import '../models/exercise.dart';

// Fixed IDs mean a retried seed overwrites the same documents instead of
// creating duplicates.
const List<Exercise> defaultExercises = [
  Exercise(
    id: 'default_bench_press',
    name: 'Bench Press',
    muscleGroup: 'Chest',
    equipment: 'Barbell',
  ),
  Exercise(
    id: 'default_barbell_row',
    name: 'Barbell Row',
    muscleGroup: 'Back',
    equipment: 'Barbell',
  ),
  Exercise(
    id: 'default_shoulder_press',
    name: 'Shoulder Press',
    muscleGroup: 'Shoulders',
    equipment: 'Dumbbell',
  ),
  Exercise(
    id: 'default_barbell_squat',
    name: 'Barbell Squat',
    muscleGroup: 'Legs',
    equipment: 'Barbell',
  ),
  Exercise(
    id: 'default_leg_press',
    name: 'Leg Press',
    muscleGroup: 'Legs',
    equipment: 'Machine',
  ),
  Exercise(
    id: 'default_romanian_deadlift',
    name: 'Romanian Deadlift',
    muscleGroup: 'Legs',
    equipment: 'Barbell',
  ),
  Exercise(
    id: 'default_lat_pulldown',
    name: 'Lat Pulldown',
    muscleGroup: 'Back',
    equipment: 'Cable',
  ),
  Exercise(
    id: 'default_bicep_curl',
    name: 'Bicep Curl',
    muscleGroup: 'Biceps',
    equipment: 'Dumbbell',
  ),
  Exercise(
    id: 'default_tricep_pushdown',
    name: 'Tricep Pushdown',
    muscleGroup: 'Triceps',
    equipment: 'Cable',
  ),
  Exercise(
    id: 'default_plank',
    name: 'Plank',
    muscleGroup: 'Core',
    equipment: 'Bodyweight',
  ),
];
