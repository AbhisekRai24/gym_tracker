import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exercise.dart';
import '../viewmodels/exercise_viewmodel.dart';
import '../viewmodels/workout_viewmodel.dart';
import 'exercise_picker_screen.dart';
import 'workout_session_screen.dart';

class WorkoutDetailScreen extends ConsumerWidget {
  final String workoutId;

  const WorkoutDetailScreen({super.key, required this.workoutId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutViewModelProvider);
    final workouts = ref.watch(workoutListProvider);

    final matches = workouts.where((w) => w.id == workoutId);

    if (matches.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: workoutsAsync.isLoading
              ? const CircularProgressIndicator()
              : const Text('Workout not found'),
        ),
      );
    }

    final workout = matches.first;
    final libraryExercises =
        ref.watch(exerciseViewModelProvider).value ?? const <Exercise>[];

    final exerciseByName = <String, Exercise>{
      for (final item in libraryExercises) item.name.trim().toLowerCase(): item,
    };

    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onPrimaryColor = theme.colorScheme.onPrimary;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          workout.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: workout.exercises.isEmpty
          ? Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.fitness_center_rounded,
                        size: 48,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No Exercises Yet',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add exercises to this workout routine to start training.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ExercisePickerScreen(workoutId: workoutId),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: onPrimaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text(
                        'Add First Exercise',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ReorderableListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
              buildDefaultDragHandles: false,
              proxyDecorator: (child, index, animation) {
                final name = index < workout.exercises.length
                    ? workout.exercises[index]
                    : '';

                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, _) {
                    final t = Curves.easeOut.transform(animation.value);

                    return Transform.scale(
                      scale: 1 + (0.03 * t),
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3 * t),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.fitness_center_rounded,
                                color: onPrimaryColor,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: onPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              itemCount: workout.exercises.length,
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }

                final reorderedExercises = List<String>.from(workout.exercises);
                final exercise = reorderedExercises.removeAt(oldIndex);
                reorderedExercises.insert(newIndex, exercise);

                ref
                    .read(workoutViewModelProvider.notifier)
                    .reorderExercises(workoutId, reorderedExercises);
              },
              itemBuilder: (context, index) {
                final exercise = workout.exercises[index];
                final details = exerciseByName[exercise.trim().toLowerCase()];

                return Container(
                  key: ValueKey(exercise),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.2 : 0.05,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          // Step index badge
                          CircleAvatar(
                            radius: 15,
                            backgroundColor: primaryColor.withValues(
                              alpha: 0.15,
                            ),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Exercise title
                          // Exercise title and tags
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exercise,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                if (details != null) ...[
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      _buildBadge(
                                        details.muscleGroup,
                                        primaryColor,
                                      ),
                                      _buildBadge(
                                        details.equipment,
                                        theme.textTheme.bodySmall?.color
                                                ?.withValues(alpha: 0.6) ??
                                            Colors.grey,
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Action Buttons & Reorder Handle
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: theme.colorScheme.error,
                                  size: 20,
                                ),
                                tooltip: 'Remove exercise',
                                onPressed: () {
                                  ref
                                      .read(workoutViewModelProvider.notifier)
                                      .removeExercise(workoutId, exercise);
                                },
                              ),
                              ReorderableDragStartListener(
                                index: index,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.drag_indicator_rounded,
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withValues(alpha: 0.4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

      // Stacked Action FABs
      floatingActionButton: workout.exercises.isEmpty
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'addExercise',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ExercisePickerScreen(workoutId: workoutId),
                      ),
                    );
                  },
                  backgroundColor: isDark
                      ? const Color(0xFF1E293B)
                      : Colors.grey.shade200,
                  foregroundColor: theme.textTheme.bodyLarge?.color,
                  elevation: 2,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(
                    'Add Exercise',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: 'startWorkout',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            WorkoutSessionScreen(workout: workout),
                      ),
                    );
                  },
                  backgroundColor: primaryColor,
                  foregroundColor: onPrimaryColor,
                  elevation: 4,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text(
                    'Start Workout',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBadge(String text, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: accentColor,
        ),
      ),
    );
  }
}
