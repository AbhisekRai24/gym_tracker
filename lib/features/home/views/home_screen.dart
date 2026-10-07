import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_track/features/planner/viewmodels/weekly_schedule_viewmodel.dart';
import 'package:gym_track/features/workouts/models/workout_session.dart';

import '../../workouts/models/workout.dart';
import '../../workouts/viewmodels/workout_viewmodel.dart';
import '../../workouts/viewmodels/workout_session_viewmodel.dart';
import '../../workouts/views/workout_session_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getWorkoutName(List<Workout> workouts, String workoutId) {
    for (final workout in workouts) {
      if (workout.id == workoutId) {
        return workout.name;
      }
    }

    return 'Unknown Workout';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  bool _hasWorkoutOnDay(List<WorkoutSession> sessions, DateTime day) {
    return sessions.any((session) {
      return session.date.year == day.year &&
          session.date.month == day.month &&
          session.date.day == day.day;
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(workoutViewModelProvider);
    final sessions = ref.watch(workoutSessionViewModelProvider);

    final today = DateTime.now();
    final schedule = ref.watch(weeklyScheduleViewModelProvider);

    final todayIndex = today.weekday % 7;

    final todayWorkoutId = schedule.workoutForDay(todayIndex);

    final todayWorkout = todayWorkoutId == null
        ? null
        : workouts.firstWhere((workout) => workout.id == todayWorkoutId);

    final startOfWeek = today.subtract(Duration(days: today.weekday % 7));
    final totalSets = sessions.fold<int>(
      0,
      (total, session) => total + session.sets.length,
    );
    double bestLift = 0;

    for (final session in sessions) {
      for (final set in session.sets) {
        if (set.weight > bestLift) {
          bestLift = set.weight;
        }
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GymTrack',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.person_outline)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Good morning 👋',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            const Text(
              "Today's Workout",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: todayWorkout == null
                    ? const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rest Day 😴',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('No workout scheduled for today.'),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            todayWorkout.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('${todayWorkout.exercises.length} exercises'),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WorkoutSessionScreen(
                                      workout: todayWorkout,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('START WORKOUT'),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'This Week',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (index) {
                    final day = startOfWeek.add(Duration(days: index));

                    const dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                    return _DayIndicator(
                      day: dayLabels[index],
                      completed: _hasWorkoutOnDay(sessions, day),
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Recent Workouts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            if (sessions.isEmpty)
              const Text('No workouts completed yet.')
            else
              ...sessions.reversed.take(3).map((session) {
                final workoutName = _getWorkoutName(
                  workouts,
                  session.workoutId,
                );

                return _WorkoutHistoryTile(
                  workout: workoutName,
                  date: _formatDate(session.date),
                );
              }),
            const SizedBox(height: 24),

            const Text(
              'Quick Stats',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Workouts',
                    value: '${sessions.length}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(title: 'Exercises', value: '$totalSets'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(title: 'Best Lift', value: '$bestLift kg'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DayIndicator extends StatelessWidget {
  final String day;
  final bool completed;

  const _DayIndicator({required this.day, required this.completed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        CircleAvatar(
          radius: 16,
          backgroundColor: completed ? Colors.green : Colors.grey.shade300,
          child: completed
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : null,
        ),
      ],
    );
  }
}

class _WorkoutHistoryTile extends StatelessWidget {
  final String workout;
  final String date;

  const _WorkoutHistoryTile({required this.workout, required this.date});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.fitness_center)),
        title: Text(
          workout,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Text(date),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(title),
          ],
        ),
      ),
    );
  }
}
