import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum ExerciseType { pushUps, squats, downwardDogPlank, jumpingJack, highKnees, birdDog,  }

class ExerciseLevel {
  final int levelNumber;
  final int durationInSeconds;
  final int targetCount;
  bool isCompleted;

  ExerciseLevel({
    required this.levelNumber,
    required this.durationInSeconds,
    required this.targetCount,
    this.isCompleted = false,
  });

  void markAsCompleted() {
    isCompleted = true;
  }

  Map<String, dynamic> toMap() {
    return {
      'levelNumber': levelNumber,
      'durationInSeconds': durationInSeconds,
      'targetCount': targetCount,
      'isCompleted': isCompleted,
    };
  }

  factory ExerciseLevel.fromMap(Map<String, dynamic> map) {
    return ExerciseLevel(
      levelNumber: map['levelNumber'],
      durationInSeconds: map['durationInSeconds'],
      targetCount: map['targetCount'],
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

class ExerciseDataModel {
  String title;
  String image;
  Color color;
  ExerciseType type;
  List<ExerciseLevel> levels = [];

  ExerciseDataModel(this.title, this.image, this.color, this.type) {
    levels = _initializeLevels();
    loadCompletionStatus();
  }

  Future<void> loadCompletionStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user logged in');
        return;
      }

      // Get the user's exercise progress document from 'completed_levels'
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('completed_levels') // Corrected to 'completed_levels'
          .doc(title)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final completedLevels = data['completedLevels'] as List<dynamic>;
        final lastUpdated = data['lastUpdated'] as Timestamp?;

        print('✅Loading completion status for $title');
        print('✅Completed levels: $completedLevels');
        print('✅Last updated: $lastUpdated');

        // Update the completion status for each level
        for (var level in levels) {
          level.isCompleted = completedLevels.contains(level.levelNumber);
        }
      } else {
        print('❌No progress data found for $title');
        // Initialize with no completed levels
        for (var level in levels) {
          level.isCompleted = false;
        }
      }
    } catch (e) {
      print('❌Error loading completion status: $e');
      // Initialize with no completed levels in case of error
      for (var level in levels) {
        level.isCompleted = false;
      }
    }
  }

  Future<void> saveCompletionStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌No user logged in - Cannot save completion status');
        return;
      }

      print('👤Current user ID: ${user.uid}');
      print('📝Attempting to save data for exercise: $title');

      final completedLevels = levels
          .where((level) => level.isCompleted)
          .map((level) => level.levelNumber)
          .toList();

      print('✅Completed levels to save: $completedLevels');

      // Save to Firestore with timestamp in 'completed_levels'
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('completed_levels')
          .doc(title)
          .set({
        'completedLevels': completedLevels,
        'lastUpdated': FieldValue.serverTimestamp(),
        'exerciseType': type.toString(),
        'totalLevels': levels.length,
        'completedCount': completedLevels.length,
      }, SetOptions(merge: true));

      print('✅Successfully saved completion status to Firestore');
    } catch (e) {
      print('❌Error saving completion status: $e');
      print('❌Error details: ${e.toString()}');
    }
  }

  // Get completion statistics
  Future<Map<String, dynamic>> getCompletionStats() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return {};

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('completed_levels') // Corrected to 'completed_levels'
          .doc(title)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'completedLevels': data['completedLevels'] as List<dynamic>,
          'totalLevels': data['totalLevels'] as int,
          'completedCount': data['completedCount'] as int,
          'lastUpdated': data['lastUpdated'] as Timestamp?,
        };
      }
      return {};
    } catch (e) {
      print('❌Error getting completion stats: $e');
      return {};
    }
  }

  List<ExerciseLevel> _initializeLevels() {
    switch (type) {
      case ExerciseType.pushUps:
        return [
          ExerciseLevel(levelNumber: 1, durationInSeconds: 45, targetCount: 5),
          ExerciseLevel(levelNumber: 2, durationInSeconds: 60, targetCount: 10),
          ExerciseLevel(levelNumber: 3, durationInSeconds: 90, targetCount: 15),
          ExerciseLevel(
            levelNumber: 4,
            durationInSeconds: 120,
            targetCount: 20,
          ),
          ExerciseLevel(
            levelNumber: 5,
            durationInSeconds: 150,
            targetCount: 25,
          ),
        ];
      case ExerciseType.squats:
        return [
          ExerciseLevel(levelNumber: 1, durationInSeconds: 45, targetCount: 5),
          ExerciseLevel(levelNumber: 2, durationInSeconds: 60, targetCount: 10),
          ExerciseLevel(levelNumber: 3, durationInSeconds: 90, targetCount: 15),
          ExerciseLevel(
            levelNumber: 4,
            durationInSeconds: 120,
            targetCount: 20,
          ),
          ExerciseLevel(
            levelNumber: 5,
            durationInSeconds: 150,
            targetCount: 25,
          ),
        ];
      case ExerciseType.downwardDogPlank:
        return [
          ExerciseLevel(levelNumber: 1, durationInSeconds: 45, targetCount: 5),
          ExerciseLevel(levelNumber: 2, durationInSeconds: 60, targetCount: 10),
          ExerciseLevel(levelNumber: 3, durationInSeconds: 90, targetCount: 15),
          ExerciseLevel(
            levelNumber: 4,
            durationInSeconds: 120,
            targetCount: 20,
          ),
          ExerciseLevel(
            levelNumber: 5,
            durationInSeconds: 150,
            targetCount: 25,
          ),
        ];
      case ExerciseType.jumpingJack:
        return [
          ExerciseLevel(levelNumber: 1, durationInSeconds: 45, targetCount: 5),
          ExerciseLevel(levelNumber: 2, durationInSeconds: 60, targetCount: 10),
          ExerciseLevel(levelNumber: 3, durationInSeconds: 90, targetCount: 15),
          ExerciseLevel(
            levelNumber: 4,
            durationInSeconds: 120,
            targetCount: 20,
          ),
          ExerciseLevel(
            levelNumber: 5,
            durationInSeconds: 150,
            targetCount: 25,
          ),
        ];
      case ExerciseType.highKnees:
        return [
          ExerciseLevel(levelNumber: 1, durationInSeconds: 45, targetCount: 5),
          ExerciseLevel(levelNumber: 2, durationInSeconds: 60, targetCount: 10),
          ExerciseLevel(levelNumber: 3, durationInSeconds: 90, targetCount: 15),
          ExerciseLevel(
            levelNumber: 4,
            durationInSeconds: 120,
            targetCount: 20,
          ),
          ExerciseLevel(
            levelNumber: 5,
            durationInSeconds: 150,
            targetCount: 25,
          ),
        ];
      case ExerciseType.birdDog:
        return [
          ExerciseLevel(levelNumber: 1, durationInSeconds: 45, targetCount: 5),
          ExerciseLevel(levelNumber: 2, durationInSeconds: 60, targetCount: 10),
          ExerciseLevel(levelNumber: 3, durationInSeconds: 90, targetCount: 15),
          ExerciseLevel(
            levelNumber: 4,
            durationInSeconds: 120,
            targetCount: 20,
          ),
          ExerciseLevel(
            levelNumber: 5,
            durationInSeconds: 150,
            targetCount: 25,
          ),
        ];
    }
  }
}
