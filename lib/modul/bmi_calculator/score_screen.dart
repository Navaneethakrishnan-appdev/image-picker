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
  void setBmiInterpretation() {
    if (widget.bmiScore > 30) {
      widget.bmiStatus = 'Obese';
      widget.bmiInterpretation = 'Please work to reduce Obesity';
      widget.bmiStatusColor = Colors.pink;
    } else if (widget.bmiScore >= 25) {
      widget.bmiStatus = 'Overweight';
      widget.bmiInterpretation = 'Do regular exercise and reduce the weight';
      widget.bmiStatusColor = Colors.orange;
    } else if (widget.bmiScore >= 18.5) {
      widget.bmiStatus = 'Normal';
      widget.bmiInterpretation = 'Enjoy, You are fit';
      widget.bmiStatusColor = Colors.green;
    } else if (widget.bmiScore < 18.5) {
      widget.bmiStatus = 'Underweight';
      widget.bmiInterpretation = 'Try to increase the weight';
      widget.bmiStatusColor = Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    setBmiInterpretation();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff7C4585),
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
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Card(
            elevation: 12,
            shape: RoundedRectangleBorder(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Your Score',
                  style: GoogleFonts.outfit(
                    fontSize: 30,
                    color: Color(0xff7C4585),
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
                  needleColor: Color(0xff7C4585),
                ),
                SizedBox(height: 10),
                Text(
                  widget.bmiStatus!,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    color: widget.bmiStatusColor,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  widget.bmiInterpretation!,
                  style: GoogleFonts.outfit(fontSize: 15),
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
                        backgroundColor: Color(0xff7C4585),
                      ),
                      child: Text(
                        'Re-calculate',
                        style: GoogleFonts.outfit(color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        Share.share(
                          'Your BMI is ${widget.bmiScore.toStringAsFixed(1)} at age ${widget.age}',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff7C4585),
                      ),
                      child: Text(
                        'Share',
                        style: GoogleFonts.outfit(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
