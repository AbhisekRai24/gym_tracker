import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_track/features/workouts/viewmodels/workout_viewmodel.dart';
import 'package:gym_track/features/workouts/views/create_workout_screen.dart';
import 'package:gym_track/features/workouts/widgets/workout_card.dart';

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

  Future<void> _editWorkout(
    BuildContext context,
    WidgetRef ref,
    Workout workout,
  ) async {
    final workoutName = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateWorkoutScreen(workout: workout),
      ),
    );

    if (workoutName != null) {
      final updatedWorkout = workout.copyWith(name: workoutName);

      ref.read(workoutViewModelProvider.notifier).updateWorkout(updatedWorkout);
    }
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
            onEdit: () => _editWorkout(context, ref, workout),
          );
        },
      ),
    );
  }
}
