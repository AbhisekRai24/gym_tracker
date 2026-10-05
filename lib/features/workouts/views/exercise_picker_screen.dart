import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/exercise_viewmodel.dart';
import 'exercise_detail_screen.dart';

class ExercisePickerScreen extends ConsumerStatefulWidget {
  final String workoutId;

  const ExercisePickerScreen({
    super.key,
    required this.workoutId,
  });

  @override
  ConsumerState<ExercisePickerScreen> createState() =>
      _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends ConsumerState<ExercisePickerScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  String _selectedMuscleGroup = 'All';

  static const List<String> muscleGroups = [
    'All',
    'Chest',
    'Back',
    'Shoulders',
    'Triceps',
    'Legs',
  ];

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = ref.watch(exerciseViewModelProvider);

    final filteredExercises = exercises.where((exercise) {
      final matchesSearch = exercise.name.toLowerCase().contains(_searchQuery);

      final matchesMuscleGroup =
          _selectedMuscleGroup == 'All' ||
          exercise.muscleGroup == _selectedMuscleGroup;

      return matchesSearch && matchesMuscleGroup;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Exercise')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: muscleGroups.length,
              itemBuilder: (context, index) {
                final group = muscleGroups[index];

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(group),
                    selected: _selectedMuscleGroup == group,
                    onSelected: (_) {
                      setState(() {
                        _selectedMuscleGroup = group;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        Navigator.pop(context, exercise.name);
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExerciseDetailScreen(
  exercise: exercise,
  workoutId: widget.workoutId,
),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
