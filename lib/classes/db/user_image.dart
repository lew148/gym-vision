import 'package:gymvision/classes/db/_dbo.dart';
import 'package:gymvision/enums.dart';

class UserImage extends DBO {
  final String name;
  final ImageStorageType storageType;
  final UserImageType imageType;

  final String? relativePath; // relative path on device
  final String? source; // cloud path

  DateTime? takenAt;

  UserImage({
    super.id,
    super.updatedAt,
    super.createdAt,
    this.source,
    this.relativePath,
    required this.name,
    required this.storageType,
    required this.imageType,
    this.takenAt,
  });

  DateTime getTakenAt() => takenAt ?? DateTime(1999, 01, 01);
}
