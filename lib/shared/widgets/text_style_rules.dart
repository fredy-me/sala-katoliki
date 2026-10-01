/// Every presentation rule the text views used to hardcode, in one place.
///
/// The text views classified lines by matching literal string prefixes, and the
/// screens classified content by hardcoded id sets. That meant a content author
/// who rephrased `"In the name of the Father..."` silently lost its formatting,
/// and adding a litany that needed St Rita styling meant editing Dart. This file
/// removes that coupling: the rules are data, the views are code that reads data,
/// and a content author edits one table instead of three widgets.
///
/// Nothing here is language-aware. Every literal is already in the form the
/// classifier receives — lowercased for the `startsWith`/`contains` rules,
/// verbatim for the equality rules — so a view can pass its normalized string
/// straight in.
///
/// Part 6 replaces these tables with rules loaded from the content bundle. The
/// call sites do not need to change when that happens.
library;

// ---------------------------------------------------------------------------
// Response and highlight prefixes
// ---------------------------------------------------------------------------

/// Prefixes that mark a leader's response or a call to pray.
///
/// Used by `LitanyTextView._isHighlightedLine` and
/// `PrayerTextView._isResponseLine`, which historically shared one identical
/// list of twelve literals.
const List<String> kResponsePrefixes = <String>[
  'kiitikio',
  'response',
  'r:',
  'v:',
  'k:',
  'w:',
  'k.',
  'w.',
  'kiongozi:',
  'wote:',
  'tuombe',
  'let us pray',
];

/// Prefixes `LitanyTextView._isResponseLine` matches. A narrower set than
/// [kResponsePrefixes]: it drops the call-to-pray prefixes and adds the
/// `r.`/`all:` forms.
const List<String> kLitanyResponsePrefixes = <String>[
  'kiitikio',
  'response',
  'r:',
  'w:',
  'r.',
  'w.',
  'all:',
  'wote:',
];

/// Suffixes that mark a response even though the line does not start like one.
const List<String> kLitanyResponseSuffixes = <String>[
  'utuombee',
  'pray for us',
];

/// Prefixes for the "Lamb of God" turn in a litany.
const List<String> kLambOfGodPrefixes = <String>[
  'Mwanakondoo',
  'Lamb of God',
  'O Lamb of God',
];

/// Prefixes that introduce a litany or novena section.
const List<String> kLitanyHeadingPrefixes = <String>[
  'the litany of',
  'litany to',
  'litania ya',
  'litania kwa',
  'tuombe',
  'let us pray',
];

/// Single-letter leader markers, used by `NovenaTextView._isLeaderResponse`.
const List<String> kLeaderResponsePrefixes = <String>['k:', 'w:', 'v:', 'r:'];

// ---------------------------------------------------------------------------
// Novena structural prefixes
// ---------------------------------------------------------------------------

/// Prefixes that open a novena day with the invocation.
const List<String> kInvocationPrefixes = <String>[
  'in the name of the father',
  'kwa jina la baba',
];

/// Fragments that identify a `(here make ...)` / `(hapa omba ...)` placeholder.
const List<String> kRequestPlaceholderFragments = <String>[
  '(hapa omba',
  '(here make',
];

/// Anchored prefixes identifying an "(state your intentions)" line.
///
/// The original code used `startsWith` for these, so they must stay
/// anchored. A single merged `contains` list would also match a line that
/// merely *mentions* an intention marker mid-sentence, which was never the
/// case before 4.8.
const List<String> kIntentionPrefixes = <String>[
  '(state your intentions',
  '(mention your intention',
  '(taja nia zako',
  '(taja nia yako',
  '"today bring to me',
  '"leo uniletee',
  'holy spirit we ask for the grace of [',
  'roho mtakatifu, tunakuomba neema ya [',
];

/// Unanchored fragments that also identify an intention line.
///
/// These were the original code's separate `contains` clause. The `hapa)`
/// forms are matched mid-line on purpose: the novena prints the marker after
/// some lead-in text, so `startsWith` alone misses them. `(mention your
/// intention` is already in [kIntentionPrefixes]; keeping it here costs
/// nothing and mirrors the original two-clause check.
const List<String> kIntentionContainsFragments = <String>[
  '(mention your intention',
  '(taja nia zako hapa)',
  '(taja nia yako hapa)',
];

/// Prefixes that mark a leader's response inside a St Rita novena.
const List<String> kStRitaResponsePrefixes = <String>['r:', 'w:'];

/// The three-repeat prayer counts, matched as a conjunction of all three so a
/// single stray "(3)" cannot trigger the styling.
const List<List<String>> kPrayerCountTriples = <List<String>>[
  <String>['baba yetu (3)', 'salamu maria (3)', 'atukuzwe baba (3)'],
  <String>['our father (3)', 'hail mary (3)', 'glory be (3)'],
];

/// Fragments identifying a prayer count in a St Rita novena.
const List<String> kStRitaPrayerCountFragments = <String>[
  'our father (3)',
  'baba yetu (3)',
];

/// Headings matched by exact equality rather than by all-caps shape, because
/// they are sentence case in the content.
const List<String> kExactHeadingEquals = <String>[
  'pray the divine mercy chaplet.',
  'sali chapleti ya huruma ya mungu.',
  'the litany of trust',
  'litania ya tumaini',
];

/// Standalone headings matched by exact equality.
const List<String> kStandaloneHeadingEquals = <String>[
  'tuombe:',
  'utuombe:',
  'let us pray:',
  'sehemu ya pili',
  'part two',
  'baba yetu (3), salamu maria (3), atukuzwe baba (3)',
  'our father (3), hail mary (3), glory be (3)',
];

/// Standalone headings matched as prefixes, because the content appends a number
/// to them.
const List<String> kStandaloneHeadingPrefixes = <String>[
  'siku 3 za kumshukuru mungu',
  'three days of thanksgiving',
];

/// The nine virtues of the Holy Spirit novena, in both languages. Matched by
/// exact equality against the whole line.
const List<String> kHolySpiritHeadings = <String>[
  'charity',
  'joy',
  'peace',
  'patience',
  'kindness',
  'faithfulness',
  'gentleness',
  'self-control',
  'goodness',
  'mapendo',
  'furaha',
  'amani',
  'subira',
  'ukarimu',
  'uaminifu',
  'upole',
  'kujitawala',
  'wema',
];

/// Heading prefixes that split into a heading and a body. The list and the
/// pattern list are index-aligned; `_splitHeading` tries them in order.
const List<String> kHeadingWithBodyPrefixes = <String>[
  'kwa njia ya mtakatifu rita:-',
  'kwa maombezi yako:-',
  'tuombe:',
  'utuombe:',
  'through saint rita:',
  'through your intercession:',
  'let us pray:',
];

/// Patterns aligned with [kHeadingWithBodyPrefixes], each capturing the heading
/// and the body.
final List<RegExp> kHeadingWithBodyPatterns = <RegExp>[
  RegExp(r'^(Kwa njia ya Mtakatifu Rita:-)\s*(.+)$'),
  RegExp(r'^(Kwa maombezi yako:-)\s*(.+)$'),
  RegExp(r'^(TUOMBE:)\s*(.+)$'),
  RegExp(r'^(UTUOMBE:)\s*(.+)$'),
  RegExp(r'^(Through Saint Rita:)\s*(.+)$'),
  RegExp(r'^(Through your intercession:)\s*(.+)$'),
  RegExp(r'^(LET US PRAY:)\s*(.+)$'),
];

// ---------------------------------------------------------------------------
// Content ids that select a styling profile
// ---------------------------------------------------------------------------

/// Litanies rendered with the St Rita response styling.
const Set<String> kStRitaLitanies = <String>{
  'st_rita_litany',
  'bikira_maria_litany',
  'divine_mercy_litany',
  'holy_spirit_litany',
  'sacred_head_of_jesus_litany',
  'st_aloysius_gonzaga_litany',
  'st_jude_thaddeus_litany',
  'st_joseph_litany',
  'st_anthony_of_padua_litany_v1',
  'st_anthony_of_padua_litany_v2',
  'franciscan_st_anthony_litany',
  'st_anne_litany',
  'holy_angels_litany',
  'sacred_heart_of_jesus_litany',
  'holy_face_of_jesus_litany',
  'souls_in_purgatory_litany',
  'seven_sorrows_mary_litany',
  'litany_of_reparation',
};

/// Novenas rendered with the All Saints paragraph styling.
const Set<String> kAllSaintsNovenas = <String>{
  'all_saints_day_novena',
  'divine_mercy_novena',
  'holy_family_novena',
  'holy_spirit_novena',
  'litany_of_trust_novena',
  'sacred_heart_of_jesus_novena',
  'st_aloysius_gonzaga_novena',
  'st_jude_novena',
  'st_rita_novena',
};

/// The novena whose virtue names are styled as headings.
const String kHolySpiritNovenaId = 'holy_spirit_novena';

/// The novena rendered with the St Rita response styling.
const String kStRitaNovenaId = 'st_rita_novena';

/// Categories that the library screen folds into the "common prayers" grouping.
const Set<String> kCommonPrayerCategoryIds = <String>{
  'common_prayers',
  'mass_prayers',
  'confession_prayers',
  'divine_mercy',
};

// ---------------------------------------------------------------------------
// Matchers
// ---------------------------------------------------------------------------

/// Whether [normalized] starts with any of [prefixes].
///
/// Used instead of an unrolled `||` chain so the rules stay data. A const list
/// literal in Dart is a canonical, hashed constant, so the loop allocates
/// nothing per call.
bool startsWithAny(String normalized, List<String> prefixes) {
  for (final prefix in prefixes) {
    if (normalized.startsWith(prefix)) {
      return true;
    }
  }
  return false;
}

/// Whether [normalized] contains any of [fragments].
bool containsAny(String normalized, List<String> fragments) {
  for (final fragment in fragments) {
    if (normalized.contains(fragment)) {
      return true;
    }
  }
  return false;
}

/// Whether [normalized] ends with any of [suffixes].
bool endsWithAny(String normalized, List<String> suffixes) {
  for (final suffix in suffixes) {
    if (normalized.endsWith(suffix)) {
      return true;
    }
  }
  return false;
}

/// Whether [normalized] is one of [values].
bool equalsAny(String normalized, List<String> values) {
  for (final value in values) {
    if (normalized == value) {
      return true;
    }
  }
  return false;
}

/// Whether [normalized] contains every fragment of at least one triple.
///
/// This is the rule behind the "(3)" prayer-count styling. It is a conjunction
/// rather than a disjunction on purpose: matching a single stray `(3)` would
/// mis-style unrelated text.
bool containsAllOfAnyTriple(String normalized, List<List<String>> triples) {
  for (final triple in triples) {
    var all = true;
    for (final fragment in triple) {
      if (!normalized.contains(fragment)) {
        all = false;
        break;
      }
    }
    if (all) {
      return true;
    }
  }
  return false;
}

/// Whether [prayerId] selects the St Rita litany styling.
bool usesStRitaLitanyStyling(String prayerId) => kStRitaLitanies.contains(prayerId);

/// Whether [novenaId] selects the All Saints paragraph styling.
bool usesAllSaintsStyling(String novenaId) => kAllSaintsNovenas.contains(novenaId);

/// Whether [categoryId] is folded into the "common prayers" library grouping.
bool isCommonPrayerCategory(String categoryId) =>
    kCommonPrayerCategoryIds.contains(categoryId);
