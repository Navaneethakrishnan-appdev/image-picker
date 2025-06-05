import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker_test/modul/bmi_calculator/bmi_calculator.dart';
import 'package:image_picker_test/modul/food_chart/food_chart_screen.dart';
import 'package:image_picker_test/modul/live_camera_fitness_tracker/exercise_listing_screen.dart';
import 'package:image_picker_test/modul/yoga_pose_detection/yoga_pose_detection.dart';
import 'package:image_picker_test/chat_page.dart';

import 'profile_page.dart';
import 'services/auth_service.dart';
import 'signin_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  String? userEmail;
  String? userName;
  String? userPhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = await _authService.getCurrentUser();
    if (mounted) {
      setState(() {
        userEmail = user?.email;
        userName = user?.displayName ?? 'Fitness User';
        userPhotoUrl = user?.photoURL;
      });
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff129990),
        iconTheme: const IconThemeData(color: Colors.white),
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
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 40, right: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff129990), Color(0xff9B7EBD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatPage()),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                userName ?? 'Fitness User',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              accountEmail: Text(
                userEmail ?? 'Loading...',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage:
                    userPhotoUrl != null ? NetworkImage(userPhotoUrl!) : null,
                child:
                    userPhotoUrl == null
                        ? Icon(
                          Icons.person,
                          size: 40,
                          color: const Color(0xff129990),
                        )
                        : null,
              ),
              decoration: const BoxDecoration(color: Color(0xff129990)),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.black),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.black),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center, color: Colors.black),
              title: const Text('Exercises'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExerciseListingScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.self_improvement, color: Colors.black),
              title: const Text('Yoga Pose Detection'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => YogaPoseDetection()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate, color: Colors.black),
              title: const Text('BMI Calculator'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BmiCalculator()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate, color: Colors.black),
              title: const Text('Food Chart'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FoodChartScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black),
              title: const Text('Sign Out'),
              onTap: _signOut,
            ),
          ],
        ),
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
                        border: Border.all(color: Colors.white, width: 1),
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
                        'Food Chart:',
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
                          builder: (context) => const FoodChartScreen(),
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
                        color: Color(0xffC1E2A4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 1),
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
                              'Food Chart',
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
                                  'assets/images/home_food_chart1.png',
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
                        color: Color(0xff9f86c0),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 1),
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
