import 'package:flutter/material.dart';
import 'package:image_picker_test/exercise_data_model.dart';
import 'package:image_picker_test/test/level_selection_page.dart';

class ExerciseListingScreen extends StatefulWidget {
  const ExerciseListingScreen({super.key});

  @override
  State<ExerciseListingScreen> createState() => _ExerciseListingScreenState();
}

class _ExerciseListingScreenState extends State<ExerciseListingScreen> {
  List<ExerciseDataModel> exerciseList = [];

  loadData() {
    exerciseList.add(
      ExerciseDataModel(
        "Push Ups",
        "pushup.gif",
        Color(0xff005F9C),
        ExerciseType.pushUps,
      ),
    );
    exerciseList.add(
      ExerciseDataModel(
        "Squats",
        "squat.gif",
        Color(0xffDF5889),
        ExerciseType.squats,
      ),
    );
    exerciseList.add(
      ExerciseDataModel(
        "Plank to Downward Dog",
        "plank.gif",
        Color(0xffFD8636),
        ExerciseType.downwardDogPlank,
      ),
    );
    exerciseList.add(
      ExerciseDataModel(
        "Jumping Jack",
        "jumping.gif",
        Color(0xff000000),
        ExerciseType.jumpingJack,
      ),
    );

    exerciseList.add(
      ExerciseDataModel(
        "High Knees",
        "High-Knee.gif",
        Colors.deepOrangeAccent,
        ExerciseType.highKnees,
      ),
    );

    setState(() {
      exerciseList;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI Exercises')),
      body: Container(
        child: ListView.builder(
          shrinkWrap: false,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder:
                //         (context) => LiveCameraFitnessTracker(
                //           exerciseDataModel: exerciseList[index],
                //         ),
                //   ),
                // );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LevelSelectionPage()),
                );
              },
              child: Container(
                height: 150,
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: exerciseList[index].color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        exerciseList[index].title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        height: 150,
                        width: 150,
                        child: Image(
                          image: AssetImage(
                            'assets/gif/${exerciseList[index].image}',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          itemCount: exerciseList.length,
        ),
      ),
    );
  }
}
