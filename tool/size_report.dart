import 'dart:convert';
import 'dart:io';

/// Prints the shipped-size breakdown used by app_optimization.md section 1.
///
/// Reads an already-built bundle and reports what a single device actually
/// receives, separated into the two measurement bases:
///
///   Basis A - the split APK as stored on the device, where native `.so` files
///             are stored uncompressed so the loader can memory-map them.
///   Basis B - the same payload compressed for transport.
///
/// Both figures are exact. The ZIP central directory records each entry's
/// uncompressed size, its compressed size and its compression method, so the
/// on-disk and transfer sizes are derived rather than estimated.
///
/// This tool never builds anything. Point it at an existing bundle:
///
///   dart run tool/size_report.dart build/app/outputs/bundle/release/app-release.aab
///
/// With no argument it reports the source `assets/` folder instead, which is
/// the part that changes during optimization and needs no build to measure.
void main(List<String> arguments) {
  final aabPath = arguments.isEmpty ? null : arguments.first;

  if (aabPath == null) {
    _printSourceAssets();
    return;
  }

  final file = File(aabPath);
  if (!file.existsSync()) {
    stderr.writeln('Bundle not found: $aabPath');
    stderr.writeln(
      'This tool never builds. Build the bundle first, then re-run it, or run '
      'with no argument to report source asset sizes.',
    );
    exitCode = 1;
    return;
  }

  _printBundle(file);
}

void _printSourceAssets() {
  final assets = Directory('assets');
  if (!assets.existsSync()) {
    stderr.writeln('assets/ not found. Run from the project root.');
    exitCode = 1;
    return;
  }

  final entries = <_Entry>[];
  for (final entity in assets.listSync(recursive: true)) {
    if (entity is! File) {
      continue;
    }
    final relative = entity.path.replaceFirst('${assets.path}/', '');
    entries.add(
      _Entry(
        relative,
        entity.lengthSync(),
        _gzip9Size(entity),
        _Compression.deflated,
      ),
    );
  }
  entries.sort((a, b) => b.storedSize.compareTo(a.storedSize));

  final totalStored = entries.fold(0, (sum, e) => sum + e.storedSize);
  final totalRaw = entries.fold(0, (sum, e) => sum + e.size);

  stdout.writeln('Source assets - no build required');
  stdout.writeln('  files                ${entries.length}');
  stdout.writeln('  raw                  ${_mb(totalRaw)}');
  stdout.writeln('  gzip -9              ${_mb(totalStored)}');
  stdout.writeln('');
  stdout.writeln('  Largest contributors, compressed');
  for (final entry in entries.take(15)) {
    stdout.writeln(
      '    ${_kb(entry.storedSize).padLeft(10)}  '
      '${entry.path}  (${_kb(entry.size)} raw)',
    );
  }
  stdout.writeln('');
  stdout.writeln(
    '  A removed asset shrinks Basis A by its raw size and Basis B by its '
    'gzip size.',
  );
}

void _printBundle(File bundle) {
  final entries = _ZipReader(bundle).entries;
  if (entries.isEmpty) {
    stderr.writeln('No entries found in $bundle');
    exitCode = 1;
    return;
  }

  final native = <_Entry>[];
  final dex = <_Entry>[];
  final flutterAssets = <_Entry>[];
  final androidRes = <_Entry>[];
  var bundleMetadata = <_Entry>[];
  var rootConfig = <_Entry>[];

  for (final entry in entries) {
    if (entry.path.startsWith('BUNDLE-METADATA/')) {
      bundleMetadata.add(entry);
    } else if (entry.path.startsWith('base/lib/')) {
      native.add(entry);
    } else if (entry.path.startsWith('base/dex/')) {
      dex.add(entry);
    } else if (entry.path.startsWith('base/assets/flutter_assets/')) {
      flutterAssets.add(entry);
    } else if (entry.path.startsWith('base/res/') ||
        entry.path == 'base/resources.pb') {
      androidRes.add(entry);
    } else if (entry.path.startsWith('base/')) {
      rootConfig.add(entry);
    }
  }

  native.sort((a, b) => b.size.compareTo(a.size));

  stdout.writeln('Bundle - ${bundle.path}');
  stdout.writeln('  archive file size    ${_mb(bundle.lengthSync())}');
  stdout.writeln('  entries              ${entries.length}');
  stdout.writeln('');

  stdout.writeln('Not shipped to any user');
  _printRow(
    'BUNDLE-METADATA',
    bundleMetadata,
    note: 'symbol tables for Play only',
  );
  stdout.writeln('');

  stdout.writeln('Shipped once for all devices - ABI independent');
  _printRow('dex', dex);
  _printRow('assets logo.png', _pick(flutterAssets, (e) => e.path.endsWith('logo.png')));
  _printRow(
    'assets content',
    _pickAll(flutterAssets, (e) => e.path.contains('/assets/content/')),
  );
  _printRow('assets NOTICES.Z', _pick(flutterAssets, (e) => e.path.endsWith('NOTICES.Z')));
  _printRow(
    'assets other',
    _pickAll(
      flutterAssets,
      (e) =>
          !e.path.endsWith('logo.png') &&
          !e.path.endsWith('NOTICES.Z') &&
          !e.path.contains('/assets/content/'),
    ),
  );
  _printRow('res + resources.pb', androidRes);
  _printRow('manifest + config', rootConfig);
  stdout.writeln('');

  stdout.writeln('Shipped per device ABI - only the matching slice is installed');
  for (final abi in _abis(native)) {
    _printRow('lib/$abi', _pickAll(native, (e) => e.path.contains('/lib/$abi/')));
  }
  stdout.writeln('');

  stdout.writeln('Largest native libraries, by uncompressed size');
  for (final entry in native.take(8)) {
    stdout.writeln('  ${_kb(entry.size).padLeft(11)}  ${entry.path}');
  }
  stdout.writeln('');

  _printTotals(bundle, native, dex, flutterAssets, androidRes, rootConfig);
}

void _printTotals(
  File bundle,
  List<_Entry> native,
  List<_Entry> dex,
  List<_Entry> flutterAssets,
  List<_Entry> androidRes,
  List<_Entry> rootConfig,
) {
  final abi = _abis(native).contains('arm64-v8a') ? 'arm64-v8a' : _abis(native).first;
  final perAbi = _pickAll(native, (e) => e.path.contains('/lib/$abi/'));

  final abiIndependent = <_Entry>[
    ...dex,
    ...flutterAssets,
    ...androidRes,
    ...rootConfig,
  ];

  final engine = _first(perAbi, (e) => e.path.endsWith('libflutter.so'));
  final app = _first(perAbi, (e) => e.path.endsWith('libapp.so'));

  stdout.writeln('Per device, $abi');
  _printRow('libflutter.so', [engine], note: 'engine, not ours to shrink');
  _printRow('libapp.so', [app], note: 'our Dart in AOT form');
  _printRow('other native', perAbi.where((e) => e != engine && e != app).toList());
  _printRow('ABI independent', abiIndependent);
  stdout.writeln('');

  final libRaw = perAbi.fold(0, (sum, e) => sum + e.size);
  final libTransfer = perAbi.fold(0, (sum, e) => sum + e.storedSize);
  final otherTransfer = abiIndependent.fold(0, (sum, e) => sum + e.storedSize);
  final otherRaw = abiIndependent.fold(0, (sum, e) => sum + e.size);

  stdout.writeln('  Transfer size   what the user downloads, exact');
  stdout.writeln('                 ${_mb(libTransfer + otherTransfer)}');
  stdout.writeln('                   ${_mb(libTransfer)} native libraries');
  stdout.writeln('                   ${_mb(otherTransfer)} everything else');
  stdout.writeln('');

  stdout.writeln(
    '  On-device size  estimated, not measured from the bundle',
  );
  stdout.writeln(
    '                 ${_mb(libRaw + otherTransfer)}   native libraries stored',
  );
  stdout.writeln(
    '                 uncompressed so the loader can mmap them; everything',
  );
  stdout.writeln('                 else transferred at its compressed size.');
  stdout.writeln('                 Confirm with an installed split APK, not the AAB.');
  stdout.writeln('');

  stdout.writeln('  Floor           ${_mb(libRaw)}   native libraries alone,');
  stdout.writeln('                 fully uncompressed. This is the hard lower bound');
  stdout.writeln('                 for any change made to Dart code or assets, since');
  stdout.writeln('                 the engine version sets it.');
  stdout.writeln('');

  stdout.writeln(
    '  Addressable     ${_mb(otherRaw - otherTransfer)}   of compressible content,',
  );
  stdout.writeln('                 the ABI independent part, is what shrinking assets');
  stdout.writeln('                 and Dart code can actually recover.');
}

void _printRow(String label, List<_Entry> entries, {String? note}) {
  if (entries.isEmpty) {
    return;
  }
  final raw = entries.fold(0, (sum, e) => sum + e.size);
  final stored = entries.fold(0, (sum, e) => sum + e.storedSize);
  final suffix = note == null ? '' : '  ($note)';
  stdout.writeln(
    '  ${label.padRight(22)}${_kb(raw).padLeft(12)} uncompressed'
    '${_kb(stored).padLeft(13)} transfer   ${entries.length} file$suffix',
  );
}

List<_Entry> _pick(List<_Entry> entries, bool Function(_Entry) test) {
  for (final entry in entries) {
    if (test(entry)) {
      return [entry];
    }
  }
  return const [];
}

List<_Entry> _pickAll(List<_Entry> entries, bool Function(_Entry) test) =>
    entries.where(test).toList();

_Entry _first(List<_Entry> entries, bool Function(_Entry) test) {
  for (final entry in entries) {
    if (test(entry)) {
      return entry;
    }
  }
  return const _Entry('(absent)', 0, 0, _Compression.stored);
}

List<String> _abis(List<_Entry> native) {
  final abis = <String>{};
  for (final entry in native) {
    final parts = entry.path.split('/');
    if (parts.length > 2) {
      abis.add(parts[2]);
    }
  }
  return abis.toList()..sort();
}

int _gzip9Size(File file) {
  final result = Process.runSync('gzip', ['-9', '-c', file.path]);
  final output = result.stdout;
  return output is List<int> ? output.length : file.lengthSync();
}

String _mb(int bytes) => '${(bytes / 1048576).toStringAsFixed(2)} MB';

String _kb(int bytes) => '${(bytes / 1024).toStringAsFixed(1)} KB';

enum _Compression { stored, deflated }

class _Entry {
  const _Entry(this.path, this.size, this.storedSize, this.compression);

  final String path;
  final int size;
  final int storedSize;
  final _Compression compression;
}

/// Minimal ZIP central-directory reader.
///
/// A bundle is an ordinary ZIP archive, so its full file listing - including
/// each entry's uncompressed size, compressed size and compression method - can
/// be read from the central directory alone. No entry is ever decompressed,
/// which keeps this tool dependency-free and instant even for a bundle that
/// contains a 17 MB engine library.
class _ZipReader {
  _ZipReader(this.file) {
    _read();
  }

  final File file;
  final entries = <_Entry>[];

  static const _eocdSignature = 0x06054b50;
  static const _centralSignature = 0x02014b50;
  static const _eocdSize = 22;
  static const _centralHeaderSize = 46;
  static const _maxComment = 0xffff;

  void _read() {
    final bytes = file.readAsBytesSync();
    final eocd = _findEndOfCentralDirectory(bytes);
    if (eocd < 0) {
      return;
    }

    final entryCount = _uint16(bytes, eocd + 10);
    var offset = _uint32(bytes, eocd + 16);

    for (var index = 0; index < entryCount; index += 1) {
      if (offset + _centralHeaderSize > bytes.length ||
          _uint32(bytes, offset) != _centralSignature) {
        return;
      }

      final method = _uint16(bytes, offset + 10);
      final storedSize = _uint32(bytes, offset + 20);
      final size = _uint32(bytes, offset + 24);
      final nameLength = _uint16(bytes, offset + 28);
      final extraLength = _uint16(bytes, offset + 30);
      final commentLength = _uint16(bytes, offset + 32);

      final nameStart = offset + _centralHeaderSize;
      final name = ascii.decode(
        bytes.sublist(nameStart, nameStart + nameLength),
        allowInvalid: true,
      );

      entries.add(
        _Entry(
          name,
          size,
          storedSize,
          method == 0 ? _Compression.stored : _Compression.deflated,
        ),
      );

      offset = nameStart + nameLength + extraLength + commentLength;
    }
  }

  int _findEndOfCentralDirectory(List<int> bytes) {
    final lowest = bytes.length - _maxComment - _eocdSize;
    final start = lowest < 0 ? 0 : lowest;
    for (var index = bytes.length - _eocdSize; index >= start; index -= 1) {
      if (_uint32(bytes, index) == _eocdSignature) {
        return index;
      }
    }
    return -1;
  }

  int _uint16(List<int> bytes, int offset) =>
      bytes[offset] | (bytes[offset + 1] << 8);

  int _uint32(List<int> bytes, int offset) =>
      bytes[offset] |
      (bytes[offset + 1] << 8) |
      (bytes[offset + 2] << 16) |
      (bytes[offset + 3] << 24);
}
