import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_track/features/planner/viewmodels/weekly_schedule_viewmodel.dart';
import 'package:gym_track/features/workouts/viewmodels/workout_viewmodel.dart';

class WeeklyPlannerScreen extends ConsumerWidget {
  const WeeklyPlannerScreen({super.key});

  static const dayNames = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = ref.watch(weeklyScheduleViewModelProvider);
    final workouts = ref.watch(workoutListProvider);
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onPrimaryColor = theme.colorScheme.onPrimary;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Workout Planner',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: dayNames.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final workoutId = schedule.workoutForDay(index);

          final matchingWorkouts = workouts.where(
            (workout) => workout.id == workoutId,
          );

          final workout = matchingWorkouts.isEmpty
              ? null
              : matchingWorkouts.first;

          return DragTarget<int>(
            onAcceptWithDetails: (details) async {
              final draggedDay = details.data;

              if (draggedDay == index) {
                return;
              }

              await ref
                  .read(weeklyScheduleViewModelProvider.notifier)
                  .swapDays(draggedDay, index);
            },
            builder: (context, candidateData, rejectedData) {
              final isHovered = candidateData.isNotEmpty;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isHovered
                      ? primaryColor.withValues(alpha: 0.15)
                      : isDark
                      ? const Color(0xFF1E293B)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isHovered
                        ? primaryColor
                        : isDark
                        ? Colors.white10
                        : Colors.black12,
                    width: isHovered ? 2 : 1,
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
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      _showWorkoutPicker(context, ref, index, workouts);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Day indicator avatar
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: workout != null
                                  ? primaryColor.withValues(alpha: 0.15)
                                  : (isDark
                                        ? Colors.white10
                                        : Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                dayNames[index].substring(0, 3).toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: workout != null
                                      ? primaryColor
                                      : theme.textTheme.bodySmall?.color
                                            ?.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Day name and assigned workout
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dayNames[index],
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  workout?.name ?? 'Rest Day',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: workout != null
                                        ? primaryColor
                                        : theme.textTheme.bodySmall?.color
                                              ?.withValues(alpha: 0.5),
                                    fontWeight: workout != null
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Drag Handle Widget
                          if (workout != null)
                            Draggable<int>(
                              data: index,
                              feedback: Material(
                                color: Colors.transparent,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.fitness_center_rounded,
                                        color: onPrimaryColor,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        workout.name,
                                        style: TextStyle(
                                          color: onPrimaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              childWhenDragging: Icon(
                                Icons.drag_indicator_rounded,
                                color: theme.textTheme.bodySmall?.color
                                    ?.withValues(alpha: 0.2),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.drag_indicator_rounded,
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showWorkoutPicker(
    BuildContext context,
    WidgetRef ref,
    int day,
    List workouts,
  ) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grab handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Text(
                      'Assign to ${dayNames[day]}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  children: [
                    // Rest Day option
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.bed_outlined, size: 20),
                      ),
                      title: const Text(
                        'Rest Day',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onTap: () {
                        ref
                            .read(weeklyScheduleViewModelProvider.notifier)
                            .clearDay(day);

                        Navigator.pop(context);
                      },
                    ),
                    const Divider(height: 16, indent: 16, endIndent: 16),

                    // Workouts list
                    ...workouts.map((workout) {
                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.fitness_center_rounded,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          workout.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onTap: () {
                          ref
                              .read(weeklyScheduleViewModelProvider.notifier)
                              .assignWorkout(day, workout.id);

                          Navigator.pop(context);
                        },
                      );
                    }),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
