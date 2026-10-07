class WorkoutSet {
  final String exerciseName;
  final double weight;
  final int reps;

  const WorkoutSet({
    required this.exerciseName,
    required this.weight,
    required this.reps,
  });
}

class WorkoutSession {
  final String id;
  final String workoutId;
  final DateTime date;
  final List<WorkoutSet> sets;
  final Duration duration;

  const WorkoutSession({
    required this.id,
    required this.workoutId,
    required this.date,
    this.sets = const [],
    this.duration = Duration.zero,
  });

  WorkoutSession copyWith({
    String? id,
    String? workoutId,
    DateTime? date,
    List<WorkoutSet>? sets,
    Duration? duration,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      date: date ?? this.date,
      sets: sets ?? this.sets,
      duration: duration ?? this.duration,
    );
  }
}