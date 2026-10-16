import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_track/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:gym_track/features/planner/repositories/weekly_schedule_repository.dart';

import '../models/weekly_schedule.dart';

final _emptySchedule = WeeklySchedule(
  workoutsByDay: {for (var day = 0; day < 7; day++) day: null},
);

// Depends on the signed-in uid. When the user changes, everything below
// rebuilds, so one user's plan can never linger for the next one.
final weeklyScheduleRepositoryProvider = Provider<WeeklyScheduleRepository?>((
  ref,
) {
  final uid = ref.watch(authViewModelProvider.select((s) => s.user?.uid));

  if (uid == null) return null;

  return WeeklyScheduleRepository(FirebaseFirestore.instance, uid);
});

final weeklyScheduleViewModelProvider =
    StreamNotifierProvider<WeeklyScheduleViewModel, WeeklySchedule>(
      WeeklyScheduleViewModel.new,
    );

// Plain schedule for screens that only need the data. All rest days while
// loading, on error, or while switching users, so stale data is never shown.
final weeklyScheduleProvider = Provider<WeeklySchedule>((ref) {
  final async = ref.watch(weeklyScheduleViewModelProvider);

  if (async.isLoading || async.hasError) return _emptySchedule;

  return async.requireValue;
});

class WeeklyScheduleViewModel extends StreamNotifier<WeeklySchedule> {
  @override
  Stream<WeeklySchedule> build() {
    final repository = ref.watch(weeklyScheduleRepositoryProvider);

    if (repository == null) return Stream.value(_emptySchedule);

    return repository.watchSchedule();
  }

  WeeklyScheduleRepository? get _repository =>
      ref.read(weeklyScheduleRepositoryProvider);

  // Swaps and removals are computed from the loaded schedule. If it has not
  // loaded yet we do nothing, so we can never overwrite the plan with blanks.
  bool get _isReady => !state.isLoading && !state.hasError;

  Future<void> assignWorkout(int day, String? workoutId) async {
    _repository?.saveDays({day: workoutId});
  }

  Future<void> clearDay(int day) async {
    _repository?.saveDays({day: null});
  }

  Future<void> swapDays(int firstDay, int secondDay) async {
    if (!_isReady) return;

    final current = ref.read(weeklyScheduleProvider);

    _repository?.saveDays({
      firstDay: current.workoutForDay(secondDay),
      secondDay: current.workoutForDay(firstDay),
    });
  }

  Future<void> removeWorkout(String workoutId) async {
    if (!_isReady) return;

    final current = ref.read(weeklyScheduleProvider);
    final changes = <int, String?>{};

    for (var day = 0; day < 7; day++) {
      if (current.workoutForDay(day) == workoutId) changes[day] = null;
    }

    _repository?.saveDays(changes);
  }
}
