import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/prayer_model.dart';

class PrayerLocalDataSource {
  PrayerLocalDataSource({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  Future<List<PrayerModel>> getPrayers() async {
    final raw = await _bundle.loadString('assets/data/prayers.json');
    final decoded = jsonDecode(raw) as List<dynamic>;

    return decoded
        .cast<Map<String, dynamic>>()
        .map(PrayerModel.fromJson)
        .toList(growable: false);
  }
}
