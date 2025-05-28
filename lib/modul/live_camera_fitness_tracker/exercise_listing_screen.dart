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
        Color(0xffe0b1cb),
        ExerciseType.pushUps,
      ),
    );
    exerciseList.add(
      ExerciseDataModel(
        "Squats",
        "squat.gif",
        Color(0xffbe95c4),
        ExerciseType.squats,
      ),
    );
    exerciseList.add(
      ExerciseDataModel(
        "Downward Dog",
        "plank.gif",
        Color(0xff9f86c0),
        ExerciseType.downwardDogPlank,
      ),
    );
    exerciseList.add(
      ExerciseDataModel(
        "Jumping Jack",
        "jumping.gif",
        Color(0xff5e548e),
        ExerciseType.jumpingJack,
      ),
    );

    exerciseList.add(
      ExerciseDataModel(
        "High Knees",
        "High-Knee.gif",
        Color(0xff231942),
        ExerciseType.highKnees,
      ),
    );

    exerciseList.add(
      ExerciseDataModel(
        "Bird Dog",
        "bird-dog.gif",
        Color(0xff9B7EBD),
        ExerciseType.birdDog,
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
        backgroundColor: Color(0xffAA60C8),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.navigate_before, size: 35, color: Colors.white),
        ),
        title: Text(
          'AI Exercises',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
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
                margin: EdgeInsets.only(
                  left: 15,
                  top: 10,
                  right: 15,
                  bottom: 10,
                ),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: exerciseList[index].color,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.8),
                      spreadRadius: 4,
                      blurRadius: 10,
                      offset: Offset(0, 3), // horizontal, vertical offset
                    ),
                  ],
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
