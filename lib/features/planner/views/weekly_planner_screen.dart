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

          final matchingWorkouts = workouts.where(
            (workout) => workout.id == workoutId,
          );

          final workout = matchingWorkouts.isEmpty
              ? null
              : matchingWorkouts.first;

          return DragTarget<int>(
            onAcceptWithDetails: (details) async {
              final draggedDay = details.data;

              if (draggedDay == index) {
                return;
              }

              await ref
                  .read(weeklyScheduleViewModelProvider.notifier)
                  .swapDays(draggedDay, index);
            },
            builder: (context, candidateData, rejectedData) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: candidateData.isNotEmpty
                    ? Colors.green.withValues(alpha: 0.15)
                    : null,
                child: ListTile(
                  title: Text(
                    dayNames[index],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(workout?.name ?? 'Rest Day'),
                  trailing: workout == null
                      ? null
                      : Draggable<int>(
                          data: index,
                          feedback: Material(
                            color: Colors.transparent,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.fitness_center),
                                    const SizedBox(width: 8),
                                    Text(workout.name),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          childWhenDragging: const Icon(
                            Icons.drag_handle,
                            color: Colors.grey,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.drag_handle),
                          ),
                        ),
                  onTap: () {
                    _showWorkoutPicker(context, ref, index, workouts);
                  },
                ),
              );
            },
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
