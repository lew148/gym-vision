import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/user_image.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/helpers/functions/app_helper.dart';
import 'package:gymvision/helpers/functions/bottom_sheet_helper.dart';
import 'package:gymvision/models/db_models/user_image_model.dart';
import 'package:gymvision/widgets/forms/pickers/image_picker_widget.dart';

class ImageHelper {
  static const String imageExtension = '.jpg';

  static const String progressPicRelativePath = '/progress_pics';

  static Future<String?> getFullImagePath(String relativePath) async =>
      '${await AppHelper.getAppDocumentsPath()}/$relativePath';

  static Future<(File, String?)> saveImageLocally(
    File image,
    String path, {
    String? customName,
    bool addToGallery = false,
  }) async {
    final dir = Directory(path);
    if (!await dir.exists()) await dir.create(recursive: true);
    final name = '${customName ?? DateTime.now().millisecondsSinceEpoch}$imageExtension';
    final newFile = File('${dir.path}/$name');
    final savedImage = await image.copy(newFile.path);
    return (savedImage, name);
  }

  static Future<bool> addProgressPic(File image, {DateTime? dateTime}) async {
    try {
      final now = dateTime ?? DateTime.now();
      final path = '${await AppHelper.getAppDocumentsPath()}$progressPicRelativePath';

      final (File _, String? savedName) = await ImageHelper.saveImageLocally(image, path);
      if (savedName == null) return false;

      await UserImageModel.insert(UserImage(
        name: savedName,
        relativePath: '$progressPicRelativePath/$savedName',
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
