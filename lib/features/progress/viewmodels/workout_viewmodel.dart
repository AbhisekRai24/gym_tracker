import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/workout.dart';
import '../repositories/workout_repository.dart';

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository();
});

final workoutViewModelProvider =
    NotifierProvider<WorkoutViewModel, List<Workout>>(
  WorkoutViewModel.new,
);

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

  void addExercise(
    String workoutId,
    String exerciseName,
  ) {
    _repository.addExerciseToWorkout(
      workoutId,
      exerciseName,
    );

    state = _repository.getWorkouts();
  }
}