/// Explicit, language-independent reading annotations. Markers never enter
/// search, sharing, progress, or native widget snippets.
class ReadingNode {
  const ReadingNode(this.kind, this.content);

  final String kind;
  final String content;
}

abstract final class ReadingMarkup {
  static const kinds = {
    'plain',
    'response',
    'heading',
    'invocation',
    'italic',
    'rich',
    'group',
    'lamb',
    'highlight',
    'panel_gold',
    'panel_outline',
  };
  static final _marker = RegExp(r'\[\[(/?)([a-z_]+)\]\]');
  static final _plainCache = <String, String>{};
  static final _nodeCache = <String, List<ReadingNode>>{};

  static bool hasMarkers(String text) => text.contains('[[');

  static String plainText(String text) {
    if (!hasMarkers(text)) return text;
    final cached = _plainCache.remove(text);
    if (cached != null) {
      _plainCache[text] = cached;
      return cached;
    }
    final value = text.replaceAll(_marker, '');
    if (_plainCache.length >= 64) _plainCache.remove(_plainCache.keys.first);
    _plainCache[text] = value;
    return value;
  }

  /// Parses siblings, retaining their raw content for nested groups/spans.
  /// Rejects typos, unmatched markers and excessive nesting rather than letting
  /// malformed authoring instructions appear in a reading.
  static List<ReadingNode> parse(String text) {
    final cached = _nodeCache.remove(text);
    if (cached != null) {
      _nodeCache[text] = cached;
      return cached;
    }
    final result = <ReadingNode>[];
    final stack = <String>[];
    var cursor = 0;
    var contentStart = 0;
    var scanned = 0;
    for (final match in _marker.allMatches(text)) {
      final gap = text.substring(scanned, match.start);
      if (gap.contains('[[') || gap.contains(']]')) {
        throw const FormatException('Malformed reading marker');
      }
      final kind = match.group(2)!;
      if (!kinds.contains(kind)) {
        throw FormatException('Unknown reading marker: $kind');
      }
      if (match.group(1)!.isEmpty) {
        if (stack.isEmpty) {
          if (match.start > cursor) {
            result.add(
              ReadingNode('text', text.substring(cursor, match.start)),
            );
          }
          contentStart = match.end;
        }
        if (stack.length >= 8) {
          throw const FormatException('Reading markers are nested too deeply');
        }
        stack.add(kind);
      } else {
        if (stack.isEmpty || stack.removeLast() != kind) {
          throw FormatException('Unmatched reading marker: $kind');
        }
        if (stack.isEmpty) {
          result.add(
            ReadingNode(kind, text.substring(contentStart, match.start)),
          );
          cursor = match.end;
        }
      }
      scanned = match.end;
    }
    final tail = text.substring(scanned);
    if (stack.isNotEmpty || tail.contains('[[') || tail.contains(']]')) {
      throw const FormatException('Unclosed or malformed reading marker');
    }
    if (cursor < text.length) {
      result.add(ReadingNode('text', text.substring(cursor)));
    }
    final nodes = List<ReadingNode>.unmodifiable(result);
    if (_nodeCache.length >= 64) _nodeCache.remove(_nodeCache.keys.first);
    _nodeCache[text] = nodes;
    return nodes;
  }

  /// Bundled readings must declare every non-empty line/paragraph. Legacy
  /// unmarked strings remain supported by the widgets for non-content callers.
  static void validate(String text, {required String mode}) {
    final parts = mode == 'novena'
        ? text.split(RegExp(r'\n\s*\n'))
        : text.split('\n');
    final allowed = switch (mode) {
      'prayer' => const {'plain', 'response', 'heading'},
      'litany' => const {
        'plain',
        'response',
        'heading',
        'lamb',
        'panel_gold',
        'panel_outline',
      },
      'novena' => const {
        'plain',
        'response',
        'heading',
        'invocation',
        'italic',
        'rich',
        'group',
        'highlight',
      },
      _ => throw ArgumentError.value(mode, 'mode'),
    };
    void check(ReadingNode node) {
      if (!allowed.contains(node.kind)) {
        throw FormatException(
          'Reading marker ${node.kind} is not supported in $mode',
        );
      }
      if (plainText(node.content).replaceAll('*', '').trim().isEmpty) {
        throw const FormatException('Empty reading marker');
      }
      final children = parse(node.content);
      if (node.kind == 'group') {
        for (final child in children) {
          if (child.kind == 'text') {
            if (child.content.replaceAll('*', '').trim().isNotEmpty) {
              throw const FormatException(
                'Group text must have an explicit marker',
              );
            }
          } else {
            check(child);
          }
        }
      } else if (node.kind == 'rich') {
        for (final child in children) {
          if (child.kind != 'text' && child.kind != 'italic') {
            throw const FormatException(
              'Rich paragraphs allow only inline italic markers',
            );
          }
          if (child.kind == 'italic' &&
              (hasMarkers(child.content) || child.content.trim().isEmpty)) {
            throw const FormatException(
              'Inline italic markers must contain plain text',
            );
          }
        }
      } else if (hasMarkers(node.content)) {
        throw FormatException(
          'Nested markers are not supported inside ${node.kind}',
        );
      }
    }

    for (final part in parts.where((part) => part.trim().isNotEmpty)) {
      check(block(part));
    }
    if (plainText(text).trim().isEmpty) {
      throw const FormatException('Reading body must not be empty');
    }
  }

  static ReadingNode block(String text) {
    final nodes = parse(text)
        .where((node) => node.kind != 'text' || node.content.trim().isNotEmpty)
        .toList(growable: false);
    if (nodes.length != 1 || nodes.single.kind == 'text') {
      throw const FormatException('Expected one explicit reading block');
    }
    return nodes.single;
  }
}
