import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker_test/test/task_complete_page.dart';

import 'game_levels.dart';
import 'gameover_page.dart';

class GamePlayPage extends StatefulWidget {
  final GameLevel level;

  const GamePlayPage({super.key, required this.level});

  @override
  State<GamePlayPage> createState() => _GamePlayPageState();
}

class _GamePlayPageState extends State<GamePlayPage> {
  late Timer _timer;
  int _timeLeft = 0;
  int _pushupCount = 0;

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.level.durationInSeconds;
    startTimer();
    startPoseDetection();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft <= 0) {
        checkGameResult();
        timer.cancel();
      } else {
        setState(() {
          _timeLeft--;
        });
      }
    });
  }

  void startPoseDetection() {
    // Your pose detection logic, on detecting pushup:
    // incrementPushup();
  }

  void incrementPushup() {
    setState(() {
      _pushupCount++;
    });
  }

  void checkGameResult() {
    if (_pushupCount >= widget.level.targetPushups) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => TaskCompletePage(currentLevel: widget.level.levelNumber),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GameOverPage(currentLevel: widget.level.levelNumber),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Level ${widget.level.levelNumber}')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Time left: $_timeLeft seconds'),
          Text('Pushups: $_pushupCount'),
        ],
      ),
    );
  }
}
