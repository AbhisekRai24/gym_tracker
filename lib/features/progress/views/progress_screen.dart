import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/progress_viewmodel.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressViewModelProvider);

    final bestPerformance = ref
        .read(progressViewModelProvider.notifier)
        .bestPerformance();

    final totalSets = progress.length;

    final exerciseNames = progress
        .map((item) => item.exerciseName)
        .toSet()
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Progress',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: progress.isEmpty
          ? const Center(child: Text('Complete a workout to see your progress'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _ProgressSummaryCard(
                        title: 'Total Sets',
                        value: '$totalSets',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ProgressSummaryCard(
                        title: 'Exercises',
                        value: '$exerciseNames',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Best Performance',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                ...bestPerformance.values.map(
                  (item) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.emoji_events),
                      ),
                      title: Text(
                        item.exerciseName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${item.weight} kg × ${item.reps} reps'),
                      trailing: const Text(
                        'BEST',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),
                const Text(
                  'Recent Performance',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...progress.reversed.map(
                  (item) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.fitness_center),
                      ),
                      title: Text(
                        item.exerciseName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${item.weight} kg × ${item.reps} reps'),
                      trailing: Text('${item.date.day}/${item.date.month}'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ProgressSummaryCard extends StatelessWidget {
  final String title;
  final String value;

  const _ProgressSummaryCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(title),
          ],
        ),
      ),
    );
  }
}
