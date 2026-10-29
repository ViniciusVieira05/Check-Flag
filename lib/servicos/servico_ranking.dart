import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/resultado_jogo.dart';

class ScoreService {
  ScoreService._();
  static final ScoreService instance = ScoreService._();

  static const _key = 'ranking';
  static const _maxEntries = 50;

  final ValueNotifier<int> best = ValueNotifier(0);

  Future<void> load() async {
    final ranking = await loadRanking();
    best.value = ranking.isEmpty ? 0 : ranking.first.correct;
  }

  Future<List<GameResult>> loadRanking() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key) ?? [];

    final results = saved.map((text) => GameResult.fromJson(jsonDecode(text))).toList();
    _sort(results);
    return results;
  }

  bool isNewRecord(GameResult result) => result.correct > 0 && result.correct > best.value;

  Future<void> saveResult(GameResult result) async {
    final ranking = await loadRanking();
    ranking.add(result);
    _sort(ranking);

    final toSave = ranking.take(_maxEntries).map((r) => jsonEncode(r.toJson())).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, toSave);

    best.value = ranking.first.correct;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    best.value = 0;
  }

  void _sort(List<GameResult> list) {
    list.sort((a, b) {
      final byCorrect = b.correct.compareTo(a.correct);
      if (byCorrect != 0) return byCorrect;
      return b.percentage.compareTo(a.percentage);
    });
  }
}
