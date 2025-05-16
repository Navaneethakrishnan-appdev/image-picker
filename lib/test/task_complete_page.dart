import 'package:flutter/material.dart';

import 'game_levels.dart';
import 'game_play_page.dart';
import 'level_selection_page.dart';

class TaskCompletePage extends StatelessWidget {
  final int currentLevel;

  const TaskCompletePage({super.key, required this.currentLevel});

  @override
  Widget build(BuildContext context) {
    final isLastLevel = currentLevel == levels.length;

    return Scaffold(
      appBar: AppBar(title: Text('Level Complete')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🎉 Task Completed!', style: TextStyle(fontSize: 24)),
            if (!isLastLevel)
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GamePlayPage(level: levels[currentLevel]),
                    ),
                  );
                },
                child: Text('Next Level'),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LevelSelectionPage()),
                  (_) => false,
                );
              },
              child: Text('Home Page'),
            ),
          ],
        ),
      ),
    );
  }
}
