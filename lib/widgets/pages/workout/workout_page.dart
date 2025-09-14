// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:gymvision/classes/db/workouts/workout.dart';
// import 'package:gymvision/classes/db/workouts/workout_category.dart';
// import 'package:gymvision/classes/db/workouts/workout_exercise.dart';
// import 'package:gymvision/widgets/notes.dart';
// import 'package:gymvision/enums.dart';
// import 'package:gymvision/helpers/datetime_helper.dart';
// import 'package:gymvision/helpers/ordering_helper.dart';
// import 'package:gymvision/models/db_models/workout_category_model.dart';
// import 'package:gymvision/models/db_models/workout_model.dart';
// import 'package:gymvision/helpers/common_functions.dart';
// import 'package:gymvision/widgets/debug_scaffold.dart';
// import 'package:gymvision/widgets/pages/workout/workout_view.dart';
// import 'package:gymvision/widgets/rest_timer.dart';
// import 'package:gymvision/widgets/forms/category_picker.dart';
// import 'package:gymvision/widgets/common/common_ui.dart';
// import 'package:gymvision/widgets/forms/add_exercises_to_workout.dart';
// import 'package:gymvision/widgets/time_elapsed_widget.dart';
// import 'package:gymvision/widgets/pages/workout/workout_exercise_widget.dart';
// import 'package:gymvision/static_data/enums.dart';
// import 'package:reorderables/reorderables.dart';

// class WorkoutPage extends StatefulWidget {
//   final int workoutId;
//   final bool autofocusNotes;
//   final Function? reloadParent;

//   const WorkoutPage({
//     super.key,
//     required this.workoutId,
//     this.autofocusNotes = false,
//     this.reloadParent,
//   });

//   @override
//   State<WorkoutPage> createState() => _WorkoutPageState();
// }

// class _WorkoutPageState extends State<WorkoutPage> {
//   late Future<Workout?> workoutFuture;
//   List<int> droppedWes = [];
//   late bool workoutIsFinished;

//   @override
//   void initState() {
//     super.initState();
//     workoutFuture = WorkoutModel.getWorkout(widget.workoutId, withCategories: true, withWorkoutExercises: true);
//   }

//   void reloadState() => setState(() {
//         workoutFuture = WorkoutModel.getWorkout(widget.workoutId, withCategories: true, withWorkoutExercises: true);
//       });


//   void showEditDate(Workout workout) => showDateTimePicker(
//         context,
//         initialDateTime: workout.date,
//         CupertinoDatePickerMode.date,
//         (DateTime dt) async {
//           try {
//             workout.date =
//                 DateTime(dt.year, dt.month, dt.day, workout.date.hour, workout.date.minute, workout.date.second);
//             await WorkoutModel.update(workout);
//             reloadState();
//           } catch (ex) {
//             // do nothing
//           }
//         },
//       );

//   void showEditTime(Workout workout) => showDateTimePicker(
//         context,
//         initialDateTime: workout.date,
//         CupertinoDatePickerMode.time,
//         (DateTime dt) async {
//           try {
//             workout.date =
//                 DateTime(workout.date.year, workout.date.month, workout.date.day, dt.hour, dt.minute, dt.second);
//             await WorkoutModel.update(workout);
//             reloadState();
//           } catch (ex) {
//             // do nothing
//           }
//         },
//       );

//   void showEditEndTime(Workout workout) => showDateTimePicker(
//         context,
//         initialDateTime: workout.endDate,
//         CupertinoDatePickerMode.dateAndTime,
//         (DateTime dt) async {
//           try {
//             workout.endDate = dt;
//             await WorkoutModel.update(workout);
//             reloadState();
//           } catch (ex) {
//             // do nothing
//           }
//         },
//       );

//   void showMoreMenu(Workout workout) => showOptionsMenu(
//         context,
//         [
//           //   ButtonDetails(
//           //     onTap: () async {
//           //       Navigator.pop(context);

//           //       try {
//           //         final exportString = await WorkoutModel.getWorkoutExportString(workout.id!);
//           //         if (exportString == null) throw Exception();
//           //         await Clipboard.setData(ClipboardData(text: exportString));
//           //         if (mounted) showSnackBar(context, 'Workout copied to clipboard!');
//           //       } catch (ex) {
//           //         if (mounted) showSnackBar(context, 'Failed to export workout.');
//           //       }
//           //     },
//           //     icon: Icons.share_rounded,
//           //     text: 'Export Workout',
//           //   ),
//           ButtonDetails(
//             onTap: () {
//               Navigator.pop(context);
//               showEditDate(workout);
//             },
//             style: ButtonDetailsStyle.primaryIcon(context),
//             icon: Icons.calendar_today_rounded,
//             text: 'Change Date',
//           ),
//           ButtonDetails(
//             onTap: () {
//               Navigator.pop(context);
//               showEditTime(workout);
//             },
//             icon: Icons.access_time_rounded,
//             style: ButtonDetailsStyle.primaryIcon(context),
//             text: 'Change Start Time',
//           ),
//           if (workoutIsFinished)
//             ButtonDetails(
//               onTap: () {
//                 Navigator.pop(context);
//                 showEditEndTime(workout);
//               },
//               icon: Icons.access_time_filled_rounded,
//               style: ButtonDetailsStyle.primaryIcon(context),
//               text: 'Change End Time',
//             ),

//           ButtonDetails(
//             onTap: () {
//               Navigator.pop(context);
//               showDeleteConfirm(
//                 context,
//                 "workout",
//                 () => WorkoutModel.delete(workout.id!),
//                 widget.reloadParent,
//                 popCaller: true,
//               );
//             },
//             icon: Icons.delete_rounded,
//             text: 'Delete Workout',
//             style: ButtonDetailsStyle.redIcon,
//           ),
//         ],
//       );

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Workout?>(
//       future: workoutFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) return const SizedBox.shrink();
//         if (!snapshot.hasData || snapshot.data == null) {
//           return const DebugScaffold(body: Center(child: Text("Failed to load workout.")));
//         }

//         return DebugScaffold(
//           customAppBarTitle: const Text(
//             'Workout',
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           customAppBarActions: [
//             IconButton(
//               icon: const Icon(Icons.more_vert_rounded),
//               onPressed: () => showMoreMenu(snapshot.data!),
//             )
//           ],
//           body: WorkoutView(
//             workout: snapshot.data!,
//             autofocusNotes: widget.autofocusNotes,
//           ),
//         );
//       },
//     );
//   }
// }
