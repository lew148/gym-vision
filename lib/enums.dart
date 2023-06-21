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

enum WorkoutCategoryType {
  muscleGroup,
  split,
  cardio,
  // ignore: constant_identifier_names
  Class,
  other,
}

enum ExerciseType {
  cardio,
  stretch,
  weight, // includes body-weight
  other,
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

enum ExerciseSplit {
  push,
  pull,
  legs,
  other,
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
