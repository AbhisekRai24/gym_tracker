import 'package:flutter/material.dart';

import '../models/workout_session.dart';

class WorkoutSessionDetailScreen extends StatelessWidget {
  final WorkoutSession session;
  final String workoutName;

  const WorkoutSessionDetailScreen({
    super.key,
    required this.session,
    required this.workoutName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workoutName),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Workout Details',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '${session.date.day}/${session.date.month}/${session.date.year}',
          ),
          const SizedBox(height: 24),
          ...session.sets.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final set = entry.value;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(
                    set.exerciseName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${set.weight} kg × ${set.reps} reps',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}