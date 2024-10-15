import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/db/classes/workout.dart';
import 'package:gymvision/db/helpers/workouts_helper.dart';
import 'package:gymvision/pages/coming_soon.dart';
import 'package:gymvision/pages/exercises/exercises.dart';
import 'package:gymvision/shared/forms/add_bodyweight_form.dart';
import 'package:gymvision/shared/ui_helper.dart';
import 'package:gymvision/user_settings_view.dart';
import 'package:gymvision/pages/workouts/workout_view.dart';
import 'package:gymvision/pages/workouts/workouts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  // final userSettings = await UserSettingsHelper.getUserSettings();

  // ThemeMode getThemeModeFromSetting() {
  //   ThemeMode themeMode;
  //   switch (userSettings.theme) {
  //     case ThemeSetting.light:
  //       themeMode = ThemeMode.light;
  //       break;
  //     case ThemeSetting.dark:
  //       themeMode = ThemeMode.dark;
  //       break;
  //     case ThemeSetting.system:
  //       themeMode = ThemeMode.system;
  //       break;
  //   }
  //   return themeMode;
  // }

  // todo: need to get this from shared prefs as sqflite is not setup yet

  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://2b42d972537c900eabae2739a88e994b@o4507913067823104.ingest.de.sentry.io/4507913074770000';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.profilesSampleRate = 1.0;
    },
    appRunner: () => runApp(EasyDynamicThemeWidget(
      initialThemeMode: ThemeMode.system,
      child: const MyApp(),
    )),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final darkThemeBackground = const Color.fromARGB(255, 46, 46, 46);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'Gym Vision',
      theme: ThemeData(
        splashColor: Colors.transparent,
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        colorScheme: ColorScheme.light(
          primary: Colors.lightBlue[400]!,
          secondary: const Color.fromARGB(255, 216, 160, 233),
          tertiary: const Color.fromARGB(255, 235, 156, 140),
          shadow: Colors.grey[600],
        ),
      ),
      darkTheme: ThemeData(
        splashColor: Colors.transparent,
        scaffoldBackgroundColor: darkThemeBackground,
        cardTheme: CardTheme(
          surfaceTintColor: Colors.grey[800],
          shadowColor: Colors.grey[400],
          color: Colors.grey[800],
        ),
        bottomSheetTheme: BottomSheetThemeData(backgroundColor: darkThemeBackground),
        colorScheme: ColorScheme.dark(
          primary: Colors.lightBlue[400]!,
          secondary: const Color.fromARGB(255, 216, 160, 233),
          tertiary: const Color.fromARGB(255, 255, 101, 101),
          shadow: Colors.grey[400],
          surface: Colors.grey[800]!,
          surfaceTint: Colors.grey[800],
        ),
      ),
      themeMode: EasyDynamicTheme.of(context).themeMode,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void reloadState() => onItemTapped(selectedIndex);

  void onAddWeightTap() async => showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: AddBodyWeightForm(reloadState: reloadState),
            ),
          ],
        ),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      );

  void onAddWorkoutTap({DateTime? date}) async {
    try {
      var now = DateTime.now();

      if (date != null) {
        date = DateTime(date.year, date.month, date.day, now.hour, now.minute);
      }

      final newWorkoutId = await WorkoutsHelper.insertWorkout(Workout(date: date ?? now));
      if (!mounted) return;

      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (context) => WorkoutView(
                workoutId: newWorkoutId,
                reloadParent: reloadState,
              ),
            ),
          )
          .then((value) => reloadState());
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add workout')),
      );
    }
  }

  void onAddButtonTap() => showModalBottomSheet(
        context: context,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                child: Column(
                  children: [
                    getSectionTitle(context, 'Add'),
                    const Divider(thickness: 0.25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        getOutlinedPrimaryButton(ActionButton(
                          onTap: () {
                            Navigator.pop(context);
                            onAddWorkoutTap();
                          },
                          text: 'Workout',
                          icon: Icons.fitness_center_rounded,
                        )),
                        getOutlinedPrimaryButton(ActionButton(
                          onTap: () {
                            Navigator.pop(context);
                            onAddWeightTap();
                          },
                          text: 'Bodyweight',
                          icon: Icons.monitor_weight_rounded,
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      );

  List<Widget> widgetPages() => [
        Workouts(onAddWorkoutTap: onAddWorkoutTap),
        const Exercises(),
        const ComingSoon(),
        const ComingSoon(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [Text('GymVision')]),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => const UserSettingsView()))
                .then((value) => setState(() {})),
          )
        ],
      ),
      body: Center(child: widgetPages().elementAt(selectedIndex)),
      floatingActionButton: FloatingActionButton(
        onPressed: onAddButtonTap,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add_rounded),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: onItemTapped,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        indicatorColor: Colors.transparent,
        selectedIndex: selectedIndex,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.format_list_bulleted_rounded),
            selectedIcon: Icon(
              Icons.format_list_bulleted_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Workouts',
          ),
          NavigationDestination(
            icon: const Icon(Icons.fitness_center_rounded),
            selectedIcon: Icon(
              Icons.fitness_center_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Exercises',
          ),
          NavigationDestination(
            icon: const Icon(Icons.timeline_rounded),
            selectedIcon: Icon(
              Icons.timeline_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_rounded),
            selectedIcon: Icon(
              Icons.person_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
