import '../../workouts/models/workout_session.dart';
import '../models/exercise_progress.dart';

class ProgressRepository {
  List<ExerciseProgress> getExerciseProgress(
    List<WorkoutSession> sessions,
  ) {
    final progress = <ExerciseProgress>[];

    for (final session in sessions) {
      for (final set in session.sets) {
        progress.add(
          ExerciseProgress(
            exerciseName: set.exerciseName,
            weight: set.weight,
            reps: set.reps,
            date: session.date,
          ),
        );
      }
    }

    return progress;
  }
}