import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker_test/modul/live_camera_fitness_tracker/exercise_data_model.dart';
import 'package:image_picker_test/modul/live_camera_fitness_tracker/live_camera_fitness_tracker.dart';

class LevelSelectionPage extends StatefulWidget {
  final ExerciseDataModel exerciseDataModel;

  const LevelSelectionPage({super.key, required this.exerciseDataModel});

  @override
  State<LevelSelectionPage> createState() => _LevelSelectionPageState();
}

class _LevelSelectionPageState extends State<LevelSelectionPage> {
  @override
  void initState() {
    super.initState();
    // Force a rebuild when the page is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '${widget.exerciseDataModel.title} Levels',
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        backgroundColor: widget.exerciseDataModel.color,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.navigate_before, color: Colors.white, size: 30),
        ),
      ),
      body: ListView.builder(
        shrinkWrap: false,
        physics: BouncingScrollPhysics(),
        itemCount: widget.exerciseDataModel.levels.length,
        itemBuilder: (context, index) {
          final level = widget.exerciseDataModel.levels[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color:
                level.isCompleted
                    ? Color(0xffCAE8BD)
                    // ? Colors.green.withOpacity(0.1)
                    : Color(0xffF4E7E1),
            elevation: 5,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    level.isCompleted
                        ? Colors.green
                        : widget.exerciseDataModel.color,
                child: Text(
                  '${level.levelNumber}',
                  style: GoogleFonts.outfit(color: Colors.white),
                ),
              ),
              title: Text(
                'Level ${level.levelNumber}',
                style: GoogleFonts.outfit(),
              ),
              subtitle: Text(
                'Duration: ${level.durationInSeconds} seconds\nTarget: ${level.targetCount} ${widget.exerciseDataModel.title.toLowerCase()}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (level.isCompleted)
                    Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: widget.exerciseDataModel.color,
                  ),
                ],
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => LiveCameraFitnessTracker(
                          exerciseDataModel: widget.exerciseDataModel,
                          selectedLevel: level,
                          currentLevelIndex: index,
                          allLevels: widget.exerciseDataModel.levels,
                        ),
                  ),
                );
                // Refresh the state when returning from LiveCameraFitnessTracker
                setState(() {});
              },
            ),
          );
        },
      ),
    );
  }
}
