import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/db/classes/workout.dart';
import 'package:gymvision/db/helpers/workouts_helper.dart';
import 'package:gymvision/exercises/exercises.dart';
import 'package:gymvision/shared/forms/add_weight_form.dart';
import 'package:gymvision/shared/ui_helper.dart';
import 'package:gymvision/user_settings_view.dart';
import 'package:gymvision/workouts/workout_view.dart';
import 'package:gymvision/workouts/workouts.dart';

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

  runApp(EasyDynamicThemeWidget(
    initialThemeMode: ThemeMode.system,
    child: const MyApp(),
  ));
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
          primary: Colors.green[400]!,
          secondary: const Color.fromARGB(255, 216, 160, 233),
          tertiary: const Color.fromARGB(255, 235, 156, 140),
          shadow: Colors.grey[600],
        ),
      ),
      darkTheme: ThemeData(
        splashColor: Colors.transparent,
        scaffoldBackgroundColor: darkThemeBackground,
        bottomSheetTheme: BottomSheetThemeData(backgroundColor: darkThemeBackground),
        colorScheme: ColorScheme.dark(
          primary: Colors.green[400]!,
          secondary: const Color.fromARGB(255, 216, 160, 233),
          tertiary: const Color.fromARGB(255, 255, 101, 101),
          shadow: Colors.grey[400],
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
              child: AddWeightForm(reloadState: reloadState),
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
                        ))
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
                .push(
                  MaterialPageRoute(builder: (context) => const UserSettingsView()),
                )
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_bulleted_rounded),
            label: 'Workouts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_rounded),
            label: 'Exercises',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: onItemTapped,
      ),
    );
  }
}
