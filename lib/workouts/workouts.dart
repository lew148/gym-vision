import 'package:flutter/material.dart';
import 'package:gymvision/workouts/workout_month_scroller.dart';

import '../db/classes/workout.dart';
import '../db/helpers/workouts_helper.dart';
// import 'flavour_text_card.dart';

class Workouts extends StatefulWidget {
  const Workouts({super.key});

  @override
  State<Workouts> createState() => _WorkoutsState();
}

class _WorkoutsState extends State<Workouts> {
  reloadState() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final Future<List<Workout>> workouts = WorkoutsHelper.getWorkouts();

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
                  return const Center(
                    child: Text('Loading...'),
                  );
                }

                return WorkoutMonthScoller(
                  workouts: snapshot.data!,
                  reloadState: reloadState,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
