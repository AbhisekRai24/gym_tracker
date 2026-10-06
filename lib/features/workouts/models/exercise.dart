class Exercise {
  final String id;
  final String name;
  final String muscleGroup;
  final String equipment;

  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'].toString(),
      name: json['name'] as String,
      muscleGroup: json['muscleGroup'] as String,
      equipment: json['equipment'] as String,
    );
  }

  static List<Exercise> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => Exercise.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
