class Workout {
  final String id;
  final String name;
  final List<String> exercises;

  const Workout({
    required this.id,
    required this.name,
    this.exercises = const [],
  });

  Workout copyWith({
    String? id,
    String? name,
    List<String>? exercises,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
    );
  }
}