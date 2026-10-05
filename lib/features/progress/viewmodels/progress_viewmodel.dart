import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../workouts/viewmodels/workout_session_viewmodel.dart';
import '../models/exercise_progress.dart';
import '../repositories/progress_repository.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository();
});

final progressViewModelProvider =
    NotifierProvider<ProgressViewModel, List<ExerciseProgress>>(
      ProgressViewModel.new,
    );

class ProgressViewModel extends Notifier<List<ExerciseProgress>> {
  @override
  List<ExerciseProgress> build() {
    final repository = ref.watch(progressRepositoryProvider);
    final sessions = ref.watch(workoutSessionViewModelProvider);

    return repository.getExerciseProgress(sessions);
  }

  Map<String, ExerciseProgress> bestPerformance() {
    final best = <String, ExerciseProgress>{};

    for (final item in state) {
      final currentBest = best[item.exerciseName];

      if (currentBest == null || item.weight > currentBest.weight) {
        best[item.exerciseName] = item;
      }
    }

    return best;
  }
}
