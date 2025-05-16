import 'package:flutter_test/flutter_test.dart';
import 'package:gymvision/static_data/data/default_exercises.dart';

// flutter test test/static_data_tests.dart

void main() {
  test('Test Default Exercise Identifiers are Unique', () {
    final ids = <String>[];
    for (var exercise in defaultExercises) {
      expect(exercise.identifier, isNotNull);
      expect(exercise.identifier, isNotEmpty);

      final isDupe = ids.contains(exercise.identifier);
      if (isDupe) {
        fail("ID: '${exercise.identifier}' is duplicated");
      }

      ids.add(exercise.identifier);
    }
  });

  test('Test Same-Named Default Exercises are Char Limited', () {
    for (var exercise in defaultExercises) {
      if (defaultExercises.where((e) => e.name == exercise.name).length <= 1) return;
      if (exercise.name.length > 20) fail('Exercises: ${exercise.name} have names too long to append equipment to');
    }
  });
}
