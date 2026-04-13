enum ExerciseType {
  strength,
  cardio,
  stretch,
  other,
}

// trackable fields for WorkoutSet
enum TrackingMetric {
  weight,
  addedWeight,
  assistedWeight,
  reps,
  time,
  distance,
  calsBurned,
}

enum LoadType {
  externalWeight, // only external weight (DBs, machines, etc.)
  bodyweightOnly, // only BW
  assisted, // BW - assistance
  weighted, // BW + external weight
  noLoad, // no load (e.g. cardio, stretches)
}

enum Category {
  push,
  pull,
  legs,
  // fullBody,
  upperBody,
  lowerBody,
  arms,
  back,
  biceps,
  triceps,
  shoulders,
  chest,
  core,
  cardio,
  other,
}

enum MuscleGroup {
  chest,
  frontDelts,
  sideDelts,
  rearDelts,
  biceps,
  triceps,
  quadriceps,
  hamstrings,
  glutes,
  core,
  forearms,
  calves,
  abductors,
  adductors,
  lats,
  lowerBack,
  traps,
  upperBack,
  other,
}

enum Equipment {
  none,
  barbell,
  bodyweight,
  cable,
  dumbbell,
  kettlebell,
  machine,
  plates,
  resistanceBand,
  medicineBall,
  smithMachine,
  other,
}
