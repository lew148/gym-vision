import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/user_settings.dart';
import 'package:gymvision/constants.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/helpers/database_helper.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/helpers/functions/app_helper.dart';
import 'package:gymvision/helpers/functions/bottom_sheet_helper.dart';
import 'package:gymvision/helpers/functions/dialog_helper.dart';
import 'package:gymvision/helpers/functions/picker_helper.dart';
import 'package:gymvision/services/local_notification_service.dart';
import 'package:gymvision/models/db_models/flavour_text_schedule_model.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/components/stateless/header.dart';
import 'package:gymvision/widgets/debug_scaffold.dart';
import 'package:gymvision/widgets/forms/fields/custom_dropdown.dart';
import 'package:gymvision/widgets/forms/import_data_form.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/db_models/user_settings_model.dart';

class UserSettingsView extends StatefulWidget {
  const UserSettingsView({super.key});

  @override
  State<UserSettingsView> createState() => _UserSettingsViewState();
}

class _UserSettingsViewState extends State<UserSettingsView> {
  Future<UserSettings> userSettings = UserSettingsModel.getUserSettings();

  void reloadState() => setState(() {
        userSettings = UserSettingsModel.getUserSettings();
      });

  @override
  Widget build(BuildContext context) {
    return DebugScaffold(
      ignoreDefaults: true,
      body: FutureBuilder(
        future: userSettings,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.shrink(); // loading
          }

          final settings = snapshot.data!;

          String? getInitialValue() {
            if (settings.theme == UserTheme.light) return 'Light';
            if (settings.theme == UserTheme.dark) return 'Dark';
            if (settings.theme == UserTheme.system) return 'System';
            return null;
          }

          return Column(
            children: [
              Padding(
                padding: EdgeInsetsGeometry.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Intra-set Rest Timer',
                      style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                    ),
                    Button(
                      style: ButtonCustomStyle(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5)),
                      text: settings.intraSetRestTimer == null
                          ? 'Set Timer'
                          : DateTimeHelper.getDurationString(settings.intraSetRestTimer!, noHours: true),
                      onTap: () => PickerHelper.showDurationPicker(
                        context,
                        initialDuration: settings.intraSetRestTimer,
                        CupertinoTimerPickerMode.ms,
                        onSubmit: (Duration d) async {
                          try {
                            settings.intraSetRestTimer = d.inSeconds == 0 ? null : d;
                            await UserSettingsModel.update(settings);
                          } catch (ex) {
                            if (context.mounted) {
                              AppHelper.showSnackBar(context, 'Failed to update Intra-Set Rest Timer.');
                            }
                          }

                          reloadState();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              CustomDropdown(
                label: 'Theme',
                intialValue: getInitialValue(),
                values: ['Light', 'Dark', 'System'],
                onChange: (value) async {
                  try {
                    switch (value) {
                      case 'Light':
                        {
                          settings.theme = UserTheme.light;
                          EasyDynamicTheme.of(context).changeTheme(dark: false, dynamic: false);
                          break;
                        }
                      case 'Dark':
                        {
                          settings.theme = UserTheme.dark;
                          EasyDynamicTheme.of(context).changeTheme(dark: true, dynamic: false);
                          break;
                        }
                      case 'System':
                        {
                          settings.theme = UserTheme.system;
                          EasyDynamicTheme.of(context).changeTheme(dynamic: true);
                          break;
                        }
                      case null:
                        return;
                    }

                    await UserSettingsModel.update(settings);
                  } catch (ex) {
                    if (context.mounted) AppHelper.showSnackBar(context, 'Failed to update theme.');
                  }

                  reloadState();
                },
              ),
              const Padding(padding: EdgeInsets.all(5)),
              const Header(title: 'Developer Settings'),
              const CustomDivider(),
              Row(children: [
                Expanded(
                  child: Button.elevated(
                    icon: Icons.upload_rounded,
                    text: 'Export Data',
                    onTap: () async {
                      try {
                        final exportString = await AppHelper.getFullExportString();
                        if (exportString == null) throw Exception();
                        await SharePlus.instance.share(ShareParams(text: exportString));
                      } catch (ex) {
                        if (context.mounted) AppHelper.showSnackBar(context, 'Failed to export');
                      }
                    },
                  ),
                ),
                Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 5)),
                Expanded(
                  child: Button.elevated(
                    icon: Icons.download_rounded,
                    text: 'Import Data',
                    onTap: () async {
                      await BottomSheetHelper.showCloseableBottomSheet(context, const ImportDataForm());
                    },
                  ),
                ),
              ]),
              Button.elevated(
                onTap: () async {
                  await FlavourTextScheduleModel.setRecentFlavourTextScheduleNotDismissed();
                  if (!context.mounted) return;
                  AppHelper.showSnackBar(context, 'Flavour Text Un-dismissed!');
                },
                text: 'Un-Dismiss Flavour Text',
              ),
              Button.elevated(
                onTap: () async {
                  await Sentry.captureMessage('(Ignore) This message was sent manually by a developer.');
                  if (context.mounted) AppHelper.showSnackBar(context, 'Sentry message sent!');
                },
                text: 'Send Error to Sentry',
              ),
              Button.elevated(
                onTap: () => LocalNotificationService.showTestNotification(),
                text: 'Show Test Notification',
              ),
              const Padding(padding: EdgeInsets.all(5)),
              const Header(title: 'Database Settings'),
              const CustomDivider(),
              Button.elevated(
                text: 'Update Database',
                onTap: () => DialogHelper.showConfirm(
                  context,
                  title: 'Update Database',
                  content: 'This will persist existing data. Please wait for success message!',
                  onConfirm: () async {
                    DialogHelper.showCustomDialog(
                      context,
                      title: 'Updating Database - Do not close app!',
                      dismissable: false,
                      content: Center(child: CircularProgressIndicator()),
                    );

                    final success = await DatabaseHelper.resetWhilePersistingData();
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    AppHelper.showSnackBar(
                      context,
                      success ? 'Successfully updated database' : 'Failed to update database',
                    );
                  },
                ),
              ),
              const Padding(padding: EdgeInsets.all(10)),
              Center(
                child: GestureDetector(
                  onDoubleTap: () => DialogHelper.showDeleteConfirm(
                    context,
                    "database",
                    () async {
                      await DatabaseHelper.resetDatabase();
                      if (!context.mounted) return;
                      AppHelper.showSnackBar(context, 'Successfully reset database');
                    },
                  ),
                  child: Column(children: [
                    Text(
                      'Version: $appVersion',
                      style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                    ),
                    Text(
                      '(Double tap for DELETE DATABASE)',
                      style: TextStyle(color: Theme.of(context).colorScheme.shadow),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
