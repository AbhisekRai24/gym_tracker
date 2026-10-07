import 'package:hive_flutter/hive_flutter.dart';

class HiveBoxes {
  static const String workouts = 'workouts';
  static const String workoutSessions = 'workout_sessions';
  static const String exercises = 'exercises';
  static const String profile = 'profile';

  static Future<Box> openWorkoutsBox() async {
    return Hive.openBox(workouts);
  }

  static Future<Box> openWorkoutSessionsBox() async {
    return Hive.openBox(workoutSessions);
  }

  static Future<Box> openExercisesBox() async {
    return Hive.openBox(exercises);
  }

  static Future<Box> openProfileBox() async {
    return Hive.openBox(profile);
  }
}
