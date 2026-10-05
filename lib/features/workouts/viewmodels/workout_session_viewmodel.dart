import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/workout_session.dart';
import '../repositories/workout_session_repository.dart';

final workoutSessionRepositoryProvider =
    Provider<WorkoutSessionRepository>((ref) {
  return WorkoutSessionRepository();
});

final workoutSessionViewModelProvider =
    NotifierProvider<WorkoutSessionViewModel, List<WorkoutSession>>(
  WorkoutSessionViewModel.new,
);

class WorkoutSessionViewModel
    extends Notifier<List<WorkoutSession>> {
  late final WorkoutSessionRepository _repository;

  @override
  List<WorkoutSession> build() {
    _repository = ref.watch(workoutSessionRepositoryProvider);

    return _repository.getSessions();
  }

  void addSession(WorkoutSession session) {
    _repository.addSession(session);

    state = _repository.getSessions();
  }
}