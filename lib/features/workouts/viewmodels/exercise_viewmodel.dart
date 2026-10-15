import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_track/features/auth/viewmodel/auth_viewmodel.dart';

import '../models/exercise.dart';
import '../repositories/exercise_repository.dart';

// Depends on the signed-in uid. When the user changes, this provider (and
// everything below it) rebuilds, so one user's data can never linger for the
// next one. Null means nobody is signed in.
final exerciseRepositoryProvider = Provider<ExerciseRepository?>((ref) {
  final uid = ref.watch(authViewModelProvider.select((s) => s.user?.uid));

  if (uid == null) return null;

  return ExerciseRepository(FirebaseFirestore.instance, uid);
});

final exerciseViewModelProvider =
    StreamNotifierProvider<ExerciseViewModel, List<Exercise>>(
      ExerciseViewModel.new,
    );

class ExerciseViewModel extends StreamNotifier<List<Exercise>> {
  @override
  Stream<List<Exercise>> build() async* {
    final repository = ref.watch(exerciseRepositoryProvider);

    if (repository == null) {
      yield const <Exercise>[];
      return;
    }

    // Seeding finishes before the list is shown, so the user never sees a
    // flash of "No exercises yet".
    await repository.seedDefaultsIfNeeded();

    yield* repository.watchExercises();
  }

  void addExercise({
    required String name,
    required String muscleGroup,
    required String equipment,
  }) {
    ref
        .read(exerciseRepositoryProvider)
        ?.addExercise(
          Exercise(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            muscleGroup: muscleGroup,
            equipment: equipment,
          ),
        );
  }

  void updateExercise(Exercise exercise) {
    ref.read(exerciseRepositoryProvider)?.updateExercise(exercise);
  }

  void deleteExercise(String exerciseId) {
    ref.read(exerciseRepositoryProvider)?.deleteExercise(exerciseId);
  }
}
