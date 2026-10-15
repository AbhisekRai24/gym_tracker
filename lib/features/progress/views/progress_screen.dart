import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_track/features/progress/widgets/progress_chart.dart';
import 'package:gym_track/core/widgets/async_error_view.dart';
import 'package:gym_track/features/workouts/viewmodels/workout_session_viewmodel.dart';
import '../models/exercise_progress.dart';
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
    final sessionsAsync = ref.watch(workoutSessionViewModelProvider);
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    final sortedProgress = [...progress]
      ..sort((a, b) => a.date.compareTo(b.date));

    final availableExercises =
        sortedProgress.map((item) => item.exerciseName).toSet().toList()
          ..sort();

    if (!availableExercises.contains(_selectedExercise)) {
      _selectedExercise = availableExercises.isEmpty
          ? null
          : availableExercises.first;
    }

    final bestPerformance = ref
        .read(progressViewModelProvider.notifier)
        .bestPerformance();

    final selectedProgress = sortedProgress
        .where((item) => item.exerciseName == _selectedExercise)
        .toList();

    final selectedBest = _selectedExercise == null
        ? null
        : bestPerformance[_selectedExercise];

    final recentExerciseRecords = selectedProgress.reversed.take(5).toList();
    final recentRecords = sortedProgress.reversed.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Progress & Analytics',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: sessionsAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : sessionsAsync.hasError
          ? AsyncErrorView(
              message: 'Could not load your progress.',
              onRetry: () => ref.invalidate(workoutSessionViewModelProvider),
            )
          : sortedProgress.isEmpty
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
                        Icons.insights_rounded,
                        size: 48,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Your Progress Starts Here',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complete a workout and log your sets to visualize your strength over time.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                // Summary Stat Cards
                Row(
                  children: [
                    Expanded(
                      child: _ProgressSummaryCard(
                        title: 'Total Sets',
                        value: '${sortedProgress.length}',
                        icon: Icons.fitness_center_rounded,
                        primaryColor: primaryColor,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _ProgressSummaryCard(
                        title: 'Exercises',
                        value: '${availableExercises.length}',
                        icon: Icons.category_rounded,
                        primaryColor: primaryColor,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Exercise Filter Dropdown
                Container(
                  padding: const EdgeInsets.all(16),
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
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target Exercise',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedExercise,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Select Exercise',
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: primaryColor,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Colors.white.withValues(alpha: 0.03)
                              : Colors.grey.shade50,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 2,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: availableExercises.map((exercise) {
                          return DropdownMenuItem(
                            value: exercise,
                            child: Text(
                              exercise,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedExercise = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Best Performance Card
                if (selectedBest != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                            : [Colors.white, Colors.grey.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.emoji_events_rounded,
                            color: primaryColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Personal Best Record',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${selectedBest.weight} kg × ${selectedBest.reps} reps',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                selectedBest.exerciseName,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Strength Progression Chart
                if (selectedProgress.length >= 2) ...[
                  Text(
                    'Strength Progression',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
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
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ProgressChart(data: selectedProgress),
                  ),
                  const SizedBox(height: 28),
                ],

                // Exercise History Section
                _SectionHeader(
                  title: 'Exercise History',
                  onViewAll: () => _openHistory(
                    context,
                    title: '$_selectedExercise History',
                    records: selectedProgress.reversed.toList(),
                  ),
                ),
                const SizedBox(height: 10),

                if (recentExerciseRecords.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No records for this exercise yet.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  )
                else
                  ...recentExerciseRecords.map(
                    (item) => _ProgressRecordCard(
                      item: item,
                      isDark: isDark,
                      primaryColor: primaryColor,
                    ),
                  ),

                const SizedBox(height: 28),

                // Recent Performance Section
                _SectionHeader(
                  title: 'Recent Performance',
                  onViewAll: () => _openHistory(
                    context,
                    title: 'All Performance',
                    records: sortedProgress.reversed.toList(),
                  ),
                ),
                const SizedBox(height: 10),

                ...recentRecords.map(
                  (item) => _ProgressRecordCard(
                    item: item,
                    showExerciseName: true,
                    isDark: isDark,
                    primaryColor: primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  void _openHistory(
    BuildContext context, {
    required String title,
    required List<ExerciseProgress> records,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProgressHistoryScreen(title: title, records: records),
      ),
    );
  }
}

class ProgressHistoryScreen extends StatelessWidget {
  final String title;
  final List<ExerciseProgress> records;

  const ProgressHistoryScreen({
    super.key,
    required this.title,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: records.isEmpty
          ? const Center(child: Text('No history available yet.'))
          : ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: records.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _ProgressRecordCard(
                  item: records[index],
                  showExerciseName: true,
                  isDark: isDark,
                  primaryColor: primaryColor,
                );
              },
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const _SectionHeader({required this.title, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(foregroundColor: primaryColor),
          child: const Text(
            'View All',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _ProgressRecordCard extends StatelessWidget {
  final ExerciseProgress item;
  final bool showExerciseName;
  final bool isDark;
  final Color primaryColor;

  const _ProgressRecordCard({
    required this.item,
    this.showExerciseName = false,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = '${item.date.day}/${item.date.month}/${item.date.year}';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.fitness_center_rounded,
                color: primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    showExerciseName
                        ? item.exerciseName
                        : '${item.weight} kg × ${item.reps} reps',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    showExerciseName
                        ? '${item.weight} kg × ${item.reps} reps'
                        : 'Recorded performance',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: showExerciseName
                          ? primaryColor
                          : theme.textTheme.bodySmall?.color?.withValues(
                              alpha: 0.6,
                            ),
                      fontWeight: showExerciseName
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              date,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color primaryColor;
  final bool isDark;

  const _ProgressSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.primaryColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
