import 'package:drift/drift.dart';

mixin CoreColumns on Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
}
