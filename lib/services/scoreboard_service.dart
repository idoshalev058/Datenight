import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/splurt_game_result.dart';

class ScoreboardService {
  static const _key = 'splurt_history';

  Future<List<SplurtGameResult>> loadResults() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final results = raw
        .map((s) => SplurtGameResult.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
    results.sort((a, b) => b.playedAt.compareTo(a.playedAt));
    return results;
  }

  Future<void> addResult(SplurtGameResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.add(jsonEncode(result.toJson()));
    await prefs.setStringList(_key, raw);
  }
}
