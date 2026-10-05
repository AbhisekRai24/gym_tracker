import '../models/exercise.dart';

class ExerciseRepository {
  final List<Exercise> _exercises = const [
    Exercise(
      id: '1',
      name: 'Bench Press',
      muscleGroup: 'Chest',
      equipment: 'Barbell',
    ),
    Exercise(
      id: '2',
      name: 'Incline Dumbbell Press',
      muscleGroup: 'Chest',
      equipment: 'Dumbbell',
    ),
    Exercise(
      id: '3',
      name: 'Cable Fly',
      muscleGroup: 'Chest',
      equipment: 'Cable',
    ),
    Exercise(
      id: '4',
      name: 'Shoulder Press',
      muscleGroup: 'Shoulders',
      equipment: 'Dumbbell',
    ),
    Exercise(
      id: '5',
      name: 'Lateral Raise',
      muscleGroup: 'Shoulders',
      equipment: 'Dumbbell',
    ),
    Exercise(
      id: '6',
      name: 'Tricep Pushdown',
      muscleGroup: 'Triceps',
      equipment: 'Cable',
    ),
    Exercise(
      id: '7',
      name: 'Barbell Row',
      muscleGroup: 'Back',
      equipment: 'Barbell',
    ),
    Exercise(
      id: '8',
      name: 'Lat Pulldown',
      muscleGroup: 'Back',
      equipment: 'Cable',
    ),
    Exercise(
      id: '9',
      name: 'Barbell Squat',
      muscleGroup: 'Legs',
      equipment: 'Barbell',
    ),
    Exercise(
      id: '10',
      name: 'Leg Press',
      muscleGroup: 'Legs',
      equipment: 'Machine',
    ),
    Exercise(
      id: '11',
      name: 'Romanian Deadlift',
      muscleGroup: 'Legs',
      equipment: 'Barbell',
    ),
  ];

  List<Exercise> getExercises() {
    return List.unmodifiable(_exercises);
  }
}