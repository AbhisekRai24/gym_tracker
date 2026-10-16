import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/weekly_schedule.dart';

class WeeklyScheduleRepository {
  final FirebaseFirestore _firestore;
  final String _uid;

  WeeklyScheduleRepository(this._firestore, this._uid);

  DocumentReference<Map<String, dynamic>> get _doc => _firestore
      .collection('users')
      .doc(_uid)
      .collection('planner')
      .doc('schedule');

  Stream<WeeklySchedule> watchSchedule() {
    return _doc.snapshots().map((snapshot) => _fromData(snapshot.data()));
  }

  // Tolerates a missing or malformed document: every day falls back to rest.
  WeeklySchedule _fromData(Map<String, dynamic>? data) {
    final rawDays = data?['days'];
    final schedule = <int, String?>{};

    for (var day = 0; day < 7; day++) {
      final value = rawDays is Map ? rawDays[day.toString()] : null;
      schedule[day] = (value is String && value.isNotEmpty) ? value : null;
    }

    return WeeklySchedule(workoutsByDay: schedule);
  }

  // One merged write covers any number of days, so a swap is atomic. The
  // write is queued offline and synced later; a failure is logged, not
  // swallowed.
  void saveDays(Map<int, String?> changes) {
    if (changes.isEmpty) return;

    final days = <String, String?>{
      for (final entry in changes.entries) entry.key.toString(): entry.value,
    };

    unawaited(
      _doc.set({'days': days}, SetOptions(merge: true)).catchError((
        Object error,
      ) {
        debugPrint('Failed to save planner: $error');
      }),
    );
  }
}
