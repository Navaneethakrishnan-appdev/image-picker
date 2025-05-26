import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker_test/modul/bmi_calculator/age_weight_widget.dart';
import 'package:image_picker_test/modul/bmi_calculator/gender_widget.dart';
import 'package:image_picker_test/modul/bmi_calculator/height_widget.dart';
import 'package:image_picker_test/modul/bmi_calculator/score_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';

class BmiCalculator extends StatefulWidget {
  const BmiCalculator({super.key});

  @override
  State<BmiCalculator> createState() => _BmiCalculatorState();
}

class _BmiCalculatorState extends State<BmiCalculator> {
  int _genter = 0;
  int _height = 150;
  int _age = 30;
  int _weight = 50;
  bool _isFinished = false;
  double _bmiScore = 0;

  void calculateBmi() {
    _bmiScore = _weight / pow(_height / 100, 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.navigate_before, size: 35, color: Colors.white),
        ),
        title: Text(
          'BMI Calculator',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xff9f86c0),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(12),
          child: Card(
            elevation: 12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                //let create widget for gender selection
                SizedBox(height: 20),
                GenderWidget(
                  onChange: (genderVal) {
                    _genter = genderVal;
                  },
                ),
                SizedBox(height: 20),
                HeightWidget(
                  onChange: (heightVal) {
                    _height = heightVal;
                  },
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AgeWeightWidget(
                      onChange: (ageVal) {
                        _age = ageVal;
                      },
                      title: 'Age',
                      initValue: 30,
                      min: 0,
                      max: 100,
                    ),
                    AgeWeightWidget(
                      onChange: (weightVal) {
                        _weight = weightVal;
                      },
                      title: 'Weight(Kg)',
                      initValue: 50,
                      min: 0,
                      max: 200,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 40,
                  ),
                  child: SwipeableButtonView(
                    isFinished: _isFinished,
                    onFinish: () async {
                      await Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          child: ScoreScreen(bmiScore: _bmiScore, age: _age),
                        ),
                      );
                      setState(() {
                        _isFinished = false;
                      });
                    },
                    onWaitingProcess: () {
                      //calculate BMI here
                      calculateBmi();
                      Future.delayed(Duration(seconds: 1), () {
                        setState(() {
                          _isFinished = true;
                        });
                      });
                    },
                    activeColor: Color(0xff9f86c0),
                    buttonWidget: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xff9f86c0),
                    ),
                    buttonText: 'CALCULATE',
                    buttontextstyle: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
