import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_track/features/planner/repositories/weekly_schedule_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_boxes.dart';
import '../models/weekly_schedule.dart';

final weeklyScheduleRepositoryProvider = Provider<WeeklyScheduleRepository>((
  ref,
) {
  final box = Hive.box(HiveBoxes.planner);

  return WeeklyScheduleRepository(box);
});

final weeklyScheduleViewModelProvider =
    NotifierProvider<WeeklyScheduleViewModel, WeeklySchedule>(
      WeeklyScheduleViewModel.new,
    );

class WeeklyScheduleViewModel extends Notifier<WeeklySchedule> {
  late final WeeklyScheduleRepository _repository;

  @override
  WeeklySchedule build() {
    _repository = ref.watch(weeklyScheduleRepositoryProvider);

    return _repository.getSchedule();
  }

  Future<void> assignWorkout(int day, String? workoutId) async {
    await _repository.assignWorkout(day, workoutId);

    state = _repository.getSchedule();
  }

  Future<void> clearDay(int day) async {
    await _repository.clearDay(day);

    state = _repository.getSchedule();
  }
}
