import 'package:hive_flutter/hive_flutter.dart';

class HiveBoxes {
  static const String workouts = 'workouts';
  static const String workoutSessions = 'workout_sessions';

  static Future<Box> openWorkoutsBox() async {
    return Hive.openBox(workouts);
  }

  static Future<Box> openWorkoutSessionsBox() async {
    return Hive.openBox(workoutSessions);
  }
}
