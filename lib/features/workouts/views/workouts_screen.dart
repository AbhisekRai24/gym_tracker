import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_track/core/widgets/app_feedback.dart';
import 'package:gym_track/features/planner/viewmodels/weekly_schedule_viewmodel.dart';

import 'package:gym_track/features/workouts/viewmodels/workout_viewmodel.dart';
import 'package:gym_track/features/workouts/widgets/workout_card.dart';
import 'package:gym_track/features/workouts/views/create_workout_screen.dart';
import 'edit_workout_screen.dart';

import '../models/workout.dart';
import 'workout_history_screen.dart';

class WorkoutsScreen extends ConsumerWidget {
  const WorkoutsScreen({super.key});

  Future<void> _createWorkout(BuildContext context, WidgetRef ref) async {
    final workoutName = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const CreateWorkoutScreen()),
    );

    if (workoutName != null) {
      ref.read(workoutViewModelProvider.notifier).addWorkout(workoutName);
    }
  }

  void _editWorkout(BuildContext context, Workout workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditWorkoutScreen(workout: workout),
      ),
    );
  }

  Future<void> _deleteWorkout(
    BuildContext context,
    WidgetRef ref,
    Workout workout,
  ) async {
    final shouldDelete = await AppFeedback.confirm(
      context,
      title: 'Delete Workout?',
      message: 'Are you sure you want to delete "${workout.name}"?',
      confirmText: 'Delete',
      destructive: true,
    );

    if (!shouldDelete) {
      return;
    }

    ref.read(workoutViewModelProvider.notifier).deleteWorkout(workout.id);

    await ref
        .read(weeklyScheduleViewModelProvider.notifier)
        .removeWorkout(workout.id);

    if (!context.mounted) {
      return;
    }

    AppFeedback.success(context, 'Workout deleted');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(workoutViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Workouts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WorkoutHistoryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.history),
          ),
          IconButton(
            onPressed: () => _createWorkout(context, ref),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: workouts.length,
        itemBuilder: (context, index) {
          final workout = workouts[index];

          return WorkoutCard(
            workout: workout,
            onEdit: () => _editWorkout(context, workout),
            onDelete: () => _deleteWorkout(context, ref, workout),
          );
        },
      ),
    );
  }
}
