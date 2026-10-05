import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/workout_viewmodel.dart';
import 'exercise_picker_screen.dart';

class WorkoutDetailScreen extends ConsumerWidget {
  final String workoutId;

  const WorkoutDetailScreen({
    super.key,
    required this.workoutId,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final workouts = ref.watch(workoutViewModelProvider);

    final workout = workouts.firstWhere(
      (workout) => workout.id == workoutId,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name),
      ),
      body: workout.exercises.isEmpty
          ? const Center(
              child: Text(
                'No exercises yet',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final exercise = await Navigator.push<String>(
            context,
            MaterialPageRoute(
              builder: (context) => const ExercisePickerScreen(),
            ),
          );

          if (exercise != null) {
            ref
                .read(workoutViewModelProvider.notifier)
                .addExercise(
                  workoutId,
                  exercise,
                );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Exercise'),
      ),
    );
  }
}