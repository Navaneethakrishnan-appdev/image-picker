import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeightWidget extends StatefulWidget {
  final Function(int) onChange;
  const HeightWidget({super.key, required this.onChange});

  @override
  State<HeightWidget> createState() => _HeightWidgetState();
}

class _HeightWidgetState extends State<HeightWidget> {
  int _height = 150;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Text(
              'Height',
              style: GoogleFonts.outfit(fontSize: 25, color: Color(0xff9f86c0)),
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _height.toString(),
                  style: GoogleFonts.outfit(fontSize: 40),
                ),
                SizedBox(width: 10),
                Text(
                  'cm',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    color: Color(0xff9f86c0),
                  ),
                ),
              ],
            ),
            Slider(
              min: 0,
              max: 250,
              value: _height.toDouble(),
              thumbColor: Color(0xff9f86c0),
              onChanged: (value) {
                setState(() {
                  _height = value.toInt();
                });
                widget.onChange(_height);
              },
            ),
          ],
        ),
      ),
    );
  }
}
