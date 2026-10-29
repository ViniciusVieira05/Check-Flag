class GameResult {
  final String playerName;
  final int answered;
  final int correct;
  final int totalSeconds;
  final String? continentKey;
  final String difficulty;
  final DateTime date;

  const GameResult({
    this.playerName = '',
    required this.answered,
    required this.correct,
    required this.totalSeconds,
    required this.continentKey,
    required this.difficulty,
    required this.date,
  });

  int get percentage {
    if (answered == 0) return 0;
    return (correct * 100 / answered).round();
  }

  GameResult withName(String name) => GameResult(
        playerName: name,
        answered: answered,
        correct: correct,
        totalSeconds: totalSeconds,
        continentKey: continentKey,
        difficulty: difficulty,
        date: date,
      );

  Map<String, dynamic> toJson() => {
        'name': playerName,
        'answered': answered,
        'correct': correct,
        'totalSeconds': totalSeconds,
        'continent': continentKey,
        'difficulty': difficulty,
        'date': date.toIso8601String(),
      };

  factory GameResult.fromJson(Map<String, dynamic> json) => GameResult(
        playerName: (json['name'] as String?) ?? '',
        answered: json['answered'] as int,
        correct: json['correct'] as int,
        totalSeconds: json['totalSeconds'] as int,
        continentKey: json['continent'] as String?,
        difficulty: json['difficulty'] as String,
        date: DateTime.parse(json['date'] as String),
      );
}
