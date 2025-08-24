import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/bodyweight.dart';
import 'package:gymvision/classes/db/user_settings.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/models/db_models/bodyweight_model.dart';
import 'package:gymvision/models/db_models/user_settings_model.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/pages/workouts/workout_month_scroller.dart';

class Workouts extends StatefulWidget {
  const Workouts({super.key});

  @override
  State<Workouts> createState() => _WorkoutsState();
}

class _WorkoutsState extends State<Workouts> {
  late Future<List<Workout>> workouts;
  late Future<List<Bodyweight>> bodyweights;
  late Future<UserSettings> userSettings;

  @override
  void initState() {
    super.initState();
    workouts = WorkoutModel.getAllWorkouts();
    bodyweights = BodyweightModel.getBodyweights();
    userSettings = UserSettingsModel.getUserSettings();
  }

  reloadState() => setState(() {
        workouts = WorkoutModel.getAllWorkouts();
        bodyweights = BodyweightModel.getBodyweights();
        userSettings = UserSettingsModel.getUserSettings();
      });

  @override
  Widget build(BuildContext context) {
    return Column(
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
                            reloadParent: reloadState,
                          );
                        });
                  });
            },
          ),
        ),
      ],
    );
  }
}
