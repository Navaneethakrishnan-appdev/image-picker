import 'package:flutter/material.dart';
import 'package:flutter_3d_choice_chip/flutter_3d_choice_chip.dart';
import 'package:google_fonts/google_fonts.dart';

class GenderWidget extends StatefulWidget {
  final Function(int) onChange;
  const GenderWidget({super.key, required this.onChange});

  @override
  State<GenderWidget> createState() => _GenderWidgetState();
}

class _GenderWidgetState extends State<GenderWidget> {
  int _gender = 0;

  final ChoiceChip3DStyle SelectedStyle = ChoiceChip3DStyle(
    topColor: Colors.grey[200]!,
    backColor: Color(0xff7C4585),
    borderRadius: BorderRadius.circular(20),
  );

  final ChoiceChip3DStyle unSelectedStyle = ChoiceChip3DStyle(
    topColor: Colors.white,
    backColor: Color(0xff7C4585),
    borderRadius: BorderRadius.circular(20),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ChoiceChip3D(
            border: Border.all(color: Color(0xff7C4585)),
            style: _gender == 1 ? SelectedStyle : unSelectedStyle,
            onSelected: () {
              setState(() {
                _gender = 1;
              });
              widget.onChange(_gender);
            },
            onUnSelected: () {},
            selected: _gender == 1,
            child: Column(
              children: [
                Image(image: AssetImage('assets/images/man.png'), width: 50),
                SizedBox(height: 5),
                Text('Male', style: GoogleFonts.outfit()),
              ],
            ),
          ),
          SizedBox(width: 20),
          ChoiceChip3D(
            border: Border.all(color: Color(0xff7C4585)),
            style: _gender == 2 ? SelectedStyle : unSelectedStyle,
            onSelected: () {
              setState(() {
                _gender = 2;
              });
              widget.onChange(_gender);
            },
            onUnSelected: () {},
            selected: _gender == 2,
            child: Column(
              children: [
                Image(image: AssetImage('assets/images/woman.png'), width: 50),
                SizedBox(height: 5),
                Text('Female', style: GoogleFonts.outfit()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
