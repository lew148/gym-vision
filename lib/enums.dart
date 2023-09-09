import 'package:gymvision/shared/workout_category_helper.dart';

enum ExerciseEditableField {
  name,
  weight,
  max,
  reps,
}

enum ThemeSetting {
  light,
  dark,
  system,
}

//
// ** enums below are replictaed from GymVisionApi -> Enums.cs **
//

String muscleGroupDisplayName = "💪 Muscle Group";
String splitDisplayName = "🪓 Push/Pull";
String cardioDisplayName = "💦 Cardio";
String classDisplayName = "🍀 Class";

String stretchDisplayName = "🧘 Stretch";
String weightDisplayName = "🏋️ Weight";

String backDisplayName = "🎒 Back";
String bicepsDisplayName = "💪 Biceps";
String chestDisplayName = "🍒 Chest";
String coreDisplayName = "🍎 Core";
String forearmsDisplayName = "🪵 Forearms";
String hamstringsAndGlutesDisplayName = "🍑 Hamstrings & Glutes";
String quadsAndCalvesDisplayName = "🦵 Quads & Calves";
String shouldersDisplayName = "🪨 Shoulders";
String tricepsDisplayName = "🔱 Triceps";

String pushDisplayName = "✋ Push";
String pullDisplayName = "✊ Pull";
String legsDisplayName = "🦵 Legs";

String noneDisplayName = "No Equipment";
String barbellDisplayName = "Barbell";
String bodyWeightDisplayName = "Bodyweight";
String cableDisplayName = "Cable";
String dumbbellDisplayName = "Dumbell";
String kettlebellDisplayName = "Kettlebell";
String machineDisplayName = "Machine";
String platesDisplayName = "Plates";

String otherDisplayName = "❔ Other";

enum WorkoutCategoryType {
  muscleGroup,
  split,
  cardio,
  stretch,
  // ignore: constant_identifier_names
  Class,
  other,
}

extension WorkoutCategoryTypeHelper on WorkoutCategoryType {
  String get displayName {
    switch (this) {
      case WorkoutCategoryType.muscleGroup:
        return muscleGroupDisplayName;
      case WorkoutCategoryType.split:
        return splitDisplayName;
      case WorkoutCategoryType.stretch:
        return stretchDisplayName;
      case WorkoutCategoryType.cardio:
        return cardioDisplayName;
      case WorkoutCategoryType.Class:
        return classDisplayName;
      case WorkoutCategoryType.other:
        return otherDisplayName;
    }
  }
}

enum ExerciseType {
  cardio,
  stretch,
  weight, // includes body-weight
  other,
}

extension ExerciseTypeHelper on ExerciseType {
  String get displayName {
    switch (this) {
      case ExerciseType.cardio:
        return cardioDisplayName;
      case ExerciseType.stretch:
        return stretchDisplayName;
      case ExerciseType.weight:
        return weightDisplayName;
      case ExerciseType.other:
        return otherDisplayName;
    }
  }

  WorkoutCategoryShell get categoryShell =>
      WorkoutCategoryHelper.getMiscCategoryShells().firstWhere((e) => e.displayName == displayName);
}

enum MuscleGroup {
  back,
  biceps,
  chest,
  core,
  forearms,
  hamstringsAndGlutes,
  quadsAndCalves,
  shoulders,
  triceps,
  other,
}

extension MuscleGroupHelper on MuscleGroup {
  String get displayName {
    switch (this) {
      case MuscleGroup.back:
        return backDisplayName;
      case MuscleGroup.biceps:
        return bicepsDisplayName;
      case MuscleGroup.chest:
        return chestDisplayName;
      case MuscleGroup.core:
        return coreDisplayName;
      case MuscleGroup.forearms:
        return forearmsDisplayName;
      case MuscleGroup.hamstringsAndGlutes:
        return hamstringsAndGlutesDisplayName;
      case MuscleGroup.quadsAndCalves:
        return quadsAndCalvesDisplayName;
      case MuscleGroup.shoulders:
        return shouldersDisplayName;
      case MuscleGroup.triceps:
        return tricepsDisplayName;
      case MuscleGroup.other:
        return otherDisplayName;
    }
  }

  WorkoutCategoryShell get categoryShell =>
      WorkoutCategoryHelper.getMuscleGroupCategoryShells().firstWhere((e) => e.displayName == displayName);
}

enum ExerciseSplit {
  push,
  pull,
  legs,
  other,
}

extension ExerciseSplitHelper on ExerciseSplit {
  String get displayName {
    switch (this) {
      case ExerciseSplit.push:
        return pushDisplayName;
      case ExerciseSplit.pull:
        return pullDisplayName;
      case ExerciseSplit.legs:
        return legsDisplayName;
      case ExerciseSplit.other:
        return otherDisplayName;
    }
  }

  WorkoutCategoryShell get categoryShell =>
      WorkoutCategoryHelper.getSplitCategoryShells().firstWhere((e) => e.displayName == displayName);
}

enum ExerciseEquipment {
  none,
  barbell,
  bodyWeight,
  cable,
  dumbbell,
  kettlebell,
  machine,
  plates,
  other,
}

extension ExerciseEquipmentHelper on ExerciseEquipment {
  String get displayName {
    switch (this) {
      case ExerciseEquipment.none:
        return noneDisplayName;
      case ExerciseEquipment.barbell:
        return barbellDisplayName;
      case ExerciseEquipment.bodyWeight:
        return bodyWeightDisplayName;
      case ExerciseEquipment.cable:
        return cableDisplayName;
      case ExerciseEquipment.dumbbell:
        return dumbbellDisplayName;
      case ExerciseEquipment.kettlebell:
        return kettlebellDisplayName;
      case ExerciseEquipment.machine:
        return machineDisplayName;
      case ExerciseEquipment.plates:
        return platesDisplayName;
      case ExerciseEquipment.other:
        return otherDisplayName;
    }
  }
}
