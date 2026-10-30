import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/grid_size.dart';
import '../models/score_record.dart';

/// Saves and loads the top 10 times for each grid size.
///
/// The scores are stored on the device with shared_preferences as a JSON
/// text list, so they are kept after the app is closed.
class ScoreStorage {
  static const int maxRecords = 10;

  /// Loads the saved scores for [size], fastest first.
  static Future<List<ScoreRecord>> loadScores(GridSize size) async {
    final prefs = await SharedPreferences.getInstance();
    final text = prefs.getString(size.storageKey);
    if (text == null) return [];
    final list = jsonDecode(text) as List<dynamic>;
    return list
        .map((item) => ScoreRecord.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Returns the best (lowest) time for [size], or null if there is none.
  static Future<int?> bestTime(GridSize size) async {
    final scores = await loadScores(size);
    return scores.isEmpty ? null : scores.first.timeMs;
  }

  /// Adds a new time. Keeps only the 10 fastest.
  /// Returns true if the new time is a personal best.
  static Future<bool> addScore(GridSize size, int timeMs) async {
    final scores = await loadScores(size);
    final isNewBest = scores.isEmpty || timeMs < scores.first.timeMs;

    scores.add(ScoreRecord(timeMs: timeMs, playedAt: DateTime.now()));
    scores.sort((a, b) => a.timeMs.compareTo(b.timeMs));
    final top = scores.take(maxRecords).toList();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      size.storageKey,
      jsonEncode(top.map((s) => s.toJson()).toList()),
    );
    return isNewBest;
  }

  /// Deletes all scores for [size].
  static Future<void> clearScores(GridSize size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(size.storageKey);
  }
}
