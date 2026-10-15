import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/exercise.dart';
import 'default_exercises.dart';

class ExerciseRepository {
  final FirebaseFirestore _firestore;
  final String _uid;

  ExerciseRepository(this._firestore, this._uid);

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _firestore.collection('users').doc(_uid);

  CollectionReference<Map<String, dynamic>> get _collection =>
      _userDoc.collection('exercises');

  // Live list of this user's exercises. Sorted here because Firestore does
  // not keep insertion order the way Hive did.
  Stream<List<Exercise>> watchExercises() {
    return _collection.snapshots().map((snapshot) {
      final exercises = <Exercise>[];

      for (final doc in snapshot.docs) {
        final exercise = _fromDoc(doc);
        if (exercise != null) exercises.add(exercise);
      }

      exercises.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );

      return exercises;
    });
  }

  // Writes are queued offline and synced later, so we do not wait for them.
  // A failure (for example a rules rejection) is logged, not swallowed.
  void addExercise(Exercise exercise) {
    _logFailure(
      _collection.doc(exercise.id).set({
        ..._toMap(exercise),
        'createdAt': FieldValue.serverTimestamp(),
      }),
      'add exercise',
    );
  }

  void updateExercise(Exercise exercise) {
    _logFailure(
      _collection
          .doc(exercise.id)
          .set(_toMap(exercise), SetOptions(merge: true)),
      'update exercise',
    );
  }

  void deleteExercise(String exerciseId) {
    _logFailure(_collection.doc(exerciseId).delete(), 'delete exercise');
  }

  // Gives the user the starter exercises once. Never throws: if it cannot
  // finish (offline, slow network) it is simply tried again on the next load.
  Future<void> seedDefaultsIfNeeded() async {
    try {
      await _seedDefaults().timeout(const Duration(seconds: 8));
    } catch (error) {
      debugPrint('Default exercise seeding skipped: $error');
    }
  }

  Future<void> _seedDefaults() async {
    if (await _seededAccordingToCache()) return;

    // Ask the server so a new device with an empty cache cannot bring back
    // defaults the user already deleted.
    final serverDoc = await _userDoc.get(
      const GetOptions(source: Source.server),
    );
    if (serverDoc.data()?['defaultsSeeded'] == true) return;

    final batch = _firestore.batch();

    for (final exercise in defaultExercises) {
      batch.set(_collection.doc(exercise.id), {
        ..._toMap(exercise),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    batch.set(_userDoc, {'defaultsSeeded': true}, SetOptions(merge: true));

    await batch.commit();
  }

  Future<bool> _seededAccordingToCache() async {
    try {
      final cached = await _userDoc.get(const GetOptions(source: Source.cache));
      return cached.data()?['defaultsSeeded'] == true;
    } catch (_) {
      return false;
    }
  }

  void _logFailure(Future<void> write, String action) {
    unawaited(
      write.catchError((Object error) {
        debugPrint('Failed to $action: $error');
      }),
    );
  }

  Map<String, dynamic> _toMap(Exercise exercise) {
    return {
      'name': exercise.name,
      'muscleGroup': exercise.muscleGroup,
      'equipment': exercise.equipment,
    };
  }

  // Skips malformed documents instead of crashing the whole list.
  Exercise? _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return null;

    final name = data['name'];
    final muscleGroup = data['muscleGroup'];
    final equipment = data['equipment'];

    if (name is! String || muscleGroup is! String || equipment is! String) {
      debugPrint('Skipping malformed exercise ${doc.id}');
      return null;
    }

    return Exercise(
      id: doc.id,
      name: name,
      muscleGroup: muscleGroup,
      equipment: equipment,
    );
  }
}
