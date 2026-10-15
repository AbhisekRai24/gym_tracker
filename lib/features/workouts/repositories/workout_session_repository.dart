import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/workout_session.dart';

class WorkoutSessionRepository {
  final FirebaseFirestore _firestore;
  final String _uid;

  WorkoutSessionRepository(this._firestore, this._uid);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users').doc(_uid).collection('workoutSessions');

  // Sorted oldest first, like the Hive version. Screens use .reversed to
  // show the newest first.
  Stream<List<WorkoutSession>> watchSessions() {
    return _collection.snapshots().map((snapshot) {
      final sessions = <WorkoutSession>[];

      for (final doc in snapshot.docs) {
        final session = _fromDoc(doc);
        if (session != null) sessions.add(session);
      }

      sessions.sort((a, b) {
        final byDate = a.date.compareTo(b.date);
        if (byDate != 0) return byDate;
        return a.id.compareTo(b.id);
      });

      return sessions;
    });
  }

  // The session id is the document id, so a retried write overwrites the
  // same document instead of creating a duplicate. The write is queued
  // offline and synced later; a failure is logged, not swallowed.
  void addSession(WorkoutSession session) {
    unawaited(
      _collection
          .doc(session.id)
          .set({
            'workoutId': session.workoutId,
            'date': Timestamp.fromDate(session.date),
            'durationMs': session.duration.inMilliseconds,
            'sets': session.sets
                .map(
                  (set) => {
                    'exerciseName': set.exerciseName,
                    'weight': set.weight,
                    'reps': set.reps,
                  },
                )
                .toList(),
            'createdAt': FieldValue.serverTimestamp(),
          })
          .catchError((Object error) {
            debugPrint('Failed to save session: $error');
          }),
    );
  }

  // Skips malformed documents instead of crashing the whole list.
  WorkoutSession? _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return null;

    final workoutId = data['workoutId'];
    final rawSets = data['sets'];
    final rawDate = data['date'];

    DateTime? date;
    if (rawDate is Timestamp) {
      date = rawDate.toDate();
    } else if (rawDate is String) {
      date = DateTime.tryParse(rawDate);
    }

    if (workoutId is! String || rawSets is! List || date == null) {
      debugPrint('Skipping malformed session ${doc.id}');
      return null;
    }

    final sets = <WorkoutSet>[];

    for (final item in rawSets) {
      if (item is! Map) continue;

      final exerciseName = item['exerciseName'];
      final weight = item['weight'];
      final reps = item['reps'];

      if (exerciseName is! String || weight is! num || reps is! num) continue;

      sets.add(
        WorkoutSet(
          exerciseName: exerciseName,
          weight: weight.toDouble(),
          reps: reps.toInt(),
        ),
      );
    }

    final durationMs = (data['durationMs'] as num?)?.toInt() ?? 0;

    return WorkoutSession(
      id: doc.id,
      workoutId: workoutId,
      date: date,
      duration: Duration(milliseconds: durationMs),
      sets: sets,
    );
  }
}