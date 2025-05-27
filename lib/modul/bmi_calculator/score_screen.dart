import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pretty_gauge/pretty_gauge.dart';
import 'package:share_plus/share_plus.dart';

class ScoreScreen extends StatefulWidget {
  final double bmiScore;
  final int age;
  String? bmiStatus;
  String? bmiInterpretation;
  Color? bmiStatusColor;
  ScoreScreen({super.key, required this.bmiScore, required this.age});

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  String? detailedDescription;
  List<String> recommendations = [];

  void setBmiInterpretation() {
    if (widget.bmiScore > 30) {
      widget.bmiStatus = 'Obese';
      widget.bmiInterpretation = 'Please work to reduce Obesity';
      widget.bmiStatusColor = Colors.pink;
      detailedDescription = 'Your BMI indicates obesity, which may increase the risk of various health conditions including heart disease, type 2 diabetes, and certain cancers.';
      recommendations = [
        'Consult with a healthcare provider for a personalized weight loss plan',
        'Focus on portion control and mindful eating',
        'Incorporate regular physical activity (30-60 minutes daily)',
        'Choose whole foods over processed foods',
        'Consider working with a nutritionist for meal planning',
        'Aim for a gradual weight loss of 1-2 pounds per week'
      ];
    } else if (widget.bmiScore >= 25) {
      widget.bmiStatus = 'Overweight';
      widget.bmiInterpretation = 'Do regular exercise and reduce the weight';
      widget.bmiStatusColor = Colors.orange;
      detailedDescription = 'Your BMI indicates you are overweight. While not as severe as obesity, this still increases your risk for health problems.';
      recommendations = [
        'Increase daily physical activity',
        'Reduce calorie intake by 500-750 calories per day',
        'Focus on whole grains, lean proteins, and vegetables',
        'Limit processed foods and sugary drinks',
        'Get 7-8 hours of sleep each night',
        'Consider tracking your food intake to identify patterns'
      ];
    } else if (widget.bmiScore >= 18.5) {
      widget.bmiStatus = 'Normal';
      widget.bmiInterpretation = 'Enjoy, You are fit';
      widget.bmiStatusColor = Colors.green;
      detailedDescription = 'Your BMI is within the healthy range. This is associated with the lowest health risks.';
      recommendations = [
        'Maintain your current healthy lifestyle',
        'Continue regular physical activity',
        'Eat a balanced diet with variety',
        'Stay hydrated throughout the day',
        'Get regular health check-ups',
        'Practice stress management techniques'
      ];
    } else if (widget.bmiScore < 18.5) {
      widget.bmiStatus = 'Underweight';
      widget.bmiInterpretation = 'Try to increase the weight';
      widget.bmiStatusColor = Colors.red;
      detailedDescription = 'Your BMI indicates you are underweight, which may lead to health issues like weakened immune system, nutritional deficiencies, and decreased muscle mass.';
      recommendations = [
        'Consult with a healthcare provider to rule out underlying conditions',
        'Increase calorie intake with nutrient-dense foods',
        'Add healthy fats to your diet (avocados, nuts, olive oil)',
        'Eat frequent, smaller meals throughout the day',
        'Include protein-rich foods in each meal',
        'Consider strength training to build muscle mass'
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    setBmiInterpretation();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff9f86c0),
        title: Text(
          'BMI Score',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.navigate_before, color: Colors.white, size: 40),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Card(
            elevation: 12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Your Score',
                    style: GoogleFonts.outfit(
                      fontSize: 30,
                      color: Color(0xff9f86c0),
                    ),
                  ),
                  SizedBox(height: 20),
                  PrettyGauge(
                    gaugeSize: 300,
                    minValue: 0,
                    maxValue: 40,
                    segments: [
                      GaugeSegment('UnderWeight', 18.5, Colors.red),
                      GaugeSegment('Normal', 6.4, Colors.green),
                      GaugeSegment('OverWeight', 5.1, Colors.orange),
                      GaugeSegment('Obese', 10.0, Colors.pink),
                    ],
                    valueWidget: Text(
                      widget.bmiScore.toStringAsFixed(1),
                      style: GoogleFonts.outfit(fontSize: 40),
                    ),
                    currentValue: widget.bmiScore.toDouble(),
                    needleColor: Color(0xff9f86c0),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.bmiStatusColor!.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.bmiStatus!,
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: widget.bmiStatusColor,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          widget.bmiInterpretation!,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detailed Analysis',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff9f86c0),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          detailedDescription!,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recommendations',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff9f86c0),
                          ),
                        ),
                        SizedBox(height: 10),
                        ...recommendations.map((recommendation) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: Color(0xff9f86c0),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  recommendation,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff9f86c0),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: Text(
                          'Re-calculate',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          Share.share(
                            'My BMI is ${widget.bmiScore.toStringAsFixed(1)} at age ${widget.age}.\n'
                            'Status: ${widget.bmiStatus}\n'
                            'Interpretation: ${widget.bmiInterpretation}\n'
                            'Detailed Description: $detailedDescription\n\n'
                            'Recommendations:\n${recommendations.join('\n')}'
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff9f86c0),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: Text(
                          'Share',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
