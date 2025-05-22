import 'dart:ui';

enum ExerciseType { pushUps, squats, downwardDogPlank, jumpingJack, highKnees }

class ExerciseLevel {
  final int levelNumber;
  final int durationInSeconds;
  final int targetCount;
  bool isCompleted;

  ExerciseLevel({
    required this.levelNumber,
    required this.durationInSeconds,
    required this.targetCount,
    this.isCompleted = false,
  });

  void markAsCompleted() {
    isCompleted = true;
  }
}

class ExerciseDataModel {
  String title;
  String image;
  Color color;
  ExerciseType type;
  List<ExerciseLevel> levels = []; // Initialize with empty list

  ExerciseDataModel(this.title, this.image, this.color, this.type) {
    // Initialize default levels for each exercise type
    levels = _initializeLevels();
  }

  List<ExerciseLevel> _initializeLevels() {
    switch (type) {
      case ExerciseType.pushUps:
        return [
          ExerciseLevel(levelNumber: 1, durationInSeconds: 45, targetCount: 5),
          ExerciseLevel(levelNumber: 2, durationInSeconds: 60, targetCount: 10),
          ExerciseLevel(levelNumber: 3, durationInSeconds: 90, targetCount: 15),
          ExerciseLevel(
            levelNumber: 4,
            durationInSeconds: 120,
            targetCount: 20,
          ),
          ExerciseLevel(
            levelNumber: 5,
            durationInSeconds: 150,
            targetCount: 25,
          ),
        ];
      case ExerciseType.squats:
        return [
          ExerciseLevel(levelNumber: 1, durationInSeconds: 45, targetCount: 5),
          ExerciseLevel(levelNumber: 2, durationInSeconds: 60, targetCount: 10),
          ExerciseLevel(levelNumber: 3, durationInSeconds: 90, targetCount: 15),
          ExerciseLevel(
            levelNumber: 4,
            durationInSeconds: 120,
            targetCount: 20,
          ),
          ExerciseLevel(
            levelNumber: 5,
            durationInSeconds: 150,
            targetCount: 25,
          ),
        ];
      case ExerciseType.downwardDogPlank:
        return [
          ExerciseLevel(levelNumber: 1, durationInSeconds: 45, targetCount: 5),
          ExerciseLevel(levelNumber: 2, durationInSeconds: 60, targetCount: 10),
          ExerciseLevel(levelNumber: 3, durationInSeconds: 90, targetCount: 15),
          ExerciseLevel(
            levelNumber: 4,
            durationInSeconds: 120,
            targetCount: 20,
          ),
          ExerciseLevel(
            levelNumber: 5,
            durationInSeconds: 150,
            targetCount: 25,
          ),
        ];
      case ExerciseType.jumpingJack:
        return [
          ExerciseLevel(levelNumber: 1, durationInSeconds: 45, targetCount: 5),
          ExerciseLevel(levelNumber: 2, durationInSeconds: 60, targetCount: 10),
          ExerciseLevel(levelNumber: 3, durationInSeconds: 90, targetCount: 15),
          ExerciseLevel(
            levelNumber: 4,
            durationInSeconds: 120,
            targetCount: 20,
          ),
          ExerciseLevel(
            levelNumber: 5,
            durationInSeconds: 150,
            targetCount: 25,
          ),
        ];
      case ExerciseType.highKnees:
        return [
          ExerciseLevel(levelNumber: 1, durationInSeconds: 45, targetCount: 5),
          ExerciseLevel(levelNumber: 2, durationInSeconds: 60, targetCount: 10),
          ExerciseLevel(levelNumber: 3, durationInSeconds: 90, targetCount: 15),
          ExerciseLevel(
            levelNumber: 4,
            durationInSeconds: 120,
            targetCount: 20,
          ),
          ExerciseLevel(
            levelNumber: 5,
            durationInSeconds: 150,
            targetCount: 25,
          ),
        ];
    }
  }
}
