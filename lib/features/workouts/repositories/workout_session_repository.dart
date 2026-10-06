import 'package:hive_flutter/hive_flutter.dart';


import '../models/workout_session.dart';

class WorkoutSessionRepository {
  final Box _box;

  WorkoutSessionRepository(this._box);

  List<WorkoutSession> getSessions() {
    return _box.values.map(_fromMap).toList();
  }

  void addSession(WorkoutSession session) {
    _box.put(session.id, _toMap(session));
  }

  Map<String, dynamic> _toMap(WorkoutSession session) {
    return {
      'id': session.id,
      'workoutId': session.workoutId,
      'date': session.date.toIso8601String(),
      'sets': session.sets.map((set) {
        return {
          'exerciseName': set.exerciseName,
          'weight': set.weight,
          'reps': set.reps,
        };
      }).toList(),
    };
  }

  WorkoutSession _fromMap(dynamic data) {
    final map = Map<String, dynamic>.from(data as Map);

    final sets = (map['sets'] as List).map((setData) {
      final set = Map<String, dynamic>.from(setData as Map);

      return WorkoutSet(
        exerciseName: set['exerciseName'] as String,
        weight: (set['weight'] as num).toDouble(),
        reps: (set['reps'] as num).toInt(),
      );
    }).toList();

    return WorkoutSession(
      id: map['id'] as String,
      workoutId: map['workoutId'] as String,
      date: DateTime.parse(map['date'] as String),
      sets: sets,
    );
  }
}
