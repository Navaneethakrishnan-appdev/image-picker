import 'dart:ui';

enum ExerciseType { pushUps, squats, downwardDogPlank, jumpingJack, highKnees }

class ExerciseDataModel {
  String title;
  String image;
  Color color;
  ExerciseType type;

  ExerciseDataModel(this.title, this.image, this.color, this.type);
}
