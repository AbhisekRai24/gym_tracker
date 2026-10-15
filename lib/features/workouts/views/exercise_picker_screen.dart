import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_track/core/widgets/async_error_view.dart';
import '../models/exercise.dart';
import '../viewmodels/exercise_viewmodel.dart';
import 'exercise_detail_screen.dart';
import 'package:gym_track/core/widgets/app_feedback.dart';
import 'package:gym_track/features/workouts/viewmodels/workout_viewmodel.dart';

class ExercisePickerScreen extends ConsumerStatefulWidget {
  final String workoutId;

  const ExercisePickerScreen({super.key, required this.workoutId});

  @override
  ConsumerState<ExercisePickerScreen> createState() =>
      _ExercisePickerScreenState();
}

class _ExercisePickerScreenState extends ConsumerState<ExercisePickerScreen> {
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
  ];
  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exerciseViewModelProvider);
    final exercises = (exercisesAsync.isLoading || exercisesAsync.hasError)
        ? const <Exercise>[]
        : exercisesAsync.requireValue;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onPrimaryColor = theme.colorScheme.onPrimary;
    final isDark = theme.brightness == Brightness.dark;

    final filteredExercises = exercises.where((exercise) {
      final matchesSearch = exercise.name.toLowerCase().contains(_searchQuery);

      final matchesMuscleGroup =
          _selectedMuscleGroup == 'All' ||
          exercise.muscleGroup == _selectedMuscleGroup;

      return matchesSearch && matchesMuscleGroup;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Add Exercise',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: Icon(Icons.search_rounded, color: primaryColor),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () {
                          _searchController.clear();
                        },
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

          // Muscle Group Filter Chips
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

          // Exercise List View
          Expanded(
            child: exercisesAsync.isLoading
                ? const Center(child: CircularProgressIndicator())
                : exercisesAsync.hasError
                ? AsyncErrorView(
                    message: 'Could not load your exercises.',
                    onRetry: () => ref.invalidate(exerciseViewModelProvider),
                  )
                : filteredExercises.isEmpty
                ? Center(
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
                            child: Icon(
                              Icons.search_off_rounded,
                              size: 40,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Exercises Found',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try searching for something else or reset the muscle group filter.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: filteredExercises.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final exercise = filteredExercises[index];

                      return Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white,
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
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExerciseDetailScreen(
                                    exercise: exercise,
                                    workoutId: widget.workoutId,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  // Icon Badge
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.fitness_center_rounded,
                                      color: primaryColor,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Title & Badges
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exercise.name,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: -0.2,
                                              ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            _buildBadge(
                                              context,
                                              exercise.muscleGroup,
                                              primaryColor,
                                            ),
                                            const SizedBox(width: 6),
                                            _buildBadge(
                                              context,
                                              exercise.equipment,
                                              theme.textTheme.bodySmall?.color
                                                      ?.withValues(
                                                        alpha: 0.6,
                                                      ) ??
                                                  Colors.grey,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Quick Add Action
                                  IconButton.filledTonal(
                                    style: IconButton.styleFrom(
                                      backgroundColor: primaryColor.withValues(
                                        alpha: 0.15,
                                      ),
                                      foregroundColor: primaryColor,
                                    ),
                                    icon: const Icon(
                                      Icons.add_rounded,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      final workouts = ref.read(
                                        workoutViewModelProvider,
                                      );

                                      final workout = workouts.firstWhere(
                                        (workout) =>
                                            workout.id == widget.workoutId,
                                      );

                                      if (workout.exercises.contains(
                                        exercise.name,
                                      )) {
                                        AppFeedback.info(
                                          context,
                                          '${exercise.name} is already in this workout.',
                                        );
                                        return;
                                      }

                                      ref
                                          .read(
                                            workoutViewModelProvider.notifier,
                                          )
                                          .addExercise(
                                            widget.workoutId,
                                            exercise.name,
                                          );

                                      AppFeedback.success(
                                        context,
                                        '${exercise.name} added to workout!',
                                      );
                                    },
                                    tooltip: 'Add Exercise',
                                  ),
                                ],
                              ),
                            ),
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

  Widget _buildBadge(BuildContext context, String text, Color accentColor) {
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
