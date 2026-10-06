
import 'package:hive_flutter/hive_flutter.dart';

class HiveBoxes {
  static const String workouts = 'workouts';

  static Future<Box> openWorkoutsBox() async {
    return Hive.openBox(workouts);
  }
}
