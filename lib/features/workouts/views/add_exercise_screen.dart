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
  void initState() {
    super.initState();

    final exercise = widget.exercise;

    if (exercise != null) {
      _nameController.text = exercise.name;
      _selectedMuscleGroup = exercise.muscleGroup;
      _selectedEquipment = exercise.equipment;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onPrimaryColor = theme.colorScheme.onPrimary;
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.exercise != null;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          isEditing ? 'Edit Exercise' : 'Add Exercise',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            // Top Header Icon Card
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isEditing ? Icons.edit_rounded : Icons.fitness_center_rounded,
                  size: 40,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Form Fields Container Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Exercise Details',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Exercise Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Exercise Name',
                      hintText: 'e.g. Incline Dumbbell Press',
                      prefixIcon: Icon(
                        Icons.fitness_center_rounded,
                        color: primaryColor,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.03)
                          : Colors.grey.shade50,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter an exercise name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Muscle Group Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedMuscleGroup,
                    decoration: InputDecoration(
                      labelText: 'Muscle Group',
                      prefixIcon: Icon(
                        Icons.category_rounded,
                        color: primaryColor,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.03)
                          : Colors.grey.shade50,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

                  // Equipment Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedEquipment,
                    decoration: InputDecoration(
                      labelText: 'Equipment',
                      prefixIcon: Icon(
                        Icons.build_rounded,
                        color: primaryColor,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.03)
                          : Colors.grey.shade50,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Save Action Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: onPrimaryColor,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _saveExercise,
                icon: Icon(isEditing ? Icons.save_rounded : Icons.add_rounded),
                label: Text(
                  isEditing ? 'Save Changes' : 'Add Exercise',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
