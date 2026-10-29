import 'continente.dart';

enum Difficulty { easy, hard }

const List<int> kTimeOptions = [30, 60, 180, 300];

class GameConfig {
  final Continent? continent;
  final int totalSeconds;
  final Difficulty difficulty;

  const GameConfig({
    required this.continent,
    required this.totalSeconds,
    required this.difficulty,
  });

  bool get isRandomMode => continent == null;
}
