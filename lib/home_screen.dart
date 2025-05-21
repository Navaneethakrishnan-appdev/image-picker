import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker_test/modul/bmi_calculator/bmi_calculator.dart';
import 'package:image_picker_test/modul/live_camera_fitness_tracker/exercise_listing_screen.dart';
import 'package:image_picker_test/modul/yoga_pose_detection/yoga_pose_detection.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff129990),
        title: Text(
          'AI Fitness Trainer',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: double.infinity,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: 15,
                        left: 15,
                        top: 15,
                        bottom: 0,
                      ),
                      child: Text(
                        'Yoga Pose Detector:',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          color: Color(0xff129990),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => YogaPoseDetection(),
                        ),
                      );
                    },
                    child: Container(
                      height: 150,
                      width: 350,
                      margin: EdgeInsets.only(
                        right: 15,
                        left: 15,
                        top: 15,
                        bottom: 0,
                      ),
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Color(0xffffe5f6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Color(0xff9B7EBD), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
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
                              'Yoga Pose Detector',
                              style: GoogleFonts.outfit(
                                color: Color(0xff9B7EBD),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
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
                                  'assets/images/home_yogapose.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: 15,
                        left: 15,
                        top: 15,
                        bottom: 0,
                      ),
                      child: Text(
                        'AI Exercises:',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          color: Color(0xff129990),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExerciseListingScreen(),
                        ),
                      );
                    },
                    child: Container(
                      height: 150,
                      width: 350,
                      margin: EdgeInsets.only(
                        right: 15,
                        left: 15,
                        top: 15,
                        bottom: 0,
                      ),
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Color(0xffAA60C8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
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
                              'AI Exercises',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
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
                                  'assets/images/home_exercises_pose1.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: 15,
                        left: 15,
                        top: 15,
                        bottom: 0,
                      ),
                      child: Text(
                        'BMI Calculator:',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          color: Color(0xff129990),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BmiCalculator(),
                        ),
                      );
                    },
                    child: Container(
                      height: 150,
                      width: 350,
                      margin: EdgeInsets.only(
                        right: 15,
                        left: 15,
                        top: 15,
                        bottom: 0,
                      ),
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Color(0xfffee6c0),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Color(0xfffc2c00), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
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
                              'BMI Calculator:',
                              style: GoogleFonts.outfit(
                                color: Color(0xfffc2c00),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                              height: 150,
                              width: 150,
                              child: Image(
                                image: AssetImage('assets/images/home_bmi.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
