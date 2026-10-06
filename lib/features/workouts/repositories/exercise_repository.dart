import 'package:hive_flutter/hive_flutter.dart';

import '../models/exercise.dart';

class ExerciseRepository {
  final Box _box;

  ExerciseRepository(this._box);

  List<Exercise> getExercises() {
    return _box.values.map(_fromMap).toList();
  }

  void addExercise(Exercise exercise) {
    _box.put(
      exercise.id,
      _toMap(exercise),
    );
  }

  void updateExercise(Exercise exercise) {
    _box.put(
      exercise.id,
      _toMap(exercise),
    );
  }

  void deleteExercise(String exerciseId) {
    _box.delete(exerciseId);
  }

  Map<String, dynamic> _toMap(Exercise exercise) {
    return {
      'id': exercise.id,
      'name': exercise.name,
      'muscleGroup': exercise.muscleGroup,
      'equipment': exercise.equipment,
    };
  }

  Exercise _fromMap(dynamic data) {
    final map = Map<String, dynamic>.from(data as Map);

    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      muscleGroup: map['muscleGroup'] as String,
      equipment: map['equipment'] as String,
    );
  }
}