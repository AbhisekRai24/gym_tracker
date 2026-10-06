import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/workout.dart';
import '../repositories/workout_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_boxes.dart';

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final box = Hive.box(HiveBoxes.workouts);

  return WorkoutRepository(box);
});

final workoutViewModelProvider =
    NotifierProvider<WorkoutViewModel, List<Workout>>(WorkoutViewModel.new);

class WorkoutViewModel extends Notifier<List<Workout>> {
  late final WorkoutRepository _repository;

  @override
  List<Workout> build() {
    _repository = ref.watch(workoutRepositoryProvider);

    return _repository.getWorkouts();
  }

  void addWorkout(String name) {
    final workout = Workout(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );

    _repository.addWorkout(workout);

    state = _repository.getWorkouts();
  }

  void updateWorkout(Workout workout) {
    _repository.updateWorkout(workout);

    state = _repository.getWorkouts();
  }

  void deleteWorkout(String workoutId) {
    _repository.deleteWorkout(workoutId);

    state = _repository.getWorkouts();
  }

  void addExercise(String workoutId, String exerciseName) {
    _repository.addExerciseToWorkout(workoutId, exerciseName);

    state = _repository.getWorkouts();
  }

  void removeExercise(String workoutId, String exerciseName) {
    _repository.removeExerciseFromWorkout(workoutId, exerciseName);

    state = _repository.getWorkouts();
  }
}
