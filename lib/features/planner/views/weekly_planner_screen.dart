import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_track/features/planner/viewmodels/weekly_schedule_viewmodel.dart';
import 'package:gym_track/features/workouts/viewmodels/workout_viewmodel.dart';

class WeeklyPlannerScreen extends ConsumerWidget {
  const WeeklyPlannerScreen({super.key});

  static const dayNames = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = ref.watch(weeklyScheduleViewModelProvider);

    final workouts = ref.watch(workoutViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Planner')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dayNames.length,
        itemBuilder: (context, index) {
          final workoutId = schedule.workoutForDay(index);

          final workout = workoutId == null
              ? null
              : workouts.firstWhere(
                  (workout) => workout.id == workoutId,
                  orElse: () => workouts.first,
                );

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(
                dayNames[index],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(workout?.name ?? 'Rest Day'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showWorkoutPicker(context, ref, index, workouts);
              },
            ),
          );
        },
      ),
    );
  }

  void _showWorkoutPicker(
    BuildContext context,
    WidgetRef ref,
    int day,
    List workouts,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Choose Workout',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.bed_outlined),
                title: const Text('Rest Day'),
                onTap: () {
                  ref
                      .read(weeklyScheduleViewModelProvider.notifier)
                      .clearDay(day);

                  Navigator.pop(context);
                },
              ),

              ...workouts.map((workout) {
                return ListTile(
                  leading: const Icon(Icons.fitness_center),
                  title: Text(workout.name),
                  onTap: () {
                    ref
                        .read(weeklyScheduleViewModelProvider.notifier)
                        .assignWorkout(day, workout.id);

                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
