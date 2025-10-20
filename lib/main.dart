import 'dart:ui';
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
import 'package:gymvision/widgets/pages/homepages/history/history.dart';
import 'package:gymvision/widgets/pages/homepages/progress/progress.dart';
import 'package:gymvision/widgets/pages/homepages/today/today.dart';
import 'package:gymvision/providers/navigation_provider.dart';
import 'package:gymvision/providers/rest_timer_provider.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // needed for calling async methods in main()

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await dotenv.load(fileName: ".env");

  await SentryFlutter.init(
    (options) {
      options.dsn = dotenv.env['SENTRY_DSN'];
      options.tracesSampleRate = 1.0;
      options.profilesSampleRate = 1.0;
      // options.replay.sessionSampleRate = 1.0; //
      options.replay.onErrorSampleRate = 1.0;
    },
    appRunner: () async {
      // framework errors
      FlutterError.onError = (FlutterErrorDetails details) async {
        FlutterError.presentError(details);
        await Sentry.captureException(details.exception, stackTrace: details.stack);
      };

      // async errors
      PlatformDispatcher.instance.onError = (error, stack) {
        Sentry.captureException(error, stackTrace: stack);
        return true;
      };

      try {
        await start();
        return;
      } catch (ex, st) {
        await Sentry.captureException(ex, stackTrace: st);
        showErrorScreen();
        return;
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
  runApp(
    SentryWidget(
      child: EasyDynamicThemeWidget(
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
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final primary = const Color.fromARGB(255, 252, 150, 55);
  final secondary = const Color.fromARGB(255, 146, 146, 146);
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
        const History(),
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
      title: 'Forged',
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
        bottomSheetTheme: BottomSheetThemeData(backgroundColor: darkCard),
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
        showActiveWorkout: navProvider.selectedIndex < 4,
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
              getNavItem('History', Icons.format_list_bulleted_rounded),
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
