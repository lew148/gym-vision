import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/user_image.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/helpers/functions/bottom_sheet_helper.dart';
import 'package:gymvision/models/db_models/user_image_model.dart';
import 'package:gymvision/widgets/forms/pickers/image_picker_widget.dart';
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

  static Future<List<File>> getAllSavedImages() async {
  final directory = Directory(await getProgressPicPath());
  final List<FileSystemEntity> entities = await directory.list().toList();
  final List<File> imageFiles = entities
      .whereType<File>()
      .where((file) {
        final path = file.path.toLowerCase();
        return path.endsWith('.jpg') || 
               path.endsWith('.jpeg') || 
               path.endsWith('.png');
      })
      .toList();

  return imageFiles;
}

  static Future<bool> addProgressPic(File image, {DateTime? dateTime}) async {
    try {
      final now = dateTime ?? DateTime.now();
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

  static Future<void> openImagePicker(
    BuildContext context,
    Function(List<File>) onImageSelected, {
    bool skipConfirm = false,
  }) async =>
      BottomSheetHelper.showCloseableBottomSheet(
        context,
        ImagePickerWidget(multiple: false, skipConfirm: skipConfirm, onImagesSelected: onImageSelected),
      );
}
