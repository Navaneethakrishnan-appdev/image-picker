import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExerciseCalendarScreen extends StatefulWidget {
  const ExerciseCalendarScreen({super.key});

  @override
  State<ExerciseCalendarScreen> createState() => _ExerciseCalendarScreenState();
}

class _ExerciseCalendarScreenState extends State<ExerciseCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final DateTime _firstDay = DateTime.utc(2024, 1, 1);
  final DateTime _lastDay = DateTime.utc(2030, 12, 31);
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _events = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    if (now.isBefore(_firstDay)) {
      _focusedDay = _firstDay;
    } else if (now.isAfter(_lastDay)) {
      _focusedDay = _lastDay;
    } else {
      _focusedDay = now;
    }
    _loadExerciseData();
  }

  Future<void> _loadExerciseData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user logged in');
        return;
      }

      // Get all completed levels for the user
      final completedLevelsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('completed_levels')
          .get();

      Map<DateTime, List<String>> tempEvents = {};

      for (var doc in completedLevelsSnapshot.docs) {
        final data = doc.data();
        final exerciseTitle = doc.id;
        final completedLevels = data['completedLevels'] as List<dynamic>? ?? [];
        final lastUpdated = data['lastUpdated'] as Timestamp?;

        if (lastUpdated != null && completedLevels.isNotEmpty) {
          final date = lastUpdated.toDate();
          final normalizedDate = DateTime.utc(date.year, date.month, date.day);
          
          final exerciseInfo = '$exerciseTitle (Levels: ${completedLevels.join(', ')})';
          
          if (tempEvents.containsKey(normalizedDate)) {
            tempEvents[normalizedDate]!.add(exerciseInfo);
          } else {
            tempEvents[normalizedDate] = [exerciseInfo];
          }
        }
      }

      setState(() {
        _events = tempEvents;
        _isLoading = false;
      });

      print('✅Loaded ${_events.length} days with completed exercises');
    } catch (e) {
      print('❌Error loading exercise data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffAA60C8),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.navigate_before, size: 35, color: Colors.white),
        ),
        title: Text(
          'Exercise Calendar',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadExerciseData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xffAA60C8),
              ),
            )
          : Column(
              children: [
                TableCalendar(
                  firstDay: _firstDay,
                  lastDay: _lastDay,
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  eventLoader: (day) {
                    final normalizedDay = DateTime.utc(day.year, day.month, day.day);
                    return _events[normalizedDay] ?? [];
                  },
                  calendarStyle: CalendarStyle(
                    markersMaxCount: 1,
                    markerDecoration: BoxDecoration(
                      color: Color(0xffAA60C8),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Expanded(
                  child: _selectedDay == null
                      ? Center(
                          child: Text(
                            'Select a day to view completed exercises',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _events[DateTime.utc(
                                    _selectedDay!.year,
                                    _selectedDay!.month,
                                    _selectedDay!.day,
                                  )]
                                  ?.length ??
                              0,
                          itemBuilder: (context, index) {
                            final normalizedSelectedDay = DateTime.utc(
                              _selectedDay!.year,
                              _selectedDay!.month,
                              _selectedDay!.day,
                            );
                            return ListTile(
                              leading: Icon(
                                Icons.check_circle,
                                color: Color(0xffAA60C8),
                              ),
                              title: Text(
                                _events[normalizedSelectedDay]![index],
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
} 