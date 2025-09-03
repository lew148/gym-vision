import 'package:gymvision/classes/db/bodyweight.dart';
import 'package:gymvision/classes/db/flavour_text_schedule.dart';
import 'package:gymvision/classes/db/note.dart';
import 'package:gymvision/classes/db/schedules/schedule.dart';
import 'package:gymvision/classes/db/schedules/schedule_category.dart';
import 'package:gymvision/classes/db/schedules/schedule_item.dart';
import 'package:gymvision/classes/db/user_settings.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/classes/db/workouts/workout_category.dart';
import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
import 'package:gymvision/classes/db/workouts/workout_set.dart';
import 'package:gymvision/db/drift_database.dart';
import 'package:gymvision/models/default_exercises_model.dart';

extension DriftSettingX on DriftSetting {
  UserSettings toObject() => UserSettings(
        id: id,
        updatedAt: updatedAt,
        createdAt: createdAt,
        theme: theme,
        intraSetRestTimer: intraSetRestTimer,
      );
}

extension DriftBodyweightX on DriftBodyweight {
  Bodyweight toObject() => Bodyweight(
        id: id,
        updatedAt: updatedAt,
        createdAt: createdAt,
        date: date,
        weight: weight,
        units: units,
      );
}

extension DriftFlavourTextScheduleX on DriftFlavourTextSchedule {
  FlavourTextSchedule toObject() => FlavourTextSchedule(
        id: id,
        updatedAt: updatedAt,
        createdAt: createdAt,
        flavourTextId: flavourTextId,
        date: date,
        dismissed: dismissed,
      );
}

extension DriftNoteX on DriftNote {
  Note toObject() => Note(
        id: id,
        updatedAt: updatedAt,
        createdAt: createdAt,
        objectId: objectId,
        type: type,
        note: note,
      );
}

extension DriftWorkoutX on DriftWorkout {
  Workout toObject() => Workout(
        id: id,
        updatedAt: updatedAt,
        createdAt: createdAt,
        date: date,
        endDate: endDate,
        exerciseOrder: exerciseOrder,
      );
}

extension DriftWorkoutCategoryX on DriftWorkoutCategory {
  WorkoutCategory toObject() => WorkoutCategory(
        id: id,
        updatedAt: updatedAt,
        createdAt: createdAt,
        workoutId: workoutId,
        category: category,
      );
}

extension DriftWorkoutExerciseX on DriftWorkoutExercise {
  WorkoutExercise toObject() => WorkoutExercise(
        id: id,
        updatedAt: updatedAt,
        createdAt: createdAt,
        workoutId: workoutId,
        exerciseIdentifier: exerciseIdentifier,
        done: done,
        setOrder: setOrder,
        exercise: DefaultExercisesModel.getExerciseByIdentifier(exerciseIdentifier),
      );
}

extension DriftWorkoutSetX on DriftWorkoutSet {
  WorkoutSet toObject() => WorkoutSet(
        id: id,
        updatedAt: updatedAt,
        createdAt: createdAt,
        workoutExerciseId: workoutExerciseId,
        weight: weight,
        reps: reps,
        time: time,
        distance: distance,
        calsBurned: calsBurned,
        done: done,
      );
}

extension DriftScheduleX on DriftSchedule {
  Schedule toObject() => Schedule(
        id: id,
        updatedAt: updatedAt,
        createdAt: createdAt,
        name: name,
        type: type,
        active: active,
        startDate: startDate,
      );
}

extension DriftScheduleItemX on DriftScheduleItem {
  ScheduleItem toObject() => ScheduleItem(
        id: id,
        updatedAt: updatedAt,
        createdAt: createdAt,
        scheduleId: scheduleId,
        itemOrder: itemOrder,
        );
}

extension DriftScheduleCategoryX on DriftScheduleCategory {
  ScheduleCategory toObject() => ScheduleCategory(
        id: id,
        updatedAt: updatedAt,
        createdAt: createdAt,
        scheduleItemId: scheduleItemId,
        category: category,
      );
}
