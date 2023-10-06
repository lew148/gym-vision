import 'package:gymvision/db/classes/user_exercise_details.dart';

import '../../enums.dart';

class Exercise {
  int? id;
  String name;
  ExerciseType exerciseType;
  MuscleGroup muscleGroup;
  ExerciseEquipment equipment;
  ExerciseSplit split;
  bool isDouble;
  bool isCustom;

  UserExerciseDetails? userExerciseDetails;

  Exercise({
    this.id,
    required this.name,
    this.exerciseType = ExerciseType.other,
    this.muscleGroup = MuscleGroup.other,
    this.equipment = ExerciseEquipment.other,
    this.split = ExerciseSplit.other,
    this.isDouble = false,
    this.isCustom = false,
    this.userExerciseDetails,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'exerciseType': exerciseType.index,
        'muscleGroup': muscleGroup.index,
        'equipment': equipment.index,
        'split': split.index,
        'isDouble': isDouble,
        'isCustom': isCustom,
      };
}
