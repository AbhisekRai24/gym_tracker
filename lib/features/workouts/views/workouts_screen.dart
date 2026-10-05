import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_track/features/workouts/viewmodels/workout_viewmodel.dart';
import 'package:gym_track/features/workouts/views/create_workout_screen.dart';
import 'package:gym_track/features/workouts/widgets/workout_card.dart';





class WorkoutsScreen extends ConsumerWidget {
  const WorkoutsScreen({super.key});

  Future<void> _createWorkout(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final workoutName = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateWorkoutScreen(),
      ),
    );

    if (workoutName != null) {
      ref
          .read(workoutViewModelProvider.notifier)
          .addWorkout(workoutName);
    }
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final workouts = ref.watch(workoutViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Workouts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
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
          );
        },
      ),
    );
  }
}