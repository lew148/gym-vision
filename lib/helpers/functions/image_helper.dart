import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/user_image.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/models/db_models/user_image_model.dart';
import 'package:gymvision/widgets/pages/image_picker_page.dart';
import 'package:path_provider/path_provider.dart';

class ImageHelper {
  static Future<String> getProgressPicPath() async =>
      '${(await getApplicationDocumentsDirectory()).path}/progress_pics';

  static Future<File> saveImageLocally(File image, String path, {String? name}) async {
    final dir = Directory(path);
    if (!await dir.exists()) await dir.create(recursive: true);
    final newFile = File('${dir.path}/${name ?? DateTime.now().millisecondsSinceEpoch}.jpg');
    return await image.copy(newFile.path);
  }

  static Future<bool> addProgressPic(int workoutId, File image) async {
    try {
      final now = DateTime.now();
      final savedImage = await ImageHelper.saveImageLocally(
        image,
        await getProgressPicPath(),
        name: now.millisecondsSinceEpoch.toString(),
      );

      await UserImageModel.insert(UserImage(
        path: savedImage.path,
        storageType: ImageStorageType.local,
        imageType: UserImageType.progressPic,
        takenAt: now,
      ));

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> openImagePicker(BuildContext context, Function(List<File>) onImageSelected) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagePickerPage(
          multiple: false,
          onImagesSelected: onImageSelected,
        ),
      ),
    );
  }
}
