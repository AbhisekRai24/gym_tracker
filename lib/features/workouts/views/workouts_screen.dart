import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_track/core/widgets/app_feedback.dart';
import 'package:gym_track/features/planner/viewmodels/weekly_schedule_viewmodel.dart';
import 'package:gym_track/core/widgets/async_error_view.dart';
import 'package:gym_track/features/workouts/viewmodels/workout_viewmodel.dart';
import 'package:gym_track/features/workouts/widgets/workout_card.dart';
import 'package:gym_track/features/workouts/views/create_workout_screen.dart';
import 'edit_workout_screen.dart';

import '../models/workout.dart';
import 'workout_history_screen.dart';

class WorkoutsScreen extends ConsumerWidget {
  const WorkoutsScreen({super.key});

  Future<void> _createWorkout(BuildContext context, WidgetRef ref) async {
    final workoutName = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const CreateWorkoutScreen()),
    );

    if (workoutName != null) {
      ref.read(workoutViewModelProvider.notifier).addWorkout(workoutName);
    }
  }

  void _editWorkout(BuildContext context, Workout workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditWorkoutScreen(workout: workout),
      ),
    );
  }

  Future<void> _deleteWorkout(
    BuildContext context,
    WidgetRef ref,
    Workout workout,
  ) async {
    final shouldDelete = await AppFeedback.confirm(
      context,
      title: 'Delete Workout?',
      message: 'Are you sure you want to delete "${workout.name}"?',
      confirmText: 'Delete',
      destructive: true,
    );

    if (!shouldDelete) {
      return;
    }

    ref.read(workoutViewModelProvider.notifier).deleteWorkout(workout.id);

    await ref
        .read(weeklyScheduleViewModelProvider.notifier)
        .removeWorkout(workout.id);

    if (!context.mounted) {
      return;
    }

    AppFeedback.success(context, 'Workout deleted');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutViewModelProvider);
    final workouts = ref.watch(workoutListProvider);
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onPrimaryColor = theme.colorScheme.onPrimary;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'My Workouts',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          // History button only (duplicate create button removed)
          IconButton.filledTonal(
            style: IconButton.styleFrom(
              backgroundColor: primaryColor.withValues(alpha: 0.15),
              foregroundColor: primaryColor,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WorkoutHistoryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.history_rounded, size: 20),
            tooltip: 'Workout History',
          ),
          const SizedBox(width: 16),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createWorkout(context, ref),
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
        elevation: 3,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New Workout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: workoutsAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : workoutsAsync.hasError
          ? AsyncErrorView(
              message: 'Could not load your workouts.',
              onRetry: () => ref.invalidate(workoutViewModelProvider),
            )
          : workouts.isEmpty
          ? _buildEmptyState(context, ref, primaryColor, onPrimaryColor)
          : ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: workouts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final workout = workouts[index];
                return WorkoutCard(
                  workout: workout,
                  onEdit: () => _editWorkout(context, workout),
                  onDelete: () => _deleteWorkout(context, ref, workout),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    Color primaryColor,
    Color onPrimaryColor,
  ) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fitness_center_rounded,
                size: 48,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Workouts Yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Build your first routine to start tracking your gym progress and exercises.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.6,
                ),
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => _createWorkout(context, ref),
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
                'Create First Workout',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
