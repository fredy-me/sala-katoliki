import '../../data/models/novena_model.dart';
import '../../data/models/rosary_model.dart';
import '../../features/prayers/domain/entities/prayer_entity.dart';

/// Resolves incoming App Indexing / deep link URLs (web) into internal app
/// routes so a Google search result can open the exact screen.
///
/// The site uses Kiswahili title slugs (see APP_INDEXES.md) while the app
/// routes use raw content ids. This service bridges the two:
///   https://busaradigital.com/salakatoliki/prayers/common/baba-yetu
///     -> /prayers/our_father
class DeepLinkService {
  DeepLinkService({
    required List<PrayerEntity> prayerIndex,
    required List<PrayerEntity> activePrayers,
    required List<NovenaModel> novenas,
    required List<RosaryMysteryModel> mysteries,
  }) {
    for (final prayer in prayerIndex) {
      _prayerIdsBySlug
          .putIfAbsent(slugify(prayer.title()), () => <String>[])
          .add(prayer.id);
      _prayerCategoryById[prayer.id] = prayer.categoryId;
      _knownPrayerIds.add(prayer.id);
    }
    for (final prayer in activePrayers) {
      _activePrayerIds.add(prayer.id);
    }
    for (final novena in novenas) {
      _novenaIdsBySlug[slugify(novena.title)] = novena.id;
      _novenaById[novena.id] = novena;
      _knownNovenaIds.add(novena.id);
    }
    for (final mystery in mysteries) {
      _mysteryIdsBySlug[slugify(mystery.title)] = mystery.id;
      _knownMysteryIds.add(mystery.id);
    }
  }

  static const allowedHosts = <String>{
    'busaradigital.com',
    'www.busaradigital.com',
  };

  static const sitePathPrefix = '/salakatoliki';

  /// Kiswahili URL section -> raw app category id.
  static const categorySections = <String, String>{
    'common': 'common_prayers',
    'marian': 'marian_prayers',
    'confession': 'confession_prayers',
    'litanies': 'litanies',
    'mass': 'mass_prayers',
    'divine-mercy': 'divine_mercy',
  };

  /// Known EN<->SW id mismatches for the same content (see APP_INDEXES.md
  /// Note A). Format: sw-only id -> en-only id.
  static const prayerIdAliases = <String, String>{
    'divine_mercy_prayer': 'divine_mercy_eternal_father',
  };

  final Map<String, List<String>> _prayerIdsBySlug = {};
  final Map<String, String> _prayerCategoryById = {};
  final Map<String, String> _novenaIdsBySlug = {};
  final Map<String, String> _mysteryIdsBySlug = {};
  final Map<String, NovenaModel> _novenaById = {};
  final Set<String> _knownPrayerIds = <String>{};
  final Set<String> _knownNovenaIds = <String>{};
  final Set<String> _knownMysteryIds = <String>{};
  final Set<String> _activePrayerIds = <String>{};

  /// Possible internal routes returned by [resolve]:
  /// /today, /prayers, /prayers/category/{id}, /prayers/{id}, /novenas,
  /// /novenas/{id}, /novenas/{id}/day/{day}, /novenas/{id}/closing-prayer,
  /// /novenas/{id}/thanksgiving, /rosary, /rosary/step/{mysteryId}.
  ///
  /// Returns null when the link is not a supported Sala Katoliki URL.
  String? resolve(String uriString) {
    final uri = Uri.tryParse(uriString.trim());
    if (uri == null) {
      return null;
    }

    if (uri.host.isNotEmpty && !allowedHosts.contains(uri.host)) {
      return null;
    }

    var path = uri.path;
    if (path.startsWith(sitePathPrefix)) {
      path = path.length == sitePathPrefix.length
          ? '/'
          : path.substring(sitePathPrefix.length);
    }
    if (path.isEmpty) {
      return null;
    }
    if (path == '/') {
      return '/today';
    }

    final direct = _resolveDirectRoute(path);
    if (direct != null) {
      return direct;
    }
    return _resolveSlugRoute(path);
  }

  /// Turns a title into the site's kebab-case slug. Mirrors the slugify used
  /// to build APP_INDEXES.md: lowercase, non a-z0-9 becomes a single hyphen.
  static String slugify(String text) {
    final buffer = StringBuffer();
    var hyphenPending = false;
    for (final rune in text.toLowerCase().runes) {
      final isAsciiLetter = rune >= 0x61 && rune <= 0x7a;
      final isDigit = rune >= 0x30 && rune <= 0x39;
      if (isAsciiLetter || isDigit) {
        if (hyphenPending && buffer.isNotEmpty) {
          buffer.write('-');
        }
        hyphenPending = false;
        buffer.writeCharCode(rune);
      } else {
        hyphenPending = true;
      }
    }
    return buffer.toString();
  }

  String? _resolveDirectRoute(String path) {
    final segments = _segments(path);
    if (segments.isEmpty) {
      return null;
    }

    switch (segments[0]) {
      case 'today':
        return segments.length == 1 ? '/today' : null;
      case 'prayers':
        if (segments.length == 1) {
          return '/prayers';
        }
        if (segments.length == 3 && segments[1] == 'category') {
          return _knownCategoryIds.contains(segments[2])
              ? '/prayers/category/${segments[2]}'
              : null;
        }
        if (segments.length == 2) {
          if (!_knownPrayerIds.contains(segments[1])) {
            return null;
          }
          return '/prayers/${_preferredPrayerId([segments[1]])}';
        }
        return null;
      case 'novenas':
        if (segments.length == 1) {
          return '/novenas';
        }
        final novenaId = segments[1];
        if (!_knownNovenaIds.contains(novenaId)) {
          return null;
        }
        if (segments.length == 2) {
          return '/novenas/$novenaId';
        }
        if (segments.length == 4 && segments[2] == 'day') {
          final day = int.tryParse(segments[3]);
          if (day == null || !_isValidDay(novenaId, day)) {
            return null;
          }
          return '/novenas/$novenaId/day/$day';
        }
        if (segments.length == 3 && segments[2] == 'closing-prayer') {
          return _hasClosingPrayer(novenaId)
              ? '/novenas/$novenaId/closing-prayer'
              : '/novenas/$novenaId';
        }
        if (segments.length == 3 && segments[2] == 'thanksgiving') {
          return _hasThanksgiving(novenaId)
              ? '/novenas/$novenaId/thanksgiving'
              : '/novenas/$novenaId';
        }
        return null;
      case 'rosary':
        if (segments.length == 1) {
          return '/rosary';
        }
        if (segments.length == 2 && segments[1] == 'select') {
          return '/rosary/select';
        }
        if (segments.length == 3 && segments[1] == 'step') {
          return _knownMysteryIds.contains(segments[2])
              ? '/rosary/step/${segments[2]}'
              : null;
        }
        return null;
      case 'settings':
      case 'favorites':
      case 'about':
        return segments.length == 1 ? '/${segments[0]}' : null;
    }

    return null;
  }

  String? _resolveSlugRoute(String path) {
    final segments = _segments(path);
    if (segments.length < 2 || segments[0] != 'prayers') {
      return null;
    }

    final section = segments[1];
    final rest = segments.sublist(2);

    switch (section) {
      case 'novena':
        if (rest.isEmpty) {
          return '/novenas';
        }
        final novenaId = _novenaIdsBySlug[rest.first];
        if (novenaId == null) {
          return null;
        }
        if (rest.length == 1) {
          return '/novenas/$novenaId';
        }
        if (rest.length == 3 && rest[1] == 'day') {
          final day = int.tryParse(rest[2]);
          if (day == null || !_isValidDay(novenaId, day)) {
            return null;
          }
          return '/novenas/$novenaId/day/$day';
        }
        if (rest.length == 2 && rest[1] == 'closing-prayer') {
          return _hasClosingPrayer(novenaId)
              ? '/novenas/$novenaId/closing-prayer'
              : '/novenas/$novenaId';
        }
        if (rest.length == 2 && rest[1] == 'thanksgiving') {
          return _hasThanksgiving(novenaId)
              ? '/novenas/$novenaId/thanksgiving'
              : '/novenas/$novenaId';
        }
        return null;
      case 'rosary':
        if (rest.isEmpty) {
          return '/rosary';
        }
        final mysteryId = _mysteryIdsBySlug[rest.first];
        return mysteryId == null ? null : '/rosary/step/$mysteryId';
      default:
        final categoryId = categorySections[section];
        if (categoryId == null) {
          return null;
        }
        if (rest.isEmpty) {
          return '/prayers/category/$categoryId';
        }
        final prayerId = _prayerIdBySlug(rest.first, categoryId);
        return prayerId == null ? null : '/prayers/$prayerId';
    }
  }

  String? _prayerIdBySlug(String slug, String categoryId) {
    final ids = _prayerIdsBySlug[slug] ?? const <String>[];
    for (final id in ids) {
      if (_prayerCategoryById[id] == categoryId) {
        return _preferredPrayerId([id]);
      }
    }
    if (ids.isNotEmpty) {
      return _preferredPrayerId(ids);
    }
    return null;
  }

  String _preferredPrayerId(List<String> candidates) {
    for (final id in candidates) {
      if (_activePrayerIds.contains(id)) {
        return id;
      }
    }
    for (final id in candidates) {
      final alias = prayerIdAliases[id];
      if (alias != null && _activePrayerIds.contains(alias)) {
        return alias;
      }
    }
    return candidates.first;
  }

  bool _isValidDay(String novenaId, int day) {
    final days = _novenaById[novenaId]?.days.length;
    return days != null && day >= 1 && day <= days;
  }

  bool _hasClosingPrayer(String novenaId) =>
      _novenaById[novenaId]?.closingPrayer != null;

  bool _hasThanksgiving(String novenaId) =>
      _novenaById[novenaId]?.thanksgivingSection != null;

  static final Set<String> _knownCategoryIds = categorySections.values.toSet();

  static List<String> _segments(String path) =>
      path.split('/').where((segment) => segment.isNotEmpty).toList();
}