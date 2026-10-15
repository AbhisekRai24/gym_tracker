import 'package:flutter_test/flutter_test.dart';
import 'package:gym_track/features/planner/models/weekly_schedule.dart';
import 'package:gym_track/features/progress/repositories/progress_repository.dart';
import 'package:gym_track/features/workouts/models/workout.dart';
import 'package:gym_track/features/workouts/models/workout_session.dart';

void main() {
  group('WeeklySchedule', () {
    test('returns the workout assigned to a day', () {
      const schedule = WeeklySchedule(workoutsByDay: {0: 'a', 1: null, 2: 'b'});

      expect(schedule.workoutForDay(0), 'a');
      expect(schedule.workoutForDay(1), isNull);
      expect(schedule.workoutForDay(2), 'b');
    });

    test('copyWith replaces the map without changing the original', () {
      const original = WeeklySchedule(workoutsByDay: {0: 'a'});
      final changed = original.copyWith(workoutsByDay: {0: 'b'});

      expect(original.workoutForDay(0), 'a');
      expect(changed.workoutForDay(0), 'b');
    });
  });

  group('Workout', () {
    test('copyWith keeps unchanged fields', () {
      const workout = Workout(id: '1', name: 'Push', exercises: ['Bench']);
      final renamed = workout.copyWith(name: 'Pull');

      expect(renamed.id, '1');
      expect(renamed.name, 'Pull');
      expect(renamed.exercises, ['Bench']);
    });
  });

  group('ProgressRepository', () {
    test('flattens every set of every session into progress records', () {
      final sessions = [
        WorkoutSession(
          id: 's1',
          workoutId: 'w1',
          date: DateTime(2026, 1, 1),
          sets: const [
            WorkoutSet(exerciseName: 'Bench Press', weight: 60, reps: 8),
            WorkoutSet(exerciseName: 'Bench Press', weight: 65, reps: 6),
          ],
        ),
        WorkoutSession(
          id: 's2',
          workoutId: 'w1',
          date: DateTime(2026, 1, 8),
          sets: const [
            WorkoutSet(exerciseName: 'Barbell Row', weight: 50, reps: 10),
          ],
        ),
      ];

      final progress = ProgressRepository().getExerciseProgress(sessions);

      expect(progress.length, 3);
      expect(progress.first.exerciseName, 'Bench Press');
      expect(progress.first.date, DateTime(2026, 1, 1));
      expect(progress.last.exerciseName, 'Barbell Row');
      expect(progress.last.weight, 50);
    });

    test('returns an empty list when there are no sessions', () {
      expect(ProgressRepository().getExerciseProgress(const []), isEmpty);
    });
  });
}
