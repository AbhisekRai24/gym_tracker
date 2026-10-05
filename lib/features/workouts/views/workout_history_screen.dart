import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/workout_session_viewmodel.dart';
import '../viewmodels/workout_viewmodel.dart';
import 'workout_session_detail_screen.dart';

class WorkoutHistoryScreen extends ConsumerWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(workoutSessionViewModelProvider);
    final workouts = ref.watch(workoutViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Workout History')),
      body: sessions.isEmpty
          ? const Center(child: Text('No completed workouts yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];

                final workoutIndex = workouts.indexWhere(
                  (workout) => workout.id == session.workoutId,
                );

                final workoutName = workoutIndex == -1
                    ? 'Unknown Workout'
                    : workouts[workoutIndex].name;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.fitness_center),
                    ),
                    title: Text(
                      workoutName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${session.sets.length} sets'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorkoutSessionDetailScreen(
                            session: session,
                            workoutName: workoutName,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
