import '../models/workout.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_boxes.dart';

class WorkoutRepository {
  final Box _box;

  WorkoutRepository(this._box);

  List<Workout> getWorkouts() {
    if (_box.isEmpty) {
      _seedInitialWorkouts();
    }

    return _box.values.map(_fromMap).toList();
  }

  void addWorkout(Workout workout) {
    _box.put(workout.id, _toMap(workout));
  }

  void addExerciseToWorkout(String workoutId, String exerciseName) {
    final workout = _findWorkout(workoutId);

    if (workout == null) return;
    if (workout.exercises.contains(exerciseName)) return;

    final updatedWorkout = workout.copyWith(
      exercises: [...workout.exercises, exerciseName],
    );

    _box.put(
      workoutId,
      _toMap(updatedWorkout),
    );
  }

  void removeExerciseFromWorkout(
    String workoutId,
    String exerciseName,
  ) {
    final workout = _findWorkout(workoutId);

    if (workout == null) return;

    final updatedWorkout = workout.copyWith(
      exercises: workout.exercises
          .where((exercise) => exercise != exerciseName)
          .toList(),
    );

    _box.put(
      workoutId,
      _toMap(updatedWorkout),
    );
  }

  Workout? _findWorkout(String workoutId) {
    final data = _box.get(workoutId);

    if (data == null) return null;

    return _fromMap(data);
  }

  Map<String, dynamic> _toMap(Workout workout) {
    return {
      'id': workout.id,
      'name': workout.name,
      'exercises': workout.exercises,
    };
  }

  Workout _fromMap(dynamic data) {
    final map = Map<String, dynamic>.from(data as Map);

    return Workout(
      id: map['id'] as String,
      name: map['name'] as String,
      exercises: List<String>.from(map['exercises'] as List),
    );
  }

  void _seedInitialWorkouts() {
    const workouts = [
      Workout(
        id: '1',
        name: 'Upper Body',
        exercises: [
          'Bench Press',
          'Barbell Row',
          'Shoulder Press',
        ],
      ),
      Workout(
        id: '2',
        name: 'Lower Body',
        exercises: [
          'Barbell Squat',
          'Leg Press',
          'Romanian Deadlift',
        ],
      ),
      Workout(
        id: '3',
        name: 'Full Body',
        exercises: [
          'Barbell Squat',
          'Bench Press',
          'Barbell Row',
        ],
      ),
    ];

    for (final workout in workouts) {
      _box.put(
        workout.id,
        _toMap(workout),
      );
    }
  }
}