import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/bodyweight.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/classes/db/workouts/workout_category.dart';
import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/helpers/enum_helper.dart';
import 'package:gymvision/models/db_models/bodyweight_model.dart';
import 'package:gymvision/models/db_models/workouts/workout_category_model.dart';
import 'package:gymvision/models/db_models/workouts/workout_exercise_model.dart';
import 'package:gymvision/models/db_models/workouts/workout_model.dart';
import 'package:gymvision/models/db_models/workouts/workout_set_model.dart';
import 'package:gymvision/providers/global/rest_timer_provider.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:provider/provider.dart';

class AppHelper {
  static bool isDarkMode(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  static void closeKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  static void showSnackBar(BuildContext context, String text) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  static void setRestTimer(BuildContext context, Duration duration) =>
      Provider.of<RestTimerProvider>(context, listen: false).setTimer(context: context, duration: duration);

  static Future<String?> getFullExportString() async {
    final exportMap = {};
    exportMap['bodyweights'] = (await BodyweightModel.getBodyweights()).map((bw) => bw.toMap()).toList();
    exportMap['workouts'] = await getWorkoutsExportString();
    return jsonEncode(exportMap);
  }

  static Future<List<Map>> getWorkoutsExportString() async {
    final List<Map> workoutMaps = [];
    final allWorkouts = await WorkoutModel.getAllWorkouts(withExercises: true);

    for (final workout in allWorkouts) {
      final workoutExercisesMap = workout.workoutExercises?.map((we) => we.toMap()).toList();
      if (workoutExercisesMap != null) {
        for (int i = 0; i < workoutExercisesMap.length; i++) {
          final weMap = workoutExercisesMap[i];
          weMap['sets'] = workout.workoutExercises
              ?.firstWhereOrNull((w) => w.id == weMap['id'])
              ?.workoutSets
              ?.map((ws) => ws.toMap())
              .toList();
        }
      }

      workoutMaps.add({
        ...workout.toMap(),
        'categories': workout.workoutCategories?.map((wc) => wc.getCategoryEnumString()).toList(),
        'workoutExercises': workoutExercisesMap,
      });
    }

    return workoutMaps;
  }

  static Future<bool> importData(String input) async {
    if (input.isEmpty) return false;

    final maps = jsonDecode(input);
    final bodyWeightMaps = maps['bodyweights'];
    final workoutMaps = maps['workouts'];

    if (bodyWeightMaps != null) {
      for (final bw in bodyWeightMaps) {
        await BodyweightModel.insert(Bodyweight(
          date: DateTimeHelper.parseDateTime(bw['date']),
          weight: bw['weight'],
          units: bw['units'],
        ));
      }
    }

    if (workoutMaps == null) return true;

    for (final w in workoutMaps) {
      final categoriesMap = w['categories'];
      final exercisesMap = w['workoutExercises'];

      final workoutId = await WorkoutModel.insert(Workout(
        date: DateTimeHelper.parseDateTime(w['date']),
        endDate: DateTimeHelper.tryParseDateTime(w['endDate']),
        exerciseOrder: '',
      ));

      if (workoutId == 0) continue;

      if (categoriesMap != null) {
        for (final c in categoriesMap) {
          final cat = EnumHelper.stringToEnum(c, Category.values);
          if (cat == null) continue;
          await WorkoutCategoryModel.insert(WorkoutCategory(workoutId: workoutId, category: cat));
        }
      }

      if (exercisesMap == null) continue;

      for (final we in exercisesMap) {
        final workoutExerciseId = await WorkoutExerciseModel.insert(WorkoutExercise(
          workoutId: workoutId,
          exerciseIdentifier: we['exerciseIdentifier'],
          done: we['done'] == 1,
          setOrder: '',
        ));

        if (workoutExerciseId == 0) continue;

        final setsMap = we['sets'];
        if (setsMap == null) continue;

        for (final s in setsMap) {
          await WorkoutSetModel.insert(WorkoutSet(
            workoutExerciseId: workoutExerciseId,
            done: s['done'] == 1,
            weight: s['weight'],
            reps: s['reps'],
            time: DateTimeHelper.tryParseDuration(s['time']),
            distance: s['distance'],
            calsBurned: s['calsBurned'],
          ));
        }
      }
    }

    return true;
  }
}
