import '../models/workout.dart';

class WorkoutRepository {
  final List<Workout> _workouts = [
    const Workout(
      id: '1',
      name: 'Upper Body',
      exercises: ['Bench Press', 'Barbell Row', 'Shoulder Press'],
    ),
    const Workout(
      id: '2',
      name: 'Lower Body',
      exercises: ['Barbell Squat', 'Leg Press', 'Romanian Deadlift'],
    ),
    const Workout(
      id: '3',
      name: 'Full Body',
      exercises: ['Barbell Squat', 'Bench Press', 'Barbell Row'],
    ),
  ];

  List<Workout> getWorkouts() {
    return List.unmodifiable(_workouts);
  }

  void addWorkout(Workout workout) {
    _workouts.add(workout);
  }

  void addExerciseToWorkout(String workoutId, String exerciseName) {
    final index = _workouts.indexWhere((workout) => workout.id == workoutId);

    if (index == -1) {
      return;
    }

    final workout = _workouts[index];

    if (workout.exercises.contains(exerciseName)) {
      return;
    }

    _workouts[index] = workout.copyWith(
      exercises: [...workout.exercises, exerciseName],
    );
  }

  void removeExerciseFromWorkout(String workoutId, String exerciseName) {
    final index = _workouts.indexWhere((workout) => workout.id == workoutId);

    if (index == -1) {
      return;
    }

    final workout = _workouts[index];

    _workouts[index] = workout.copyWith(
      exercises: workout.exercises
          .where((exercise) => exercise != exerciseName)
          .toList(),
    );
  }
}
