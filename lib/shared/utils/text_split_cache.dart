/// Memoizes the line/paragraph split of a rendered text body.
///
/// The text views re-split the same strings on every build, and a rebuild is
/// not rare: a text-scale change, a theme change, or an ancestor rebuild all
/// re-enter `build()` with the same body. The bundled corpus is finite and
/// stable, so the split for a given body never changes and can be kept.
///
/// The cache is bounded so a caller that feeds in generated or user-supplied
/// text cannot grow it without limit; the least recently used entry is dropped
/// once [maxEntries] is exceeded.
class TextSplitCache {
  const TextSplitCache._();

  static final int maxEntries = 64;

  static final RegExp _blankLinePattern = RegExp(r'\n\s*\n');

  static final Map<String, List<String>> _lines = <String, List<String>>{};
  static final Map<String, List<String>> _paragraphs = <String, List<String>>{};
  static final Map<String, List<String>> _rawLines = <String, List<String>>{};

  /// The lines of [text] split on single newlines, with nothing removed.
  ///
  /// Unlike [lines] this keeps blank lines and does not trim, because callers
  /// that rebuild one span per line need the line count to stay exact.
  static List<String> rawLines(String text) {
    return _lookup(_rawLines, text, () => text.split('\n'));
  }

  /// The non-empty, trimmed lines of [text], split on single newlines.
  static List<String> lines(String text) {
    return _lookup(_lines, text, () {
      return _normalize(text.split('\n'));
    });
  }

  /// The non-empty, trimmed paragraphs of [text], split on blank lines.
  static List<String> paragraphs(String text) {
    return _lookup(_paragraphs, text, () {
      return _normalize(text.split(_blankLinePattern));
    });
  }

  /// Clears both caches. Exposed for tests.
  static void debugClear() {
    _lines.clear();
    _paragraphs.clear();
    _rawLines.clear();
  }

  static List<String> _normalize(List<String> parts) {
    return parts
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
  }

  static List<String> _lookup(
    Map<String, List<String>> cache,
    String text,
    List<String> Function() compute,
  ) {
    final cached = cache[text];
    if (cached != null) {
      // Re-inserting moves the key to the end of the insertion order, which is
      // the eviction order.
      cache.remove(text);
      cache[text] = cached;
      return cached;
    }

    final computed = compute();
    if (cache.length >= maxEntries) {
      cache.remove(cache.keys.first);
    }
    cache[text] = computed;
    return computed;
  }
}
