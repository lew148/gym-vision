import 'package:gymvision/classes/exercise_details.dart';
import 'package:gymvision/db/custom_database.dart';
import 'package:gymvision/db/db.dart';
import 'package:gymvision/models/db_models/workout_set_model.dart';

class ExerciseDetailsModel {
  static Future<ExerciseDetails?> getExerciseDetails({
    required String exerciseIdentifier,
    required bool includeRecentUses,
    CustomDatabase? db,
  }) async {
    db ??= await DatabaseHelper.getDb();
    return ExerciseDetails(
      exerciseIdentifier: exerciseIdentifier,
      // notes: map['notes'],
      pr: await WorkoutSetModel.getPr(exerciseIdentifier: exerciseIdentifier, db: db),
      last: await WorkoutSetModel.getLast(exerciseIdentifier: exerciseIdentifier, db: db),
      recentUses: includeRecentUses ? await WorkoutSetModel.getWorkoutSetsForExercise(exerciseIdentifier) : null,
    );
  }
}
