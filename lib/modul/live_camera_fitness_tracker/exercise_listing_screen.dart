import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker_test/modul/live_camera_fitness_tracker/exercise_data_model.dart';
import 'package:image_picker_test/modul/live_camera_fitness_tracker/level_selection_page.dart';

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
        "Downward Dog",
        "plank.gif",
        Color(0xffFD8636),
        ExerciseType.downwardDogPlank,
      ),
    );
    exerciseList.add(
      ExerciseDataModel(
        "Jumping Jack",
        "jumping.gif",
        Color(0xff7F55B1),
        ExerciseType.jumpingJack,
      ),
    );

    exerciseList.add(
      ExerciseDataModel(
        "High Knees",
        "High-Knee.gif",
        Color(0xff670D2F),
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
      appBar: AppBar(
        title: Text('AI Exercises', style: GoogleFonts.outfit()),
        centerTitle: true,
      ),
      body: Container(
        child: ListView.builder(
          shrinkWrap: false,
          physics: BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => LevelSelectionPage(
                          exerciseDataModel: exerciseList[index],
                        ),
                  ),
                );
              },
              child: Container(
                height: 150,
                margin: EdgeInsets.only(left: 15, top: 6, right: 15, bottom: 6),
                padding: EdgeInsets.all(15),
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
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        height: 100,
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
