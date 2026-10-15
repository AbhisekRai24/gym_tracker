import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_track/features/auth/viewmodel/auth_viewmodel.dart';

import '../models/workout.dart';
import '../repositories/workout_repository.dart';

// Depends on the signed-in uid. When the user changes, everything below
// rebuilds, so one user's workouts can never linger for the next one.
final workoutRepositoryProvider = Provider<WorkoutRepository?>((ref) {
  final uid = ref.watch(authViewModelProvider.select((s) => s.user?.uid));

  if (uid == null) return null;

  return WorkoutRepository(FirebaseFirestore.instance, uid);
});

final workoutViewModelProvider =
    StreamNotifierProvider<WorkoutViewModel, List<Workout>>(
      WorkoutViewModel.new,
    );

// Plain list for screens that only need the data. Empty while loading, on
// error, or while switching users, so stale data is never shown.
final workoutListProvider = Provider<List<Workout>>((ref) {
  final async = ref.watch(workoutViewModelProvider);

  if (async.isLoading || async.hasError) return const <Workout>[];

  return async.requireValue;
});

class WorkoutViewModel extends StreamNotifier<List<Workout>> {
  @override
  Stream<List<Workout>> build() {
    final repository = ref.watch(workoutRepositoryProvider);

    if (repository == null) return Stream.value(const <Workout>[]);

    return repository.watchWorkouts();
  }

  WorkoutRepository? get _repository => ref.read(workoutRepositoryProvider);

  void addWorkout(String name) {
    _repository?.addWorkout(
      Workout(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name),
    );
  }

  void updateWorkout(Workout workout) {
    _repository?.updateWorkout(workout);
  }

  void deleteWorkout(String workoutId) {
    _repository?.deleteWorkout(workoutId);
  }

  void addExercise(String workoutId, String exerciseName) {
    _repository?.addExerciseToWorkout(workoutId, exerciseName);
  }

  void removeExercise(String workoutId, String exerciseName) {
    _repository?.removeExerciseFromWorkout(workoutId, exerciseName);
  }

  void reorderExercises(String workoutId, List<String> exercises) {
    _repository?.setExercises(workoutId, List<String>.from(exercises));
  }
}
