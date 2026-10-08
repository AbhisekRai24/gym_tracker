import 'package:flutter/material.dart';
import 'package:gym_track/core/widgets/app_feedback.dart';
import '../models/workout.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/workout_session.dart';
import '../viewmodels/workout_session_viewmodel.dart';

class WorkoutSessionScreen extends ConsumerStatefulWidget {
  final Workout workout;

  const WorkoutSessionScreen({super.key, required this.workout});

  @override
  ConsumerState<WorkoutSessionScreen> createState() =>
      _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends ConsumerState<WorkoutSessionScreen> {
  final Map<String, List<WorkoutSet>> _loggedSets = {};
  final Map<String, TextEditingController> _weightControllers = {};
  final Map<String, TextEditingController> _repsControllers = {};
  final DateTime _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    for (final exercise in widget.workout.exercises) {
      _loggedSets[exercise] = [];
      _weightControllers[exercise] = TextEditingController();
      _repsControllers[exercise] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in _weightControllers.values) {
      controller.dispose();
    }

    for (final controller in _repsControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  void _addSet(String exercise) {
    final weightText = _weightControllers[exercise]!.text.trim();
    final repsText = _repsControllers[exercise]!.text.trim();

    final weight = double.tryParse(weightText);
    final reps = int.tryParse(repsText);

    if (weight == null || reps == null || reps <= 0) {
      AppFeedback.error(context, 'Enter valid weight and reps');
      return;
    }

    setState(() {
      _loggedSets[exercise]!.add(
        WorkoutSet(exerciseName: exercise, weight: weight, reps: reps),
      );
    });

    _weightControllers[exercise]!.clear();
    _repsControllers[exercise]!.clear();
  }

  Future<void> _completeWorkout() async {
    final allSets = _loggedSets.values.expand((sets) => sets).toList();

    if (allSets.isEmpty) {
      AppFeedback.info(context, 'Log at least one set before completing');
      return;
    }

    final duration = DateTime.now().difference(_startTime);

    final session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      workoutId: widget.workout.id,
      date: DateTime.now(),
      duration: duration,
      sets: allSets,
    );

    ref.read(workoutSessionViewModelProvider.notifier).addSession(session);

    final totalSets = allSets.length;

    final completedExercises = _loggedSets.entries
        .where((entry) => entry.value.isNotEmpty)
        .length;

    double totalVolume = 0;
    double bestLift = 0;

    for (final set in allSets) {
      totalVolume += set.weight * set.reps;

      if (set.weight > bestLift) {
        bestLift = set.weight;
      }
    }

    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    final durationText = minutes > 0
        ? '$minutes min ${seconds.toString().padLeft(2, '0')} sec'
        : '$seconds sec';

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Workout Complete 🎉'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.workout.name),
              const SizedBox(height: 16),
              Text('Duration: $durationText'),
              Text('Exercises: $completedExercises'),
              Text('Sets: $totalSets'),
              Text('Best Lift: ${bestLift.toStringAsFixed(1)} kg'),
              Text('Total Volume: ${totalVolume.toStringAsFixed(1)} kg'),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('DONE'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.workout.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Workout in Progress',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          ...widget.workout.exercises.map(
            (exercise) => _ExerciseSessionCard(
              exercise: exercise,
              weightController: _weightControllers[exercise]!,
              repsController: _repsControllers[exercise]!,
              sets: _loggedSets[exercise]!,
              onAddSet: () => _addSet(exercise),
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _completeWorkout,
              child: const Text('COMPLETE WORKOUT'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseSessionCard extends StatelessWidget {
  final String exercise;
  final TextEditingController weightController;
  final TextEditingController repsController;
  final List<WorkoutSet> sets;
  final VoidCallback onAddSet;

  const _ExerciseSessionCard({
    required this.exercise,
    required this.weightController,
    required this.repsController,
    required this.sets,
    required this.onAddSet,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: weightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: TextField(
                    controller: repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Reps',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onAddSet,
                child: const Text('ADD SET'),
              ),
            ),

            if (sets.isNotEmpty) ...[
              const SizedBox(height: 12),

              const Divider(),

              ...sets.asMap().entries.map((entry) {
                final index = entry.key;
                final set = entry.value;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 14,
                    child: Text('${index + 1}'),
                  ),
                  title: Text('${set.weight} kg × ${set.reps} reps'),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
