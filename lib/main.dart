import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymvision/pages/common/coming_soon.dart';
import 'package:gymvision/pages/common/debug_scaffold.dart';
import 'package:gymvision/pages/exercises/exercises.dart';
import 'package:gymvision/pages/progress/progress.dart';
import 'package:gymvision/pages/today/today.dart';
import 'package:gymvision/pages/workouts/workouts.dart';
import 'package:gymvision/providers/navigation_provider.dart';
import 'package:gymvision/providers/rest_timer_provider.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // needed for calling async methods in main()

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
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => NavigationProvider()),
          ChangeNotifierProvider(create: (_) => RestTimerProvider()),
        ],
        child: const MyApp(),
      ),
    )),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final darkThemeBackground = const Color.fromARGB(255, 35, 35, 35);
  final darkCard = const Color.fromARGB(255, 46, 46, 46);

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
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
        appBarTheme: const AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.dark),
        // cardTheme: CardThemeData(shape: Border.all(color: darkCard)),
        colorScheme: ColorScheme.light(
          primary: Colors.lightBlue[400]!,
          secondary: const Color.fromARGB(255, 216, 160, 233),
          tertiary: const Color.fromARGB(255, 235, 156, 140),
          shadow: Colors.grey[500],
        ),
      ),
      darkTheme: ThemeData(
        splashColor: Colors.transparent,
        scaffoldBackgroundColor: darkThemeBackground,
        appBarTheme: const AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.light),
        bottomSheetTheme: BottomSheetThemeData(backgroundColor: darkThemeBackground),
        colorScheme: ColorScheme.dark(
          primary: Colors.lightBlue[400]!,
          secondary: const Color.fromARGB(255, 216, 160, 233),
          tertiary: const Color.fromARGB(255, 255, 101, 101),
          shadow: Colors.grey[500],
          surface: darkCard,
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
  List<Widget> widgetPages() => [
        const Today(),
        const Workouts(),
        const Exercises(),
        const Progress(),
        const ComingSoon(),
      ];

  NavigationDestination getNavItem(String name, IconData icon) => NavigationDestination(
        icon: Icon(icon),
        selectedIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        label: name,
      );

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final selectedIndex = navProvider.selectedIndex;

    return DebugScaffold(
      body: widgetPages().elementAt(selectedIndex),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: navProvider.changeTab,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        indicatorColor: Colors.transparent,
        selectedIndex: selectedIndex,
        destinations: [
          getNavItem('Today', Icons.today_rounded),
          getNavItem('Workouts', Icons.format_list_bulleted_rounded),
          getNavItem('Exercises', Icons.fitness_center_rounded),
          getNavItem('Progress', Icons.timeline_rounded),
          getNavItem('Profile', Icons.person_rounded),
        ],
      ),
    );
  }
}
