import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/body_weight.dart';
import 'package:gymvision/db/helpers/bodyweight_helper.dart';
import 'package:gymvision/pages/workouts/workout_month_scroller.dart';

import '../../db/classes/workout.dart';
import '../../db/helpers/workouts_helper.dart';
// import 'flavour_text_card.dart';

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
    final Future<List<Workout>> workouts = WorkoutsHelper.getWorkouts();
    final Future<List<Bodyweight>> bodyweights = BodyweightHelper.getBodyweights();

    return Container(
      padding: const EdgeInsets.fromLTRB(5, 10, 5, 5),
      child: Column(
        children: [
          // flavour text
          // const FlavourTextCard(),

          // workouts
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

                      return WorkoutMonthScoller(
                        workouts: snapshot.data!,
                        bodyweights: bwSnapshot.data!,
                        onAddWorkoutTap: widget.onAddWorkoutTap,
                        reloadState: reloadState,
                      );
                    });
              },
            ),
          ),
        ],
      ),
    );
  }
}
