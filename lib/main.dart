import 'dart:ui';
import 'package:drift/remote.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/helpers/database_helper.dart';
import 'package:gymvision/models/db_models/user_settings_model.dart';
import 'package:gymvision/providers/active_workout_provider.dart';
import 'package:gymvision/services/local_notification_service.dart';
import 'package:gymvision/widgets/coming_soon.dart';
import 'package:gymvision/widgets/debug_scaffold.dart';
import 'package:gymvision/widgets/pages/homepages/exercises/exercises.dart';
import 'package:gymvision/widgets/pages/homepages/progress/progress.dart';
import 'package:gymvision/widgets/pages/homepages/today/today.dart';
import 'package:gymvision/widgets/pages/homepages/history/workouts.dart';
import 'package:gymvision/providers/navigation_provider.dart';
import 'package:gymvision/providers/rest_timer_provider.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // needed for calling async methods in main()

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  const int maxTries = 1;

  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://2b42d972537c900eabae2739a88e994b@o4507913067823104.ingest.de.sentry.io/4507913074770000';
      options.tracesSampleRate = 1.0;
      options.profilesSampleRate = 1.0;
    },
    appRunner: () async {
      // framework errors
      FlutterError.onError = (FlutterErrorDetails details) async {
        FlutterError.presentError(details);
        await Sentry.captureException(
          details.exception,
          stackTrace: details.stack,
        );
      };

      // async errors
      PlatformDispatcher.instance.onError = (error, stack) {
        Sentry.captureException(error, stackTrace: stack);
        return true;
      };

      for (var tries = 0; tries < maxTries; tries++) {
        try {
          await start();
          return;
        } on DriftRemoteException catch (ex, st) {
          // todo: REMOVE THIS AS SOON AS ALL IOS USERS HAVE MIGRATED!!!
          await DatabaseHelper.resetDatabase();
          await Future.delayed(const Duration(seconds: 3)); // small wait between retries

          if (tries == maxTries - 1) {
            // last try
            await Sentry.captureException(ex, stackTrace: st);
            showErrorScreen();
          }
        } catch (ex, st) {
          await Sentry.captureException(ex, stackTrace: st);
          showErrorScreen();
          return;
        }
      }
    },
  );
}

void showErrorScreen() => runApp(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Something went wrong during startup. Please restart.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    ));

Future start() async {
  LocalNotificationService.init();
  await DatabaseHelper.initialiseDatabase();

  final settings = await UserSettingsModel.getUserSettings();
  runApp(EasyDynamicThemeWidget(
    initialThemeMode: settings.theme == UserTheme.system
        ? ThemeMode.system
        : (settings.theme == UserTheme.dark ? ThemeMode.dark : ThemeMode.light),
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => RestTimerProvider()),
        ChangeNotifierProvider(create: (_) => ActiveWorkoutProvider()),
      ],
      child: const MyApp(),
    ),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final primary = const Color.fromRGBO(41, 182, 246, 1);
  final secondary = const Color.fromARGB(255, 216, 160, 233);
  final tertiary = const Color.fromARGB(255, 255, 101, 101);
  final shadow = const Color.fromARGB(255, 77, 77, 77);
  final lightBackground = const Color.fromARGB(255, 245, 245, 245);
  final lightSurface = Colors.white; //const Color.fromARGB(255, 245, 245, 245);
  final darkBackground = const Color.fromARGB(255, 0, 0, 0);
  final darkSurface = const Color.fromARGB(255, 15, 15, 15);
  final darkCard = const Color.fromARGB(255, 22, 22, 22);
  final darkBottomSheet = const Color.fromARGB(255, 26, 26, 26);

  List<Widget> widgetPages() => [
        const Today(),
        const Workouts(),
        const Exercises(),
        const Progress(),
        const ComingSoon(),
      ];

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);

    NavigationDestination getNavItem(String name, IconData icon) => NavigationDestination(
          icon: Icon(icon),
          selectedIcon: Icon(icon, color: primary),
          label: name,
        );

    return MaterialApp(
      navigatorKey: navProvider.navKey,
      title: 'Gym Vision',
      theme: ThemeData(
        splashColor: Colors.transparent,
        scaffoldBackgroundColor: lightBackground,
        bottomSheetTheme: BottomSheetThemeData(backgroundColor: lightSurface),
        colorScheme: ColorScheme.light(
          primary: primary,
          secondary: secondary,
          tertiary: tertiary,
          shadow: shadow,
          surface: lightSurface,
        ),
      ),
      darkTheme: ThemeData(
        splashColor: Colors.transparent,
        scaffoldBackgroundColor: darkBackground,
        bottomSheetTheme: BottomSheetThemeData(backgroundColor: darkBottomSheet),
        cardTheme: CardThemeData(color: darkCard),
        colorScheme: ColorScheme.dark(
          primary: primary,
          secondary: secondary,
          tertiary: tertiary,
          shadow: shadow,
          surface: darkSurface,
        ),
      ),
      themeMode: EasyDynamicTheme.of(context).themeMode,
      home: DebugScaffold(
        showActiveWorkout: true,
        body: widgetPages().elementAt(navProvider.selectedIndex),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(border: BoxBorder.fromLTRB(top: BorderSide(color: shadow, width: 0.25))),
          child: NavigationBar(
            onDestinationSelected: navProvider.changeTab,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            indicatorColor: Colors.transparent,
            selectedIndex: navProvider.selectedIndex,
            destinations: [
              getNavItem('Today', Icons.today_rounded),
              getNavItem('Workouts', Icons.format_list_bulleted_rounded),
              getNavItem('Exercises', Icons.fitness_center_rounded),
              getNavItem('Progress', Icons.timeline_rounded),
              getNavItem('Profile', Icons.person_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
