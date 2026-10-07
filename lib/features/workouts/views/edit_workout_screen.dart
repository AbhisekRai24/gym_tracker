import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/workout.dart';
import '../viewmodels/workout_viewmodel.dart';
import 'exercise_picker_screen.dart';

class EditWorkoutScreen extends ConsumerStatefulWidget {
  final Workout workout;

  const EditWorkoutScreen({super.key, required this.workout});

  @override
  ConsumerState<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends ConsumerState<EditWorkoutScreen> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.workout.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveWorkout() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a workout name')),
      );
      return;
    }

    final updatedWorkout = widget.workout.copyWith(name: name);

    ref.read(workoutViewModelProvider.notifier).updateWorkout(updatedWorkout);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final workouts = ref.watch(workoutViewModelProvider);

    final workout = workouts.firstWhere(
      (workout) => workout.id == widget.workout.id,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Workout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Workout Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Exercises',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: workout.exercises.isEmpty
                  ? const Center(child: Text('No exercises yet'))
                  : ListView.builder(
                      itemCount: workout.exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = workout.exercises[index];

                        return Card(
                          child: ListTile(
                            title: Text(exercise),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                ref
                                    .read(workoutViewModelProvider.notifier)
                                    .removeExercise(workout.id, exercise);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ExercisePickerScreen(workoutId: workout.id),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('ADD EXERCISE'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saveWorkout,
                child: const Text('SAVE CHANGES'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
