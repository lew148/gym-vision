import 'package:flutter/material.dart';
import 'package:gymvision/Exercises/exercises.dart';
import 'package:gymvision/workout.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Vision',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
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
    Workout(),
    Exercises(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GymVision'),
      ),
      body: Center(child: _widgetPages.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_bulleted),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Exercises',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo[300],
        onTap: _onItemTapped,
      ),
    );
  }
}
