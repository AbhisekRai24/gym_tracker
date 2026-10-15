import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_track/core/widgets/async_error_view.dart';
import 'package:gym_track/features/workouts/viewmodels/exercise_viewmodel.dart';
import 'package:gym_track/features/workouts/viewmodels/workout_session_viewmodel.dart';

import '../../workouts/models/exercise.dart';
import '../models/exercise_progress.dart';
import '../viewmodels/progress_viewmodel.dart';

class _PrRecord {
  final ExerciseProgress best;
  final String muscleGroup;

  const _PrRecord(this.best, this.muscleGroup);
}

class PrLiftsScreen extends ConsumerStatefulWidget {
  const PrLiftsScreen({super.key});

  @override
  ConsumerState<PrLiftsScreen> createState() => _PrLiftsScreenState();
}

class _PrLiftsScreenState extends ConsumerState<PrLiftsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedMuscleGroup = 'All';

  static const List<String> muscleGroups = [
    'All',
    'Chest',
    'Back',
    'Shoulders',
    'Triceps',
    'Biceps',
    'Legs',
    'Core',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _key(String name) => name.trim().toLowerCase();

  // Heaviest set per exercise. Ties: more reps, then the most recent.
  List<_PrRecord> _buildRecords(
    List<ExerciseProgress> progress,
    List<Exercise> exercises,
  ) {
    final muscleByName = <String, String>{
      for (final exercise in exercises)
        _key(exercise.name): exercise.muscleGroup,
    };

    final bestByName = <String, ExerciseProgress>{};

    for (final item in progress) {
      final key = _key(item.exerciseName);
      final current = bestByName[key];

      if (current == null || _isBetter(item, current)) {
        bestByName[key] = item;
      }
    }

    final records = bestByName.entries
        .map((entry) => _PrRecord(entry.value, muscleByName[entry.key] ?? 'Other'))
        .toList();

    records.sort(
      (a, b) => a.best.exerciseName.toLowerCase().compareTo(
        b.best.exerciseName.toLowerCase(),
      ),
    );

    return records;
  }

  bool _isBetter(ExerciseProgress candidate, ExerciseProgress current) {
    if (candidate.weight != current.weight) {
      return candidate.weight > current.weight;
    }
    if (candidate.reps != current.reps) {
      return candidate.reps > current.reps;
    }
    return candidate.date.isAfter(current.date);
  }

  String _formatWeight(double weight) {
    return weight == weight.roundToDouble()
        ? weight.toStringAsFixed(0)
        : weight.toString();
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(workoutSessionViewModelProvider);
    final progress = ref.watch(progressViewModelProvider);
    final exercises =
        ref.watch(exerciseViewModelProvider).value ?? const <Exercise>[];

    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onPrimaryColor = theme.colorScheme.onPrimary;
    final isDark = theme.brightness == Brightness.dark;

    final records = _buildRecords(progress, exercises);

    final filtered = records.where((record) {
      final matchesSearch = record.best.exerciseName.toLowerCase().contains(
        _searchQuery,
      );

      final matchesGroup =
          _selectedMuscleGroup == 'All' ||
          record.muscleGroup == _selectedMuscleGroup;

      return matchesSearch && matchesGroup;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'My PR Lifts',
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
              message: 'Could not load your lifts.',
              onRetry: () => ref.invalidate(workoutSessionViewModelProvider),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search input
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search lifts...',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: primaryColor,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 20),
                              onPressed: _searchController.clear,
                            )
                          : null,
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF1E293B)
                          : Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white10 : Colors.black12,
                        ),
                      ),
                    ),
                  ),
                ),

                // Muscle group filter chips
                SizedBox(
                  height: 42,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: muscleGroups.length,
                    itemBuilder: (context, index) {
                      final group = muscleGroups[index];
                      final isSelected = _selectedMuscleGroup == group;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(group),
                          selected: isSelected,
                          showCheckmark: false,
                          selectedColor: primaryColor,
                          backgroundColor: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.grey.shade100,
                          labelStyle: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? onPrimaryColor
                                : theme.textTheme.bodyMedium?.color?.withValues(
                                    alpha: 0.8,
                                  ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isSelected
                                  ? primaryColor
                                  : isDark
                                  ? Colors.white10
                                  : Colors.black12,
                            ),
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedMuscleGroup = group;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: records.isEmpty
                      ? _buildEmptyState(
                          context,
                          icon: Icons.emoji_events_rounded,
                          title: 'No PRs Yet',
                          subtitle:
                              'Complete a workout and log your sets to see your personal bests here.',
                        )
                      : filtered.isEmpty
                      ? _buildEmptyState(
                          context,
                          icon: Icons.search_off_rounded,
                          title: 'No Lifts Found',
                          subtitle:
                              'Try searching for something else or reset the muscle group filter.',
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final record = filtered[index];
                            final best = record.best;
                            final date =
                                '${best.date.day}/${best.date.month}/${best.date.year}';

                            return Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E293B)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white10
                                      : Colors.black12,
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
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.emoji_events_rounded,
                                        color: primaryColor,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            best.exerciseName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: -0.2,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${_formatWeight(best.weight)} kg × ${best.reps} reps',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: primaryColor,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          const SizedBox(height: 6),
                                          _buildBadge(
                                            record.muscleGroup,
                                            primaryColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      date,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .textTheme
                                                .bodySmall
                                                ?.color
                                                ?.withValues(alpha: 0.5),
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
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