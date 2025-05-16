import 'package:flutter/material.dart';

import 'game_levels.dart';
import 'game_play_page.dart';
import 'level_selection_page.dart';

class GameOverPage extends StatelessWidget {
  final int currentLevel;

  const GameOverPage({super.key, required this.currentLevel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Game Over')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('❌ Game Over!', style: TextStyle(fontSize: 24)),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => GamePlayPage(level: levels[currentLevel - 1]),
                  ),
                );
              },
              child: Text('Retry Level'),
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
