import 'package:collection/collection.dart';
import 'package:gymvision/models/exercise_details_model.dart';
import 'package:gymvision/classes/exercise.dart';
import 'package:gymvision/static_data/data/default_exercises.dart';
import 'package:gymvision/static_data/enums.dart';

class DefaultExercisesModel {
  static List<Exercise> getExercises({
    List<Category>? categories,
    List<String>? excludedExerciseIds,
    bool includeCardio = true,
  }) {
    var exercises = defaultExercises;

    if (categories != null && categories.isNotEmpty) {
      exercises = exercises.where((e) => e.categories.any(categories.contains)).toSet();
    }

    if (excludedExerciseIds != null && excludedExerciseIds.isNotEmpty) {
      exercises = exercises.where((e) => !excludedExerciseIds.contains(e.identifier)).toSet();
    }

    if (!includeCardio) {
      exercises = exercises.where((e) => !e.categories.contains(Category.cardio)).toSet();
    }

    var list = exercises.toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  static Future<Exercise?> getExerciseWithDetails({required String identifier, bool includeRecentUses = false}) async {
    var exercise = defaultExercises.firstWhereOrNull((e) => e.identifier == identifier);
    if (exercise == null) return null;

    exercise.exerciseDetails = await ExerciseDetailsModel.getExerciseDetails(
      exerciseIdentifier: identifier,
      includeRecentUses: includeRecentUses,
    );

    return exercise;
  }

  static Exercise? getExerciseByIdentifier(String identifier) =>
      defaultExercises.firstWhereOrNull((e) => e.identifier == identifier);
}
