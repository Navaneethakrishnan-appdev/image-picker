import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AgeWeightWidget extends StatefulWidget {
  final Function(int) onChange;
  final String title;
  final int initValue;
  final int min;
  final int max;

  const AgeWeightWidget({
    super.key,
    required this.onChange,
    required this.title,
    required this.initValue,
    required this.min,
    required this.max,
  });

  @override
  State<AgeWeightWidget> createState() => _AgeWeightWidgetState();
}

class _AgeWeightWidgetState extends State<AgeWeightWidget> {
  int counter = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    counter = widget.initValue;
  }

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
              widget.title,
              style: GoogleFonts.outfit(fontSize: 20, color: Color(0xff7C4585)),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(7.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (counter > widget.min) {
                          counter--;
                        }
                      });
                      widget.onChange(counter);
                    },
                    child: SizedBox(
                      height: 45,
                      width: 45,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Color(0xff7C4585),
                        child: Icon(Icons.remove, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    counter.toString(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 5),
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (counter < widget.max) {
                          counter++;
                        }
                      });
                      widget.onChange(counter);
                    },
                    child: SizedBox(
                      height: 45,
                      width: 45,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Color(0xff7C4585),
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
