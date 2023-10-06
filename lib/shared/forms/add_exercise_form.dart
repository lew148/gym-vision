import 'package:flutter/material.dart';
import 'package:gymvision/db/helpers/exercises_helper.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/shared/forms/fields/custom_form_fields.dart';
import 'package:gymvision/shared/ui_helper.dart';
import '../../db/classes/exercise.dart';

class AddExerciseForm extends StatefulWidget {
  final void Function()? reloadState;
  final void Function(int)? onAdd;

  const AddExerciseForm({
    Key? key,
    this.reloadState,
    this.onAdd,
  }) : super(key: key);

  @override
  State<AddExerciseForm> createState() => _AddExerciseFormState();
}

class _AddExerciseFormState extends State<AddExerciseForm> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  ExerciseType? type;
  MuscleGroup? muscleGroup;
  ExerciseEquipment? equipment;
  ExerciseSplit? split;
  bool isDouble = false;

  void onSubmit() async {
    if (formKey.currentState!.validate()) {
      Navigator.pop(context);

      try {
        var id = await ExercisesHelper.insertExercise(Exercise(
          name: nameController.text,
          exerciseType: type == null ? ExerciseType.other : type!,
          muscleGroup: muscleGroup == null ? MuscleGroup.other : muscleGroup!,
          equipment: equipment == null ? ExerciseEquipment.other : equipment!,
          split: split == null ? ExerciseSplit.other : split!,
          isDouble: isDouble,
        ));

        if (widget.onAdd != null) widget.onAdd!(id);
      } catch (ex) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add Exercise')));
      }

      if (widget.reloadState != null) widget.reloadState!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          getSectionTitle(context, 'Add Exercise'),
          const Divider(),
          Form(
            key: formKey,
            child: Column(
              children: [
                CustomFormFields.stringField(
                    controller: nameController, label: 'Name', autofocus: true, canBeBlank: false),
                CustomFormFields.enumDropdown<ExerciseType?>(
                  'Exercise Type',
                  type,
                  ExerciseType.values,
                  (ExerciseType? n) => setState(() {
                    type = n;
                  }),
                ),
                CustomFormFields.enumDropdown<MuscleGroup?>(
                  'Muscle Group',
                  muscleGroup,
                  MuscleGroup.values,
                  (MuscleGroup? n) => setState(() {
                    muscleGroup = n;
                  }),
                ),
                CustomFormFields.enumDropdown<ExerciseEquipment?>(
                  'Equipment',
                  equipment,
                  ExerciseEquipment.values,
                  (ExerciseEquipment? n) => setState(() {
                    equipment = n;
                  }),
                ),
                CustomFormFields.enumDropdown<ExerciseSplit?>(
                  'Exercise Split',
                  split,
                  ExerciseSplit.values,
                  (ExerciseSplit? n) => setState(() {
                    split = n;
                  }),
                ),
                Row(children: [
                  Checkbox(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    checkColor: Colors.white,
                    activeColor: Theme.of(context).colorScheme.primary,
                    value: isDouble,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    onChanged: (bool? value) => setState(() {
                      isDouble = !isDouble;
                    }),
                  ),
                  Text('Double?'),
                ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: ElevatedButton(
                        onPressed: onSubmit,
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
