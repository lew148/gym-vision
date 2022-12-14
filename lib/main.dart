import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/exercises/exercises.dart';
import 'package:gymvision/user_settings_view.dart';
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Vision',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.green[400]!,
          secondary: const Color.fromARGB(255, 255, 216, 250),
          shadow: Colors.grey[600],
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Colors.green[400]!,
          secondary: const Color.fromARGB(255, 255, 216, 250),
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
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static const List<Widget> _widgetPages = <Widget>[
    Workouts(),
    Exercises(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GymVision'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_rounded,
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const UserSettingsView(),
              ),
            ),
          )
        ],
      ),
      body: Center(child: _widgetPages.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
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
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}
