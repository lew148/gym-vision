import 'package:gymvision/classes/exercise_details.dart';
import 'package:gymvision/static_data/data/default_exercises.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/static_data/helpers.dart';

class Exercise {
  String identifier; // gymvision-made exercise identifier
  String name;
  ExerciseType type;
  MuscleGroup primaryMuscleGroup;
  Equipment equipment;
  Set<Category> categories;
  ExerciseDetails? exerciseDetails;

  // deprecated / subject to change
  // int? id;

  Exercise({
    required this.identifier,
    required this.name,
    // this.id,
    this.type = ExerciseType.other,
    this.primaryMuscleGroup = MuscleGroup.other,
    this.equipment = Equipment.other,
    this.categories = const <Category>{Category.other},
    this.exerciseDetails,
  });

  bool isCardio() => categories.contains(Category.cardio);

  String getName() => name.length > 20
      ? name
      : '$name ${defaultExercises.where((e) => e.name == e.name).length > 1 ? '(${equipment.displayName})' : ''}';
}
