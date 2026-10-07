class WeeklySchedule {
  final Map<int, String?> workoutsByDay;

  const WeeklySchedule({
    required this.workoutsByDay,
  });

  String? workoutForDay(int day) {
    return workoutsByDay[day];
  }

  WeeklySchedule copyWith({
    Map<int, String?>? workoutsByDay,
  }) {
    return WeeklySchedule(
      workoutsByDay: workoutsByDay ?? this.workoutsByDay,
    );
  }
}