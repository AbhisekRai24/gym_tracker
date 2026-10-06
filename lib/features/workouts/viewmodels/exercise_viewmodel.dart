import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_track/core/storage/hive_boxes.dart';
import 'package:hive_flutter/hive_flutter.dart';


import '../models/exercise.dart';
import '../repositories/exercise_repository.dart';


final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  final box = Hive.box(HiveBoxes.exercises);

  return ExerciseRepository(box);
});

final exerciseViewModelProvider =
    NotifierProvider<ExerciseViewModel, List<Exercise>>(ExerciseViewModel.new);

class ExerciseViewModel extends Notifier<List<Exercise>> {
  late final ExerciseRepository _repository;

  @override
  List<Exercise> build() {
    _repository = ref.watch(exerciseRepositoryProvider);

    return _repository.getExercises();
  }

  void addExercise({
    required String name,
    required String muscleGroup,
    required String equipment,
  }) {
    final exercise = Exercise(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      muscleGroup: muscleGroup,
      equipment: equipment,
    );

    _repository.addExercise(exercise);

    state = _repository.getExercises();
  }

  void updateExercise(Exercise exercise) {
    _repository.updateExercise(exercise);

    state = _repository.getExercises();
  }

  void deleteExercise(String exerciseId) {
    _repository.deleteExercise(exerciseId);

    state = _repository.getExercises();
  }
}
