import 'package:drift/drift.dart';

List<Future<void> Function(Migrator m)> migrations = [
  //   // v1 → v2
  // (m) async {
  //   // add a new column
  //   await m.addColumn(workout, workout.description);
  // },
  // // v2 → v3
  // (m) async {
  //   // add a new table
  //   await m.createTable(log);
  // },
  // // v3 → v4
  // (m) async {
  //   // raw SQL example
  //   await m.customStatement(
  //       'ALTER TABLE workout RENAME COLUMN name TO workout_name');
  // },
];
