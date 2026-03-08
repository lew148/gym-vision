import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template_exercise.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/helpers/functions/toast_helper.dart';
import 'package:gymvision/helpers/ordering_helper.dart';
import 'package:gymvision/models/db_models/workout_template_model.dart';
import 'package:gymvision/widgets/components/custom_reorderable_list.dart';
import 'package:gymvision/widgets/components/notes.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/splash_text.dart';
import 'package:gymvision/widgets/debug_scaffold.dart';
import 'package:gymvision/widgets/forms/templates/template_exercise_widget.dart';
import 'package:gymvision/widgets/pages/homepages/exercises/exercises.dart';

class TemplateExercises extends StatelessWidget {
  final WorkoutTemplate template;
  final Function() reload;

  const TemplateExercises({
    super.key,
    required this.template,
    required this.reload,
  });

  @override
  Widget build(BuildContext context) {
    Future<void> onAddExerciseClick() async {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DebugScaffold(
            ignoreDefaults: false,
            body: Exercises(
              filterCategories: template.getCategories(),
              excludedExerciseIdentifiers:
                  template.getWorkoutTemplateExercises().map((we) => we.exerciseIdentifier).toList(),
              onAddTap: (String exerciseIdentifier) async {
                try {
                  await WorkoutTemplateModel.insertWorkoutTemplateExercise(
                    WorkoutTemplateExercise(
                      workoutTemplateId: template.id!,
                      exerciseIdentifier: exerciseIdentifier,
                      setOrder: '',
                    ),
                  );
                } catch (ex) {
                  if (context.mounted) {
                    ToastHelper.showFailureToast(context, message: 'Failed to add exercise to template!');
                  }
                } finally {
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
          ),
        ),
      );

      reload();
    }

    void onWorkoutExerciseReorder(int currentIndex, int newIndex) async {
      template.exerciseOrder = OrderingHelper.reorderByIndex(template.exerciseOrder, currentIndex, newIndex);
      await WorkoutTemplateModel.update(template);
    }

    return Column(children: [
      Row(children: [
        Expanded(child: Notes(type: NoteType.template, objectId: template.id!.toString())),
        Row(children: [
          Button(icon: Icons.add_rounded, onTap: onAddExerciseClick),
        ]),
      ]),
      Expanded(
        child: template.getWorkoutTemplateExercises().isEmpty
            ? Padding(
                padding: const EdgeInsetsGeometry.fromLTRB(30, 30, 30, 0), // b is 0 to avoid padding using keyboard
                child: Column(
                  children: [
                    const SplashText(title: 'Plan your perfect workout!', description: 'Create, customize, and reuse!'),
                    Button.outlined(icon: Icons.add_rounded, text: 'Add exercises', onTap: onAddExerciseClick),
                  ],
                ),
              )
            : CustomReorderableList(
                onReorder: onWorkoutExerciseReorder,
                children: OrderingHelper.sortByOrder(template.getWorkoutTemplateExercises(), template.exerciseOrder)
                    .map(
                      (we) => TemplateExerciseWidget(
                        key: ValueKey(we.id),
                        workoutTemplateExercise: we,
                        onDelete: (x) => reload(),
                      ),
                    )
                    .toList(),
              ),
      ),
    ]);
  }
}
