import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_boxes.dart';
import '../models/weekly_schedule.dart';

class WeeklyScheduleRepository {
  final Box _box;

  WeeklyScheduleRepository(this._box);

  WeeklySchedule getSchedule() {
    final schedule = <int, String?>{};

    for (int day = 0; day < 7; day++) {
      schedule[day] = _box.get(day.toString());
    }

    return WeeklySchedule(workoutsByDay: schedule);
  }

  Future<void> assignWorkout(int day, String? workoutId) async {
    await _box.put(day.toString(), workoutId);
  }

  Future<void> clearDay(int day) async {
    await _box.delete(day.toString());
  }

  Future<void> swapDays(int firstDay, int secondDay) async {
    final firstWorkout = _box.get(firstDay.toString());
    final secondWorkout = _box.get(secondDay.toString());

    if (secondWorkout == null) {
      await _box.delete(firstDay.toString());
    } else {
      await _box.put(firstDay.toString(), secondWorkout);
    }

    if (firstWorkout == null) {
      await _box.delete(secondDay.toString());
    } else {
      await _box.put(secondDay.toString(), firstWorkout);
    }
  }
}
