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

  const WorkoutSession({
    required this.id,
    required this.workoutId,
    required this.date,
    this.sets = const [],
  });

  WorkoutSession copyWith({
    String? id,
    String? workoutId,
    DateTime? date,
    List<WorkoutSet>? sets,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      date: date ?? this.date,
      sets: sets ?? this.sets,
    );
  }
}