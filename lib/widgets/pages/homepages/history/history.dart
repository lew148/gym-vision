import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/bodyweight.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/models/db_models/bodyweight_model.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/widgets/components/stateless/scroll_bottom_padding.dart';
import 'package:gymvision/widgets/components/workout_summary_card.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  late Future<List<Workout>> workoutsFuture;
  late Future<List<Bodyweight>> bodyweightsFuture;

  @override
  void initState() {
    super.initState();
    workoutsFuture = WorkoutModel.getAllWorkouts();
    bodyweightsFuture = BodyweightModel.getBodyweights();
  }

  reload() => setState(() {
        workoutsFuture = WorkoutModel.getAllWorkouts();
        bodyweightsFuture = BodyweightModel.getBodyweights();
      });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<List<Workout>>(
            future: workoutsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();

              return FutureBuilder<List<Bodyweight>>(
                  future: bodyweightsFuture,
                  builder: (context, bwSnapshot) {
                    if (!bwSnapshot.hasData) return const SizedBox.shrink();

                    return Column(children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: SingleChildScrollView(
                            child: Column(children: [
                              ...snapshot.data!.map((w) => Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: WorkoutSummaryCard(
                                      workoutId: w.id!,
                                      isDisplay: true,
                                    ),
                                  )),
                              const ScrollBottomPadding(),
                            ]),
                          ),
                        ),
                      ),
                    ]);
                  });
            },
          ),
        ),
      ],
    );
  }
}
