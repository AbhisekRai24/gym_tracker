import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_track/core/widgets/app_feedback.dart';
import 'package:gym_track/core/widgets/async_error_view.dart';
import '../models/exercise.dart';
import '../viewmodels/exercise_viewmodel.dart';
import 'add_exercise_screen.dart';

class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() =>
      _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen> {
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String exerciseId,
    String exerciseName,
  ) async {
    final shouldDelete = await AppFeedback.confirm(
      context,
      title: 'Delete Exercise?',
      message: 'Are you sure you want to delete "$exerciseName"?',
      confirmText: 'Delete',
      destructive: true,
    );

    if (!shouldDelete) {
      return;
    }

    ref.read(exerciseViewModelProvider.notifier).deleteExercise(exerciseId);

    if (!context.mounted) {
      return;
    }

    AppFeedback.success(context, 'Exercise deleted');
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
      final matchesSearch = exercise.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );

      final matchesGroup =
          _selectedMuscleGroup == 'All' ||
          exercise.muscleGroup == _selectedMuscleGroup;

      return matchesSearch && matchesGroup;
    }).toList();
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Exercise Library',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExerciseScreen()),
          );
        },
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
        elevation: 3,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Exercise',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: Icon(Icons.search_rounded, color: primaryColor),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      ),
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

          const SizedBox(height: 8),
          // Exercise List or Empty States
          Expanded(
            child: exercisesAsync.isLoading
                ? const Center(child: CircularProgressIndicator())
                : exercisesAsync.hasError
                ? AsyncErrorView(
                    message: 'Could not load your exercises.',
                    onRetry: () => ref.invalidate(exerciseViewModelProvider),
                  )
                : exercises.isEmpty
                ? _buildEmptyState(
                    context,
                    title: 'No exercises yet',
                    subtitle:
                        'Add your first custom exercise to build your workout routines.',
                    icon: Icons.fitness_center_rounded,
                    primaryColor: primaryColor,
                    onPrimaryColor: onPrimaryColor,
                    showAddButton: true,
                  )
                : filteredExercises.isEmpty
                ? _buildEmptyState(
                    context,
                    title: 'No exercises found',
                    subtitle:
                        'No exercises match "$_searchQuery". Try searching for something else.',
                    icon: Icons.search_off_rounded,
                    primaryColor: primaryColor,
                    onPrimaryColor: onPrimaryColor,
                    showAddButton: false,
                  )
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
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
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                // Exercise Icon
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.fitness_center_rounded,
                                    color: primaryColor,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Title & Tags
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
                                                    ?.withValues(alpha: 0.6) ??
                                                Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Popup Menu Options
                                PopupMenuButton<String>(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddExerciseScreen(
                                                exercise: exercise,
                                              ),
                                        ),
                                      );
                                    }

                                    if (value == 'delete') {
                                      _confirmDelete(
                                        context,
                                        ref,
                                        exercise.id,
                                        exercise.name,
                                      );
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit_outlined, size: 18),
                                          SizedBox(width: 12),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete_outline_rounded,
                                            size: 18,
                                            color: theme.colorScheme.error,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: theme.colorScheme.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Icon(
                                      Icons.more_vert_rounded,
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                              ],
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

  Widget _buildEmptyState(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color primaryColor,
    required Color onPrimaryColor,
    required bool showAddButton,
  }) {
    final theme = Theme.of(context);

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
            if (showAddButton) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddExerciseScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: onPrimaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Add Exercise',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
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
