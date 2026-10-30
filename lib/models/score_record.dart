/// One finished game: how long it took and when it was played.
class ScoreRecord {
  final int timeMs;
  final DateTime playedAt;

  const ScoreRecord({required this.timeMs, required this.playedAt});

  /// Converts the record to a map so it can be saved as JSON text.
  Map<String, dynamic> toJson() => {
        'timeMs': timeMs,
        'playedAt': playedAt.toIso8601String(),
      };

  /// Rebuilds a record from the saved JSON map.
  factory ScoreRecord.fromJson(Map<String, dynamic> json) => ScoreRecord(
        timeMs: json['timeMs'] as int,
        playedAt: DateTime.parse(json['playedAt'] as String),
      );
}
