import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_track/features/auth/viewmodel/auth_viewmodel.dart';

import '../models/workout_session.dart';
import '../repositories/workout_session_repository.dart';

// Depends on the signed-in uid. When the user changes, everything below
// rebuilds, so one user's history can never linger for the next one.
final workoutSessionRepositoryProvider = Provider<WorkoutSessionRepository?>((
  ref,
) {
  final uid = ref.watch(authViewModelProvider.select((s) => s.user?.uid));

  if (uid == null) return null;

  return WorkoutSessionRepository(FirebaseFirestore.instance, uid);
});

final workoutSessionViewModelProvider =
    StreamNotifierProvider<WorkoutSessionViewModel, List<WorkoutSession>>(
      WorkoutSessionViewModel.new,
    );

// Plain list for screens that only need the data. Empty while loading, on
// error, or while switching users, so stale data is never shown.
final workoutSessionListProvider = Provider<List<WorkoutSession>>((ref) {
  final async = ref.watch(workoutSessionViewModelProvider);

  if (async.isLoading || async.hasError) return const <WorkoutSession>[];

  return async.requireValue;
});

class WorkoutSessionViewModel extends StreamNotifier<List<WorkoutSession>> {
  @override
  Stream<List<WorkoutSession>> build() {
    final repository = ref.watch(workoutSessionRepositoryProvider);

    if (repository == null) return Stream.value(const <WorkoutSession>[]);

    return repository.watchSessions();
  }

  void addSession(WorkoutSession session) {
    ref.read(workoutSessionRepositoryProvider)?.addSession(session);
  }
}
