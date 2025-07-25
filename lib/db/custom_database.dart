import 'package:gymvision/pages/common/common_functions.dart';
import 'package:sqflite/sqflite.dart';

class CustomDatabase {
  Database db;
  CustomDatabase({required this.db});

  static Future<CustomDatabase> loadDb(Future<Database> database) async => CustomDatabase(db: await database);

  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]) async => await runSafe(
        () async => db.rawQuery(sql, arguments),
        fallback: [],
      );

  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async =>
      await runSafe(
        () async => db.query(
          table,
          distinct: distinct,
          columns: columns,
          where: where,
          whereArgs: whereArgs,
          groupBy: groupBy,
          having: having,
          orderBy: orderBy,
          limit: limit,
          offset: offset,
        ),
        fallback: [],
      );

  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async =>
      await runSafe(
        () async => db.insert(
          table,
          values,
          nullColumnHack: nullColumnHack,
          conflictAlgorithm: conflictAlgorithm,
        ),
        fallback: 0,
      );

  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async =>
      await runSafe(
        () async => db.update(
          table,
          values,
          where: where,
          whereArgs: whereArgs,
          conflictAlgorithm: conflictAlgorithm,
        ),
        fallback: 0,
      );

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async =>
      await runSafe(
        () async => db.delete(
          table,
          where: where,
          whereArgs: whereArgs,
        ),
        fallback: 0,
      );
}
