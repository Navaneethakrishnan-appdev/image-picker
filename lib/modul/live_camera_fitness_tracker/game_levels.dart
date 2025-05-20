class ExerciseDataModel {
  final int durationInSeconds;
  final int targetPushups;

  ExerciseDataModel({
    required this.durationInSeconds,
    required this.targetPushups,
  });
}

class GameLevel extends ExerciseDataModel {
  final int levelNumber;

  GameLevel({
    required this.levelNumber,
    required int durationInSeconds,
    required int targetPushups,
  }) : super(
         durationInSeconds: durationInSeconds,
         targetPushups: targetPushups,
       );
}
