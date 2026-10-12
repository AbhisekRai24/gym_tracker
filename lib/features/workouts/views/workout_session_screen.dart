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

    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.emoji_events_rounded, color: primaryColor),
              const SizedBox(width: 10),
              const Text('Workout Complete 🎉'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.workout.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              _buildSummaryRow(context, 'Duration', durationText),
              _buildSummaryRow(context, 'Exercises', '$completedExercises'),
              _buildSummaryRow(context, 'Total Sets', '$totalSets'),
              _buildSummaryRow(
                context,
                'Best Lift',
                '${bestLift.toStringAsFixed(1)} kg',
              ),
              _buildSummaryRow(
                context,
                'Total Volume',
                '${totalVolume.toStringAsFixed(1)} kg',
              ),
            ],
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'DONE',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    Navigator.pop(context);
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onPrimaryColor = theme.colorScheme.onPrimary;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          widget.workout.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.timer_rounded, color: primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Workout in Progress',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Log your sets and weights below',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ],
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

          const SizedBox(height: 16),

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
              onPressed: _completeWorkout,
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text(
                'COMPLETE WORKOUT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
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
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.fitness_center_rounded,
                    color: primaryColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    exercise,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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
                    decoration: InputDecoration(
                      labelText: 'Weight (kg)',
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
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: TextField(
                    controller: repsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Reps',
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
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onAddSet,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text(
                  'ADD SET',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            if (sets.isNotEmpty) ...[
              const SizedBox(height: 14),
              Divider(color: isDark ? Colors.white10 : Colors.black12),
              const SizedBox(height: 6),
              ...sets.asMap().entries.map((entry) {
                final index = entry.key;
                final set = entry.value;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: primaryColor.withValues(alpha: 0.15),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${set.weight} kg × ${set.reps} reps',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
