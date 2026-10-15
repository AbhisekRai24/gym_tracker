import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/workout.dart';

class WorkoutRepository {
  final FirebaseFirestore _firestore;
  final String _uid;

  WorkoutRepository(this._firestore, this._uid);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users').doc(_uid).collection('workouts');

  // Sorted by id (a millisecond timestamp), oldest first, like Hive was.
  Stream<List<Workout>> watchWorkouts() {
    return _collection.snapshots().map((snapshot) {
      final workouts = <Workout>[];

      for (final doc in snapshot.docs) {
        final workout = _fromDoc(doc);
        if (workout != null) workouts.add(workout);
      }

      workouts.sort((a, b) {
        final byId = (int.tryParse(a.id) ?? 0).compareTo(
          int.tryParse(b.id) ?? 0,
        );
        if (byId != 0) return byId;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      return workouts;
    });
  }

  // Writes are queued offline and synced later, so we do not wait for them.
  // A failure is logged, not swallowed.
  void addWorkout(Workout workout) {
    _logFailure(
      _collection.doc(workout.id).set({
        'name': workout.name,
        'exercises': workout.exercises,
        'createdAt': FieldValue.serverTimestamp(),
      }),
      'add workout',
    );
  }

  void updateWorkout(Workout workout) {
    _logFailure(
      _collection.doc(workout.id).set({
        'name': workout.name,
        'exercises': workout.exercises,
      }, SetOptions(merge: true)),
      'update workout',
    );
  }

  void deleteWorkout(String workoutId) {
    _logFailure(_collection.doc(workoutId).delete(), 'delete workout');
  }

  // arrayUnion never adds the same exercise twice, even if a write is retried.
  void addExerciseToWorkout(String workoutId, String exerciseName) {
    _logFailure(
      _collection.doc(workoutId).update({
        'exercises': FieldValue.arrayUnion([exerciseName]),
      }),
      'add exercise to workout',
    );
  }

  void removeExerciseFromWorkout(String workoutId, String exerciseName) {
    _logFailure(
      _collection.doc(workoutId).update({
        'exercises': FieldValue.arrayRemove([exerciseName]),
      }),
      'remove exercise from workout',
    );
  }

  void setExercises(String workoutId, List<String> exercises) {
    _logFailure(
      _collection.doc(workoutId).update({'exercises': exercises}),
      'reorder exercises',
    );
  }

  void _logFailure(Future<void> write, String action) {
    unawaited(
      write.catchError((Object error) {
        debugPrint('Failed to $action: $error');
      }),
    );
  }

  // Skips malformed documents instead of crashing the whole list.
  Workout? _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return null;

    final name = data['name'];
    final exercises = data['exercises'];

    if (name is! String || exercises is! List) {
      debugPrint('Skipping malformed workout ${doc.id}');
      return null;
    }

    return Workout(
      id: doc.id,
      name: name,
      exercises: exercises.whereType<String>().toList(),
    );
  }
}
