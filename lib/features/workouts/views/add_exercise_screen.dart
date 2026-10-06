import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/exercise_viewmodel.dart';
import '../models/exercise.dart';

class AddExerciseScreen extends ConsumerStatefulWidget {
  final Exercise? exercise;

  const AddExerciseScreen({super.key, this.exercise});

  @override
  ConsumerState<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends ConsumerState<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  String _selectedMuscleGroup = 'Chest';
  String _selectedEquipment = 'Barbell';

  static const List<String> muscleGroups = [
    'Chest',
    'Back',
    'Shoulders',
    'Triceps',
    'Biceps',
    'Legs',
    'Core',
    'Other',
  ];

  static const List<String> equipmentOptions = [
    'Barbell',
    'Dumbbell',
    'Machine',
    'Cable',
    'Bodyweight',
    'Kettlebell',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    final exercise = widget.exercise;

    if (exercise != null) {
      _nameController.text = exercise.name;
      _selectedMuscleGroup = exercise.muscleGroup;
      _selectedEquipment = exercise.equipment;
    }
  }

  void _saveExercise() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final existingExercise = widget.exercise;

    if (existingExercise == null) {
      ref
          .read(exerciseViewModelProvider.notifier)
          .addExercise(
            name: _nameController.text.trim(),
            muscleGroup: _selectedMuscleGroup,
            equipment: _selectedEquipment,
          );
    } else {
      final updatedExercise = Exercise(
        id: existingExercise.id,
        name: _nameController.text.trim(),
        muscleGroup: _selectedMuscleGroup,
        equipment: _selectedEquipment,
      );

      ref
          .read(exerciseViewModelProvider.notifier)
          .updateExercise(updatedExercise);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise == null ? 'Add Exercise' : 'Edit Exercise'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Exercise Name',
                hintText: 'e.g. Incline Dumbbell Press',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter an exercise name';
                }

                return null;
              },
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: _selectedMuscleGroup,
              decoration: const InputDecoration(
                labelText: 'Muscle Group',
                border: OutlineInputBorder(),
              ),
              items: muscleGroups.map((group) {
                return DropdownMenuItem(value: group, child: Text(group));
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _selectedMuscleGroup = value;
                });
              },
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: _selectedEquipment,
              decoration: const InputDecoration(
                labelText: 'Equipment',
                border: OutlineInputBorder(),
              ),
              items: equipmentOptions.map((equipment) {
                return DropdownMenuItem(
                  value: equipment,
                  child: Text(equipment),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _selectedEquipment = value;
                });
              },
            ),

            const SizedBox(height: 32),

            FilledButton.icon(
              onPressed: _saveExercise,
              icon: const Icon(Icons.add),
              label: Text(
                widget.exercise == null ? 'Add Exercise' : 'Save Changes',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
