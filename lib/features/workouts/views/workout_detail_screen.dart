import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/workout_viewmodel.dart';
import 'exercise_picker_screen.dart';

import 'workout_session_screen.dart';

class WorkoutDetailScreen extends ConsumerWidget {
  final String workoutId;

  const WorkoutDetailScreen({super.key, required this.workoutId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(workoutViewModelProvider);

    final workout = workouts.firstWhere((workout) => workout.id == workoutId);

    return Scaffold(
      appBar: AppBar(title: Text(workout.name)),
      body: workout.exercises.isEmpty
          ? const Center(
              child: Text(
                'No exercises yet',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: workout.exercises.length,
              itemBuilder: (context, index) {
                final exercise = workout.exercises[index];

                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.fitness_center),
                    ),
                    title: Text(
                      exercise,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        ref
                            .read(workoutViewModelProvider.notifier)
                            .removeExercise(workoutId, exercise);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'startWorkout',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkoutSessionScreen(workout: workout),
                ),
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Workout'),
          ),

          const SizedBox(height: 12),

          FloatingActionButton.extended(
            heroTag: 'addExercise',
            onPressed: () async {
              final exercise = await Navigator.push<String>(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ExercisePickerScreen(workoutId: workoutId),
                ),
              );

              if (exercise != null) {
                ref
                    .read(workoutViewModelProvider.notifier)
                    .addExercise(workoutId, exercise);
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Exercise'),
          ),
        ],
      ),
    );
  }
}
