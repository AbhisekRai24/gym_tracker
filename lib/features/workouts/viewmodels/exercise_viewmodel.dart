import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/exercise.dart';
import '../repositories/exercise_repository.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepository();
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
}
