import 'package:gymvision/classes/exercise_details.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/static_data/helpers.dart';

class Exercise {
  String identifier; // internal identifier
  String name;
  ExerciseType type;
  Set<Category> categories;

  MuscleGroup primaryMuscleGroup;
  Set<MuscleGroup>? secondaryMuscleGroups;
  
  Equipment equipment;

  ExerciseDetails? exerciseDetails;

  Exercise({
    required this.identifier,
    required this.name,
    this.type = ExerciseType.other,
    this.primaryMuscleGroup = MuscleGroup.other,
    this.secondaryMuscleGroups,
    this.equipment = Equipment.other,
    this.categories = const <Category>{Category.other},
    this.exerciseDetails,
  });

  bool isCardio() => categories.contains(Category.cardio);

  String getFullName() => '${equipment == Equipment.other ? '' : ' (${equipment.displayName})'}$name';
}
