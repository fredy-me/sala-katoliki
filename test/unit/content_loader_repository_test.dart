import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salakatoliki/data/datasources/local_content_datasource.dart';
import 'package:salakatoliki/data/datasources/prayer_local_datasource.dart';
import 'package:salakatoliki/data/repositories/prayer_repository_impl.dart';

void main() {
  test('loads sorted categories and prayers from bundled JSON paths', () async {
    final dataSource = LocalContentDataSource(bundle: _FakeAssetBundle());

    final categories = await dataSource.getCategories();
    final prayers = await dataSource.getPrayers(languageCode: 'en');

    expect(categories.map((category) => category.id), [
      'common_prayers',
      'marian_prayers',
    ]);
    expect(prayers, hasLength(1));
    expect(prayers.first.id, 'our_father');
    expect(prayers.first.categoryLabel('en'), 'Common Prayers');
  });

  test('repository returns prayer by id and null for unknown id', () async {
    final repository = PrayerRepositoryImpl(
      PrayerLocalDataSource(
        contentDataSource: LocalContentDataSource(bundle: _FakeAssetBundle()),
      ),
    );

    final prayer = await repository.getPrayerById(
      'our_father',
      languageCode: 'en',
    );

    expect(prayer?.title(), 'Our Father');
    expect(
      await repository.getPrayerById('missing', languageCode: 'en'),
      isNull,
    );
  });
}

class _FakeAssetBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final value = _assets[key];
    if (value == null) {
      throw Exception('Missing fake asset: $key');
    }
    return value;
  }

  @override
  Future<ByteData> load(String key) {
    throw UnimplementedError();
  }

  static const _assets = {
    'assets/content/metadata/content_manifest.json': '''
{
  "version": 1,
  "languages": ["en", "sw"],
  "categories": "assets/content/categories/categories.json",
  "prayers": {
    "en": ["assets/content/prayers/en/common_prayers.json"],
    "sw": ["assets/content/prayers/sw/common_prayers.json"]
  },
  "rosary": {"en": [], "sw": []},
  "novenas": {"en": [], "sw": []}
}
''',
    'assets/content/categories/categories.json': '''
[
  {
    "id": "marian_prayers",
    "title": {"en": "Marian Prayers", "sw": "Sala za Maria"},
    "description": {"en": "Marian prayers", "sw": "Sala za Maria"},
    "sort_order": 2,
    "icon": "star"
  },
  {
    "id": "common_prayers",
    "title": {"en": "Common Prayers", "sw": "Sala za Kawaida"},
    "description": {"en": "Common prayers", "sw": "Sala za kawaida"},
    "sort_order": 1,
    "icon": "church"
  }
]
''',
    'assets/content/prayers/en/common_prayers.json': '''
[
  {
    "id": "our_father",
    "type": "prayer",
    "category": "common_prayers",
    "language": "en",
    "title": "Our Father",
    "body": "Our Father, who art in heaven.",
    "tags": ["daily", "lord"],
    "source": "Traditional Catholic Prayer",
    "is_offline_available": true
  }
]
''',
    'assets/content/prayers/sw/common_prayers.json': '[]',
  };
}
