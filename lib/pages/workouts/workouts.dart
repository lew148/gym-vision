import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/bodyweight.dart';
import 'package:gymvision/classes/db/user_setting.dart';
import 'package:gymvision/classes/db/workout.dart';
import 'package:gymvision/models/db_models/bodyweight_model.dart';
import 'package:gymvision/models/db_models/user_settings_model.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/pages/workouts/workout_month_scroller.dart';

class Workouts extends StatefulWidget {
  final Function({DateTime? date}) onAddWorkoutTap;

  const Workouts({
    super.key,
    required this.onAddWorkoutTap,
  });

  @override
  State<Workouts> createState() => _WorkoutsState();
}

class _WorkoutsState extends State<Workouts> {
  reloadState() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final Future<List<Workout>> workouts = WorkoutModel.getAllWorkouts();
    final Future<List<Bodyweight>> bodyweights = BodyweightModel.getBodyweights();
    final Future<UserSettings> userSettings = UserSettingsModel.getUserSettings();

    return Container(
      padding: const EdgeInsets.fromLTRB(5, 10, 5, 5),
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Workout>>(
              future: workouts,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink(); // loading
                }

                return FutureBuilder<List<Bodyweight>>(
                    future: bodyweights,
                    builder: (context, bwSnapshot) {
                      if (!bwSnapshot.hasData) {
                        return const SizedBox.shrink(); // loading
                      }

                      return FutureBuilder<UserSettings>(
                          future: userSettings,
                          builder: (context, usSnapshot) {
                            if (!usSnapshot.hasData) {
                              return const SizedBox.shrink(); // loading
                            }

                            return WorkoutMonthScoller(
                              workouts: snapshot.data!,
                              bodyweights: bwSnapshot.data!,
                              userSettings: usSnapshot.data!,
                              onAddWorkoutTap: widget.onAddWorkoutTap,
                              reloadState: reloadState,
                            );
                          });
                    });
              },
            ),
          ),
        ],
      ),
    );
  }
}
