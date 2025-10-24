import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/bodyweight.dart';
import 'package:gymvision/classes/db/workouts/workout.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/models/db_models/bodyweight_model.dart';
import 'package:gymvision/models/db_models/workout_model.dart';
import 'package:gymvision/providers/active_workout_provider.dart';
import 'package:gymvision/providers/navigation_provider.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/widgets/components/stateless/calendar_view.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/category_filter.dart';
import 'package:gymvision/widgets/components/stateless/scroll_bottom_padding.dart';
import 'package:gymvision/widgets/components/stateless/shimmer_load.dart';
import 'package:gymvision/widgets/components/stateless/splash_text.dart';
import 'package:gymvision/widgets/components/workouts/workout_card.dart';
import 'package:provider/provider.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  late List<Category> filterCategories;
  DateTime? date;

  @override
  void initState() {
    super.initState();
    final navProvider = context.read<NavigationProvider>();
    filterCategories = navProvider.historyCategoryFilters;
    navProvider.resetHistoryCategoryFilters();
  }

  Future<(List<Bodyweight>, List<Workout>)> loadFuture() async => (
        await BodyweightModel.getBodyweights(),
        await WorkoutModel.getAllWorkouts(withSummary: true, filterCategories: filterCategories)
      );

  void reload() => setState(() {});

  void onSetFilterCategories(List<Category> categories) async {
    setState(() {
      filterCategories = categories;
    });
  }

  void setDate(DateTime? dt) => setState(() {
        date = dt;
      });

  Map<DateTime, List<CalendarViewEvent>> getEvents(List<Workout> workouts) => groupBy(workouts, (w) => w.date).map(
      (key, value) => MapEntry(DateTimeHelper.roundToDay(key), value.map((w) => (CalendarViewEvent.workout)).toList()));

  Widget getFilterRow(List<Workout> workouts) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: CategoryFilter(
              filterCategories: filterCategories,
              onChange: onSetFilterCategories,
            ),
          ),
          Button.calendar(
            onTap: () => showCalendarView(
              context,
              events: getEvents(workouts),
              onDateSelected: setDate,
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Consumer<ActiveWorkoutProvider>(builder: (context, activeWorkoutProvider, child) {
      return FutureBuilder<(List<Bodyweight>, List<Workout>)>(
          future: loadFuture(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return ListView(
                children: [
                  getFilterRow([]),
                  const Row(mainAxisAlignment: MainAxisAlignment.end, children: [Button(text: 'All Time')]),
                  ...List.generate(5, (i) => const ShimmerLoad(height: 200)),
                  const ScrollBottomPadding(),
                ],
              );
            }

            final (bodyweights, allWorkouts) = snapshot.data!;
            final workoutsToDisplay = date != null
                ? allWorkouts
                    .where((w) => DateTimeHelper.roundToDay(w.date) == DateTimeHelper.roundToDay(date!))
                    .toList()
                : allWorkouts;

            return Column(
              children: [
                getFilterRow(allWorkouts),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    date == null
                        ? const Button(text: 'All Time')
                        : Button(
                            text: DateTimeHelper.getDateStr(date!),
                            onTap: () =>
                                showConfirm(context, title: 'Remove date filter?', onConfirm: () => setDate(null))),
                  ],
                ),
                workoutsToDisplay.isEmpty
                    ? const SplashText(
                        icon: Icons.hotel_rounded,
                        title: 'No Workouts',
                        description: 'This day is a rest day!',
                      )
                    : Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: ListView.builder(
                            itemCount: workoutsToDisplay.length + 1, // + 1 for bottom padding
                            itemBuilder: (BuildContext context, int i) {
                              return i == workoutsToDisplay.length
                                  ? const ScrollBottomPadding()
                                  : Padding(
                                      padding: const EdgeInsetsGeometry.only(bottom: 5),
                                      child: WorkoutCard(
                                        workout: workoutsToDisplay[i],
                                        isDisplay: true,
                                        reloadParent: reload,
                                      ),
                                    );
                            },
                          ),
                        ),
                      ),
              ],
            );
          });
    });
  }
}
