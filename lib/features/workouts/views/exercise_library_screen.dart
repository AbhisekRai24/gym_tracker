import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_track/core/widgets/app_feedback.dart';

import '../viewmodels/exercise_viewmodel.dart';
import 'add_exercise_screen.dart';

class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() =>
      _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String exerciseId,
    String exerciseName,
  ) async {
    final shouldDelete = await AppFeedback.confirm(
      context,
      title: 'Delete Exercise?',
      message: 'Are you sure you want to delete "$exerciseName"?',
      confirmText: 'Delete',
      destructive: true,
    );

    if (!shouldDelete) {
      return;
    }

    ref.read(exerciseViewModelProvider.notifier).deleteExercise(exerciseId);

    if (!context.mounted) {
      return;
    }

    AppFeedback.success(context, 'Exercise deleted');
  }

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(exerciseViewModelProvider);

    final filteredExercises = exercises.where((exercise) {
      return exercise.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Exercise Library')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search exercises',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();

                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),

          Expanded(
            child: exercises.isEmpty
                ? const Center(
                    child: Text(
                      'No exercises yet.\nAdd your first exercise!',
                      textAlign: TextAlign.center,
                    ),
                  )
                : filteredExercises.isEmpty
                ? const Center(
                    child: Text(
                      'No exercises found.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = filteredExercises[index];

                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.fitness_center),
                          ),
                          title: Text(
                            exercise.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${exercise.muscleGroup} • ${exercise.equipment}',
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AddExerciseScreen(exercise: exercise),
                                  ),
                                );
                              }

                              if (value == 'delete') {
                                _confirmDelete(
                                  context,
                                  ref,
                                  exercise.id,
                                  exercise.name,
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExerciseScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Exercise'),
      ),
    );
  }
}
