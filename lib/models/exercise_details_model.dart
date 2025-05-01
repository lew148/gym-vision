import 'package:gymvision/classes/exercise_details.dart';
import 'package:gymvision/db/db.dart';
import 'package:gymvision/models/db_models/workout_set_model.dart';
import 'package:sqflite/sqflite.dart';

class ExerciseDetailsModel {
  static Future<ExerciseDetails?> getExerciseDetails({
    required String exerciseIdentifier,
    required bool includeRecentUses,
    Database? existingDb,
  }) async {
    final db = await DatabaseHelper.getDb(existingDb: existingDb);
    return ExerciseDetails(
      exerciseIdentifier: exerciseIdentifier,
      // notes: map['notes'],
      pr: await WorkoutSetModel.getPr(exerciseIdentifier: exerciseIdentifier, existingDb: db),
      last: await WorkoutSetModel.getLast(exerciseIdentifier: exerciseIdentifier, existingDb: db),
      recentUses: includeRecentUses ? await WorkoutSetModel.getWorkoutSetsForExercise(exerciseIdentifier) : null,
    );
  }
}
