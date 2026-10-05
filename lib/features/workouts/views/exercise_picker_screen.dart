import 'package:flutter/material.dart';

class ExercisePickerScreen extends StatelessWidget {
  const ExercisePickerScreen({super.key});

  static const List<String> exercises = [
    'Bench Press',
    'Incline Dumbbell Press',
    'Cable Fly',
    'Shoulder Press',
    'Lateral Raise',
    'Tricep Pushdown',
    'Barbell Row',
    'Lat Pulldown',
    'Barbell Squat',
    'Leg Press',
    'Romanian Deadlift',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Exercise'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index];

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
              trailing: const Icon(Icons.add),
              onTap: () {
                Navigator.pop(
                  context,
                  exercise,
                );
              },
            ),
          );
        },
      ),
    );
  }
}