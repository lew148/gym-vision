import 'package:gymvision/classes/exercise_details.dart';
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

  Exercise({
    required this.identifier,
    required this.name,
    this.type = ExerciseType.other,
    this.primaryMuscleGroup = MuscleGroup.other,
    this.equipment = Equipment.other,
    this.categories = const <Category>{Category.other},
    this.exerciseDetails,
  });

  bool isCardio() => categories.contains(Category.cardio);

  String getFullName() => '$name (${equipment.displayName})';
}
