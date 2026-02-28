import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/user_image.dart';
import 'package:gymvision/helpers/functions/bottom_sheet_helper.dart';
import 'package:gymvision/helpers/functions/dialog_helper.dart';
import 'package:gymvision/models/db_models/user_image_model.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/components/stateless/image_preview.dart';
import 'package:gymvision/widgets/components/stateless/splash_text.dart';
import 'package:gymvision/widgets/components/stateless/stat_display.dart';
import 'package:gymvision/widgets/debug_scaffold.dart';
import 'package:gymvision/widgets/forms/add_progress_pic_form.dart';

class ProgressPics extends StatefulWidget {
  const ProgressPics({super.key});

  @override
  State<ProgressPics> createState() => _ProgressPicsState();
}

class _ProgressPicsState extends State<ProgressPics> {
  var _future = UserImageModel.getAllProgressPics();

  void _reload() => setState(() {
        _future = UserImageModel.getAllProgressPics();
      });

  Future<void> _addProgressPic() async {
    await BottomSheetHelper.showCloseableBottomSheet(context, const AddProgressPicForm());
    _reload();
  }

  Widget _getEmptyState() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SplashText.none(
            item: 'progress pics',
            description: 'Add photos of your progress to track your gains visually over time',
          ),
          Button.elevated(icon: Icons.add_rounded, text: 'Add a progress pic', onTap: _addProgressPic),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
          return Text(snapshot.data.toString());
        }

        final List<UserImage> progressPics = snapshot.data!;

        return DebugScaffold(
          customAppBarTitle: Text('Progress Pics'),
          customAppBarActions: [
            IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: _addProgressPic,
            )
          ],
          body: Column(children: [
            Expanded(
              child: progressPics.isEmpty
                  ? _getEmptyState()
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: progressPics.length,
                      itemBuilder: (context, index) {
                        final image = progressPics[index];
                        final dateTime = image.takenAt ?? image.createdAt;

                        return Column(children: [
                          Expanded(
                            child: ImagePreview(
                              image: File(image.path),
                              onDelete: () async => await DialogHelper.showDeleteConfirm(
                                context,
                                'image',
                                () async {
                                  await UserImageModel.delete(image.id!);
                                  _reload();
                                },
                              ),
                            ),
                          ),
                          if (dateTime != null)
                            Column(children: [
                              CustomDivider(shadow: true),
                              StatDisplay.date(dateTime),
                              StatDisplay.time(dateTime),
                            ]),
                        ]);
                      }),
            ),
          ]),
        );
      },
    );
  }
}
