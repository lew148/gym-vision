import 'package:gymvision/db/classes/user_exercise_details.dart';

import '../../enums.dart';

class Exercise {
  int? id;
  int? userId;
  String name;
  ExerciseType exerciseType;
  MuscleGroup muscleGroup;
  ExerciseEquipment equipment;
  ExerciseSplit split;
  // true if can be done BOTH bilaterally and unilaterally (defaults to bilateral in set)
  bool uniAndBiLateral;

  UserExerciseDetails? userExerciseDetails;

  Exercise({
    this.id,
    this.userId,
    required this.name,
    this.exerciseType = ExerciseType.other,
    this.muscleGroup = MuscleGroup.other,
    this.equipment = ExerciseEquipment.other,
    this.split = ExerciseSplit.other,
    this.uniAndBiLateral = false,
    this.userExerciseDetails,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'exerciseType': exerciseType,
        'muscleGroup': muscleGroup,
        'equipment': equipment,
        'split': split,
        'uniAndBiLateral': uniAndBiLateral,
      };
}
