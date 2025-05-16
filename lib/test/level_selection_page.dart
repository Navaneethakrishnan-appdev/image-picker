import 'package:flutter/material.dart';

import 'game_levels.dart';
import 'game_play_page.dart';

class LevelSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Level')),
      body: ListView.builder(
        itemCount: levels.length,
        itemBuilder: (context, index) {
          final level = levels[index];
          return ListTile(
            title: Text('Level ${level.levelNumber}'),
            subtitle: Text(
              '${level.durationInSeconds}s | ${level.targetPushups} pushups',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GamePlayPage(level: level)),
              );
            },
          );
        },
      ),
    );
  }
}
