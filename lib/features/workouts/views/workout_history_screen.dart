import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/workout_session_viewmodel.dart';
import '../viewmodels/workout_viewmodel.dart';
import 'workout_session_detail_screen.dart';

class WorkoutHistoryScreen extends ConsumerWidget {
  const WorkoutHistoryScreen({super.key});

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) {
      return 'Duration not recorded';
    }

    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (minutes == 0) {
      return '$seconds sec';
    }

    return '$minutes min ${seconds.toString().padLeft(2, '0')} sec';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(workoutSessionViewModelProvider);
    final workouts = ref.watch(workoutViewModelProvider);
    final history = sessions.reversed.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Workout History')),
      body: sessions.isEmpty
          ? const Center(child: Text('No completed workouts yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final session = history[index];

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
                    subtitle: Text(
                      '${session.sets.length} sets • '
                      '${_formatDuration(session.duration)}',
                    ),
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
