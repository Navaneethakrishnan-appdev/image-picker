class GameLevel {
  final int levelNumber;
  final int durationInSeconds;
  final int targetPushups;

  GameLevel({
    required this.levelNumber,
    required this.durationInSeconds,
    required this.targetPushups,
  });
}

final List<GameLevel> levels = [
  GameLevel(levelNumber: 1, durationInSeconds: 60, targetPushups: 10),
  GameLevel(levelNumber: 2, durationInSeconds: 70, targetPushups: 15),
  GameLevel(levelNumber: 3, durationInSeconds: 80, targetPushups: 20),
  // Add more levels as needed...
];
