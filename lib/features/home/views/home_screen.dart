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

  Workout? _findWorkout(List<Workout> workouts, String? workoutId) {
    if (workoutId == null) {
      return null;
    }

    for (final workout in workouts) {
      if (workout.id == workoutId) {
        return workout;
      }
    }

    return null;
  }

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

  bool _hasWorkoutOnDay(
    List<WorkoutSession> sessions,
    DateTime day,
    String workoutId,
  ) {
    return sessions.any((session) {
      return session.workoutId == workoutId &&
          session.date.year == day.year &&
          session.date.month == day.month &&
          session.date.day == day.day;
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(workoutListProvider);
    final sessions = ref.watch(workoutSessionListProvider);
    final today = DateTime.now();
    final schedule = ref.watch(weeklyScheduleViewModelProvider);

    final todayIndex = today.weekday % 7;

    final todayWorkoutId = schedule.workoutForDay(todayIndex);
    final todayWorkout = _findWorkout(workouts, todayWorkoutId);

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

    final palette = _HomePalette.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          'GymTrack',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: palette.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.person_outline, color: palette.textPrimary),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning 👋',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  height: 1.15,
                  color: palette.textPrimary,
                ),
              ),

              const SizedBox(height: 20),

              _TodayWorkoutCard(
                workout: todayWorkout,
                onStart: todayWorkout == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                WorkoutSessionScreen(workout: todayWorkout),
                          ),
                        );
                      },
              ),

              const SizedBox(height: 28),

              const _SectionHeader(title: 'This Week'),

              const SizedBox(height: 12),

              _SurfaceCard(
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 14),
                child: Column(
                  children: [
                    Row(
                      children: List.generate(7, (index) {
                        final day = startOfWeek.add(Duration(days: index));

                        const dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                        final scheduledWorkoutId = schedule.workoutForDay(
                          index,
                        );

                        final scheduledWorkout = _findWorkout(
                          workouts,
                          scheduledWorkoutId,
                        );

                        final scheduled = scheduledWorkout != null;

                        final completed =
                            scheduledWorkoutId != null &&
                            _hasWorkoutOnDay(sessions, day, scheduledWorkoutId);

                        final isToday =
                            day.year == today.year &&
                            day.month == today.month &&
                            day.day == today.day;

                        return Expanded(
                          child: _DayIndicator(
                            day: dayLabels[index],
                            scheduled: scheduled,
                            completed: completed,
                            isToday: isToday,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 14),
                    const _WeekLegend(),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const _SectionHeader(title: 'Recent Workouts'),

              const SizedBox(height: 12),

              if (sessions.isEmpty)
                const _EmptyRecent()
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

              const SizedBox(height: 20),

              const _SectionHeader(title: 'Quick Stats'),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Workouts',
                      value: '${sessions.length}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(title: 'Exercises', value: '$totalSets'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(title: 'Best Lift', value: '$bestLift kg'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Neutral colors used across the screen. Primary/green comes from the theme.
class _HomePalette {
  final Color background;
  final Color card;
  final Color border;
  final Color textPrimary;
  final Color textMuted;
  final Color mutedFill;

  const _HomePalette({
    required this.background,
    required this.card,
    required this.border,
    required this.textPrimary,
    required this.textMuted,
    required this.mutedFill,
  });

  factory _HomePalette.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return const _HomePalette(
        background: Color(0xFF121413),
        card: Color(0xFF1C1F1D),
        border: Color(0xFF2B302D),
        textPrimary: Color(0xFFF2F4F3),
        textMuted: Color(0xFF9AA19D),
        mutedFill: Color(0xFF2B302D),
      );
    }

    return const _HomePalette(
      background: Color(0xFFF6F7F6),
      card: Colors.white,
      border: Color(0xFFE6E9E7),
      textPrimary: Color(0xFF1C1F1D),
      textMuted: Color(0xFF6F7772),
      mutedFill: Color(0xFFECEEED),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final palette = _HomePalette.of(context);

    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: palette.textPrimary,
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool elevated;

  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
    this.elevated = true,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _HomePalette.of(context);

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: palette.border),
        boxShadow: elevated
            ? const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

class _TodayWorkoutCard extends StatelessWidget {
  final Workout? workout;
  final VoidCallback? onStart;

  const _TodayWorkoutCard({required this.workout, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final palette = _HomePalette.of(context);
    final currentWorkout = workout;

    if (currentWorkout == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: palette.card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.bedtime_outlined, color: colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Workout",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rest Day 😴',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No workout scheduled for today.',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return _SurfaceCard(
      radius: 20,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Today's Workout",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: palette.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            currentWorkout.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.15,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.fitness_center, size: 16, color: palette.textMuted),
              const SizedBox(width: 6),
              Text(
                '${currentWorkout.exercises.length} exercises',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: palette.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onStart,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              child: const Text('START WORKOUT'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayIndicator extends StatelessWidget {
  final String day;
  final bool scheduled;
  final bool completed;
  final bool isToday;

  const _DayIndicator({
    required this.day,
    required this.scheduled,
    required this.completed,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final palette = _HomePalette.of(context);

    IconData icon;
    Color backgroundColor;
    Color iconColor;

    if (completed) {
      icon = Icons.check;
      backgroundColor = colorScheme.primary;
      iconColor = colorScheme.onPrimary;
    } else if (scheduled) {
      icon = Icons.fitness_center;
      backgroundColor = colorScheme.primaryContainer;
      iconColor = colorScheme.primary;
    } else {
      icon = Icons.bed_outlined;
      backgroundColor = palette.mutedFill;
      iconColor = palette.textMuted;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          day,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
            color: isToday ? colorScheme.primary : palette.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isToday ? colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 15,
            backgroundColor: backgroundColor,
            child: Icon(icon, color: iconColor, size: 16),
          ),
        ),
      ],
    );
  }
}

class _WeekLegend extends StatelessWidget {
  const _WeekLegend();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final palette = _HomePalette.of(context);

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 6,
      children: [
        _LegendItem(
          icon: Icons.check,
          label: 'Completed',
          background: colorScheme.primary,
          iconColor: colorScheme.onPrimary,
        ),
        _LegendItem(
          icon: Icons.fitness_center,
          label: 'Scheduled',
          background: colorScheme.primaryContainer,
          iconColor: colorScheme.primary,
        ),
        _LegendItem(
          icon: Icons.bed_outlined,
          label: 'Rest',
          background: palette.mutedFill,
          iconColor: palette.textMuted,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;
  final Color iconColor;

  const _LegendItem({
    required this.icon,
    required this.label,
    required this.background,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _HomePalette.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 8,
          backgroundColor: background,
          child: Icon(icon, size: 10, color: iconColor),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: palette.textMuted)),
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
    final palette = _HomePalette.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _SurfaceCard(
        elevated: false,
        radius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: palette.mutedFill,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.fitness_center,
                size: 18,
                color: palette.textMuted,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                workout,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              date,
              style: TextStyle(fontSize: 13, color: palette.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRecent extends StatelessWidget {
  const _EmptyRecent();

  @override
  Widget build(BuildContext context) {
    final palette = _HomePalette.of(context);

    return _SurfaceCard(
      elevated: false,
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          Icon(Icons.history, size: 20, color: palette.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No workouts completed yet.',
              style: TextStyle(fontSize: 14, color: palette.textMuted),
            ),
          ),
        ],
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
    final palette = _HomePalette.of(context);

    return _SurfaceCard(
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: palette.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: palette.textMuted),
          ),
        ],
      ),
    );
  }
}
