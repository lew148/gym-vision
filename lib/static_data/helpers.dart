import 'package:gymvision/static_data/enums.dart';

String otherDisplayName = "Other";

extension ExerciseTypeHelper on ExerciseType {
  String get displayName {
    switch (this) {
      case ExerciseType.cardio:
        return '💦 Cardio';
      case ExerciseType.strength:
        return '🏋️ Strength';
      case ExerciseType.stretch:
        return '🧘 Stretch';
      case ExerciseType.other:
        return otherDisplayName;
    }
  }
}

extension MuscleGroupHelper on MuscleGroup {
  String get displayNamePlain {
    switch (this) {
      case MuscleGroup.abductors:
        return 'Abductors';
      case MuscleGroup.adductors:
        return 'Adductors';
      case MuscleGroup.upperBack:
        return 'Upper Back';
      case MuscleGroup.lowerBack:
        return 'Lower Back';
      case MuscleGroup.lats:
        return 'Lats';
      case MuscleGroup.biceps:
        return 'Biceps';
      case MuscleGroup.calves:
        return 'Calves';
      case MuscleGroup.chest:
        return 'Chest';
      case MuscleGroup.core:
        return 'Core';
      case MuscleGroup.forearms:
        return 'Forearms';
      case MuscleGroup.glutes:
        return 'Glutes';
      case MuscleGroup.hamstrings:
        return 'Hamstrings';
      case MuscleGroup.quadriceps:
        return 'Quads';
      case MuscleGroup.frontDelts:
        return 'Front Delts';
      case MuscleGroup.sideDelts:
        return 'Side Delts';
      case MuscleGroup.rearDelts:
        return 'Rear Delts';
      case MuscleGroup.triceps:
        return 'Triceps';
      case MuscleGroup.traps:
        return 'Traps';
      case MuscleGroup.other:
        return otherDisplayName;
    }
  }

  String get displayName {
    switch (this) {
      case MuscleGroup.abductors:
        return 'Abductors';
      case MuscleGroup.adductors:
        return 'Adductors';
      case MuscleGroup.upperBack:
        return '🎒 Upper Back';
      case MuscleGroup.lowerBack:
        return '🎄 Lower Back';
      case MuscleGroup.lats:
        return '⌛ Lats';
      case MuscleGroup.biceps:
        return '💪 Biceps';
      case MuscleGroup.calves:
        return 'Calves';
      case MuscleGroup.chest:
        return '🍒 Chest';
      case MuscleGroup.core:
        return '🍎 Core';
      case MuscleGroup.forearms:
        return '🪵 Forearms';
      case MuscleGroup.glutes:
        return '🍑 Glutes';
      case MuscleGroup.hamstrings:
        return '🦵 Hamstrings';
      case MuscleGroup.quadriceps:
        return '🦵 Quads';
      case MuscleGroup.frontDelts:
        return '🪨 Front Delts';
      case MuscleGroup.sideDelts:
        return '🪨 Side Delts';
      case MuscleGroup.rearDelts:
        return '🪨 Rear Delts';
      case MuscleGroup.triceps:
        return '🔱 Triceps';
      case MuscleGroup.traps:
        return '🗻 Traps';
      case MuscleGroup.other:
        return otherDisplayName;
    }
  }
}

extension CategoryHelper on Category {
  String get displayNamePlain {
    switch (this) {
      case Category.upperBody:
        return 'Upper Body';
      case Category.lowerBody:
        return 'Lower Body';
      case Category.push:
        return 'Push';
      case Category.pull:
        return 'Pull';
      case Category.legs:
        return 'Legs';
      // case Category.fullBody:
      //   return '💯 Full Body';
      case Category.arms:
        return 'Arms';
      case Category.back:
        return 'Back';
      case Category.biceps:
        return 'Biceps';
      case Category.triceps:
        return 'Triceps';
      case Category.shoulders:
        return 'Shoulders';
      case Category.chest:
        return 'Chest';
      case Category.core:
        return 'Core';
      case Category.other:
        return otherDisplayName;
      case Category.cardio:
        return 'Cardio';
    }
  }

  String get displayName {
    switch (this) {
      case Category.upperBody:
        return '👆 Upper Body';
      case Category.lowerBody:
        return '👇 Lower Body';
      case Category.push:
        return '✋ Push';
      case Category.pull:
        return '✊ Pull';
      case Category.legs:
        return '🦵 Legs';
      // case Category.fullBody:
      //   return '💯 Full Body';
      case Category.arms:
        return '💪 Arms';
      case Category.back:
        return '🎒 Back';
      case Category.biceps:
        return '💪 Biceps';
      case Category.triceps:
        return '🔱 Triceps';
      case Category.shoulders:
        return '🪨 Shoulders';
      case Category.chest:
        return '🍒 Chest';
      case Category.core:
        return '🍎 Core';
      case Category.other:
        return otherDisplayName;
      case Category.cardio:
        return '💦 Cardio';
    }
  }
}

extension EquipmentHelper on Equipment {
  String get displayName {
    switch (this) {
      case Equipment.none:
        return 'None';
      case Equipment.barbell:
        return 'Barbell';
      case Equipment.bodyweight:
        return 'Bodyweight';
      case Equipment.cable:
        return 'Cable';
      case Equipment.dumbbell:
        return 'Dumbbell';
      case Equipment.kettlebell:
        return 'Kettlebell';
      case Equipment.machine:
        return 'Machine';
      case Equipment.plates:
        return 'Plates';
      case Equipment.resistanceBand:
        return 'Resistance Band';
      case Equipment.other:
        return otherDisplayName;
      case Equipment.medicineBall:
        return 'Medicine Ball';
      case Equipment.smithMachine:
        return 'Smith Machine';
    }
  }
}

class SplitHelper {
  static Set<Category> splitCategories = {
    Category.upperBody,
    Category.lowerBody,
    // Category.fullBody,
  };

  static Set<Category> split2Categories = {
    Category.push,
    Category.pull,
    Category.legs,
    Category.arms,
  };

  static Set<Category> muscleGroupCategories = {
    Category.back,
    Category.biceps,
    Category.triceps,
    Category.shoulders,
    Category.chest,
    Category.core,
  };

  static Set<Category> miscCategories = {
    Category.cardio,
  };
}
