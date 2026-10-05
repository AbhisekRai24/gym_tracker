import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/workout_viewmodel.dart';

import '../models/exercise.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  final Exercise exercise;
  final String workoutId;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
    required this.workoutId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(exercise.name)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.fitness_center, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              exercise.name,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text(
              'Muscle Group',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(exercise.muscleGroup),
            const SizedBox(height: 20),
            const Text(
              'Equipment',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(exercise.equipment),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  ref
                      .read(workoutViewModelProvider.notifier)
                      .addExercise(workoutId, exercise.name);

                  Navigator.pop(context, exercise.name);
                },
                icon: const Icon(Icons.add),
                label: const Text('ADD TO WORKOUT'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
