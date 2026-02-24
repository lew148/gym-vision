import 'package:drift/drift.dart';
import 'package:gymvision/classes/db/user_image.dart';
import 'package:gymvision/db/drift_database.dart';
import 'package:gymvision/db/table_extensions.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/helpers/database_helper.dart';

class UserImageModel {
  static Future<int> insert(UserImage image) async {
    final db = DatabaseHelper.db;
    final now = DateTime.now();
    return await db.into(db.driftUserImages).insert(DriftUserImagesCompanion(
          createdAt: Value(now),
          updatedAt: Value(now),
          path: Value(image.path),
          storageType: Value(image.storageType),
          imageType: Value(image.imageType),
          takenAt: Value(image.takenAt),
        ));
  }

  static Future<bool> update(UserImage image) async {
    if (image.id == null) return false;
    final db = DatabaseHelper.db;
    await (db.update(db.driftUserImages)..where((s) => s.id.equals(image.id!))).write(DriftUserImagesCompanion(
      updatedAt: Value(DateTime.now()),
      path: Value(image.path),
      storageType: Value(image.storageType),
      imageType: Value(image.imageType),
      takenAt: Value(image.takenAt),
    ));

    return true;
  }

  static Future<int> delete(int id) async {
    final db = DatabaseHelper.db;
    return await (db.delete(db.driftUserImages)..where((n) => n.id.equals(id))).go();
  }

  static Future<List<UserImage>> getAllProgressPics() async {
    final db = DatabaseHelper.db;
    return (await ((db.select(db.driftUserImages)..where((ui) => ui.imageType.equalsValue(UserImageType.progressPic))))
            .get())
        .map((ui) => ui.toObject())
        .toList();
  }
}
