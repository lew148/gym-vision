import 'dart:ui';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/helpers/database_helper.dart';
import 'package:gymvision/models/db_models/user_settings_model.dart';
import 'package:gymvision/providers/global/active_workout_provider.dart';
import 'package:gymvision/providers/global/history_provider.dart';
import 'package:gymvision/services/local_notification_service.dart';
import 'package:gymvision/widgets/coming_soon.dart';
import 'package:gymvision/widgets/debug_scaffold.dart';
import 'package:gymvision/widgets/pages/homepages/exercises/exercises.dart';
import 'package:gymvision/widgets/pages/homepages/history/history.dart';
import 'package:gymvision/widgets/pages/homepages/progress/progress.dart';
import 'package:gymvision/widgets/pages/homepages/today/today.dart';
import 'package:gymvision/providers/global/navigation_provider.dart';
import 'package:gymvision/providers/global/rest_timer_provider.dart';
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

  if (!kReleaseMode) {
    // --- debug ---
    await start();
    return;
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = dotenv.env['SENTRY_DSN'];
      options.tracesSampleRate = 1.0;
      options.profilesSampleRate = 1.0;
      // options.replay.sessionSampleRate = 1.0;
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
            ChangeNotifierProvider(create: (_) => HistoryProvider()),
          ],
          child: const MyApp(),
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // light
  // cherry red: 0xFF9B1B30
  // Persimmon & slate: #EC5840 & #4A5568
  // Jade & icy blue: #006865 & #A8DADC
  // Sage & sand (matcha): #7D9D85 & #D7C4A3
  // Slate & lime: #475569 & #8BBB32
  // monotone: #475569 & #94A3B8

  // dark
  // Mint: #81E6D9 && #D7CCC8
  // indigo & rose: #9FA8DA & #EF9A9A
  // slate & gold: #898AA6 & #F3D692
  // monotone: #94A3B8 & #64748B

  final primary = const Color(0xFFEE4545);
  final darksecondary = const Color(0xFFF4F4F5);
  final darkshadow = const Color(0xFF696969);
  final darkBackground = const Color(0xFF1A1A1C);
  final darkSurface = const Color(0xFF1E1E1C);
  final darkCard = const Color(0xFF2A2A28);

  final lightSecondary = const Color(0xFF18181B);
  final lightShadow = const Color(0xFFA5A5A5);
  final lightBackground = const Color(0xFFFAF9F6);
  final lightSurface = const Color(0xFFF5F5F0);
  final lightCard = const Color(0xFFFFFFFF);

  static const List<Widget> widgetPages = [
    Today(),
    History(),
    Exercises(),
    Progress(),
    ComingSoon(),
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
            secondary: lightSecondary,
            shadow: lightShadow,
            surface: lightSurface,
          ),
          cardTheme: CardThemeData(
            color: lightCard,
          )),
      darkTheme: ThemeData(
          splashColor: Colors.transparent,
          scaffoldBackgroundColor: darkBackground,
          bottomSheetTheme: BottomSheetThemeData(backgroundColor: darkSurface),
          colorScheme: ColorScheme.dark(
            primary: primary,
            secondary: darksecondary,
            shadow: darkshadow,
            surface: darkSurface,
          ),
          cardTheme: CardThemeData(
            color: darkCard,
          )),
      themeMode: EasyDynamicTheme.of(context).themeMode,
      home: DebugScaffold(
        showActiveWorkout: navProvider.selectedIndex < 4,
        body: MyApp.widgetPages.elementAt(navProvider.selectedIndex),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(border: BoxBorder.fromLTRB(top: BorderSide(color: darkshadow, width: 0.25))),
          child: NavigationBar(
            onDestinationSelected: navProvider.toTab,
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
