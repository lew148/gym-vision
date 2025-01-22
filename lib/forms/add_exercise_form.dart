// import 'package:flutter/material.dart';
// import 'package:gymvision/db/helpers/exercises_helper.dart';
// import 'package:gymvision/shared/forms/fields/custom_form_fields.dart';
// import '../../db/classes/exercise.dart';
// import '../../globals.dart';

// class AddExerciseForm extends StatefulWidget {
//   final int categoryId;
//   final void Function() reloadState;

//   const AddExerciseForm({
//     Key? key,
//     required this.categoryId,
//     required this.reloadState,
//   }) : super(key: key);

//   @override
//   State<AddExerciseForm> createState() => _AddExerciseFormState();
// }

// class _AddExerciseFormState extends State<AddExerciseForm> {
//   final formKey = GlobalKey<FormState>();
//   final nameController = TextEditingController();
//   final weightController = TextEditingController();
//   final repsController = TextEditingController();
//   bool isDoubleValue = false;

//   void onSubmit() async {
//     if (formKey.currentState!.validate()) {
//       Navigator.pop(context);

//       try {
//         await ExercisesHelper.insertExercise(Exercise(
//           categoryId: widget.categoryId,
//           name: nameController.text,
//           weight: double.parse(getNumberStringOrDefault(weightController.text)),
//           max: 0, // to set in edit
//           reps: int.parse(getNumberStringOrDefault(repsController.text)),
//           isSingle: !isDoubleValue,
//         ));
//       } catch (ex) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to add exercise')),
//         );
//       }

//       widget.reloadState();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         children: [
//           const Text(
//             'Add Exercise',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//           ),
//           Form(
//             key: formKey,
//             child: Column(
//               children: [
//                 CustomFormFields.stringField(
//                     controller: nameController,
//                     label: 'Name',
//                     autofocus: true,
//                     canBeBlank: false),
//                 CustomFormFields.weightField(
//                   controller: weightController,
//                   label: 'Weight',
//                   isSingle: !isDoubleValue,
//                 ),
//                 CustomFormFields.intField(
//                   controller: repsController,
//                   label: 'Reps',
//                   selectableValues: [1, 8, 12],
//                 ),
//                 CustomFormFields.checkbox(
//                   context,
//                   'Double Weight',
//                   isDoubleValue,
//                   (value) => {setState(() => isDoubleValue = value!)},
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(top: 20.0),
//                       child: ElevatedButton(
//                         onPressed: onSubmit,
//                         child: const Text('Save'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
