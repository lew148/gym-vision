import 'package:gymvision/classes/db/_dbo.dart';
import 'package:gymvision/enums.dart';

class UserImage extends DBO {
  final String path;
  final ImageStorageType storageType;
  final UserImageType imageType;
  DateTime? takenAt;

  UserImage({
    super.id,
    super.updatedAt,
    super.createdAt,
    required this.path,
    required this.storageType,
    required this.imageType,
    this.takenAt,
  });
}
