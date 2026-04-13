import 'package:gymvision/classes/exercise_details.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/static_data/helpers.dart';

class Exercise {
  String identifier; // internal identifier
  String name;
  ExerciseType type;
  Set<Category> categories;

  LoadType loadType;
  Set<TrackingMetric> trackingMetrics;

  MuscleGroup? primaryMuscleGroup;
  Set<MuscleGroup>? secondaryMuscleGroups;

  Set<Equipment>? equipment;

  ExerciseDetails? exerciseDetails;

  Exercise({
    required this.identifier,
    required this.name,
    required this.type,
    this.categories = const <Category>{Category.other},
    required this.trackingMetrics,
    required this.loadType,
    this.primaryMuscleGroup,
    this.secondaryMuscleGroups,
    this.equipment = const <Equipment>{},
    this.exerciseDetails,
  });

  bool isCardio() => categories.contains(Category.cardio);

  bool hasEquipment() => equipment != null && equipment!.isNotEmpty;

  List<TrackingMetric> getOrderedTrackingMetrics() => TrackingMetric.values.where(trackingMetrics.contains).toList();
  List<Equipment> getOrderedEquipment() =>
      equipment == null ? [] : Equipment.values.where(equipment!.contains).toList();

  String getSecondaryMuscleGroupsString() {
    if (secondaryMuscleGroups == null || secondaryMuscleGroups!.isEmpty) return 'No Secondary Muscle Groups';
    return secondaryMuscleGroups!.map((e) => e.displayName).join(', ');
  }

  String getEquipmentString() {
    if (equipment == null || equipment!.isEmpty) return 'No Equipment';
    return getOrderedEquipment().map((e) => e.displayName).join(', ');
  }
}
