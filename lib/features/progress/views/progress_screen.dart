import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_track/features/progress/widgets/lib/features/progress/widgets/progress_chart.dart';

import '../viewmodels/progress_viewmodel.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  String? _selectedExercise;

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressViewModelProvider);

    final availableExercises = progress
        .map((item) => item.exerciseName)
        .toSet()
        .toList();

    if (_selectedExercise == null && availableExercises.isNotEmpty) {
      _selectedExercise = availableExercises.first;
    }

    final bestPerformance = ref
        .read(progressViewModelProvider.notifier)
        .bestPerformance();

    final totalSets = progress.length;

    final exerciseCount = availableExercises.length;

    final selectedProgress = progress
        .where((item) => item.exerciseName == _selectedExercise)
        .toList();

    final selectedBest = _selectedExercise == null
        ? null
        : bestPerformance[_selectedExercise];

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
                        value: '$exerciseCount',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                DropdownButtonFormField<String>(
                  value: _selectedExercise,
                  decoration: const InputDecoration(
                    labelText: 'Select Exercise',
                    border: OutlineInputBorder(),
                  ),
                  items: availableExercises.map((exercise) {
                    return DropdownMenuItem(
                      value: exercise,
                      child: Text(exercise),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedExercise = value;
                    });
                  },
                ),

                const SizedBox(height: 24),

                // Best Performance
                if (selectedBest != null) ...[
                  const Text(
                    'Best Performance',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.emoji_events),
                      ),
                      title: Text(
                        '${selectedBest.weight} kg × ${selectedBest.reps} reps',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(selectedBest.exerciseName),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
                if (selectedProgress.length >= 2) ...[
                  const Text(
                    'Progress Chart',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ProgressChart(data: selectedProgress),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],

                // Progress History
                const Text(
                  'Progress History',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                ...selectedProgress.reversed.map(
                  (item) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(
                        item.exerciseName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${item.weight} kg × ${item.reps} reps'),
                      trailing: Text('${item.date.day}/${item.date.month}'),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Recent Performance
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
