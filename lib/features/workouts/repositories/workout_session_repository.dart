import '../models/workout_session.dart';

class WorkoutSessionRepository {
  final List<WorkoutSession> _sessions = [];

  List<WorkoutSession> getSessions() {
    return List.unmodifiable(_sessions);
  }

  void addSession(WorkoutSession session) {
    _sessions.add(session);
  }
}