import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/user_settings.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/helpers/app_helper.dart';
import 'package:gymvision/helpers/database_helper.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/services/local_notification_service.dart';
import 'package:gymvision/models/db_models/flavour_text_schedule_model.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/components/stateless/header.dart';
import 'package:gymvision/widgets/debug_scaffold.dart';
import 'package:gymvision/widgets/forms/import_workout_form.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
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
      body: FutureBuilder(
        future: userSettings,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.shrink(); // loading
          }

          final settings = snapshot.data!;

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Theme'),
                  DropdownButton<UserTheme>(
                    value: settings.theme,
                    onChanged: (UserTheme? value) async {
                      try {
                        switch (value) {
                          case UserTheme.light:
                            {
                              settings.theme = UserTheme.light;
                              EasyDynamicTheme.of(context).changeTheme(dark: false, dynamic: false);
                              break;
                            }
                          case UserTheme.dark:
                            {
                              settings.theme = UserTheme.dark;
                              EasyDynamicTheme.of(context).changeTheme(dark: true, dynamic: false);
                              break;
                            }
                          case UserTheme.system:
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
                        if (context.mounted) showSnackBar(context, 'Failed to update theme.');
                      }

                      reloadState();
                    },
                    items: const [
                      DropdownMenuItem<UserTheme>(value: UserTheme.system, child: Text('System')),
                      DropdownMenuItem<UserTheme>(value: UserTheme.light, child: Text('Light')),
                      DropdownMenuItem<UserTheme>(value: UserTheme.dark, child: Text('Dark')),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Intra-set Rest Timer'),
                  Button(
                    style: ButtonCustomStyle(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5)),
                    text: settings.intraSetRestTimer == null
                        ? 'Set Timer'
                        : DateTimeHelper.getDurationString(settings.intraSetRestTimer!, noHours: true),
                    onTap: () => showDurationPicker(
                      context,
                      initialDuration: settings.intraSetRestTimer,
                      CupertinoTimerPickerMode.ms,
                      onSubmit: (Duration d) async {
                        try {
                          settings.intraSetRestTimer = d.inSeconds == 0 ? null : d;
                          await UserSettingsModel.update(settings);
                        } catch (ex) {
                          if (context.mounted) showSnackBar(context, 'Failed to update Intra-Set Rest Timer.');
                        }

                        reloadState();
                      },
                    ),
                  ),
                ],
              ),
              const Header(title: 'Developer Settings'),
              const CustomDivider(),
              Button.elevated(
                onTap: () async {
                  await FlavourTextScheduleModel.setRecentFlavourTextScheduleNotDismissed();
                  if (!context.mounted) return;
                  showSnackBar(context, 'Flavour Text Un-dismissed!');
                },
                text: 'Un-Dismiss Flavour Text',
              ),
              Button.elevated(
                onTap: () async {
                  await Sentry.captureMessage('(Ignore) This message was sent manually by a developer.');
                  if (context.mounted) showSnackBar(context, 'Sentry message sent!');
                },
                text: 'Send Error to Sentry',
              ),
              Button.elevated(
                onTap: () => LocalNotificationService.showTestNotification(),
                text: 'Show Test Notification',
              ),
              Button.elevated(
                onTap: () => showCloseableBottomSheet(context, const ImportWorkoutForm()),
                text: 'Import Workout',
              ),
              const Header(title: 'Database Settings'),
              const CustomDivider(),
              Button.elevated(
                text: 'Update Database',
                onTap: () => showConfirm(
                  context,
                  title: 'Update Database',
                  content: 'This will persist existing data',
                  onConfirm: () async {
                    final success = await DatabaseHelper.resetWhilePersistingData();
                    if (!context.mounted) return;
                    showSnackBar(context, success ? 'Successfully updated database' : 'Failed to update database');
                  },
                ),
              ),
              Button.elevated(
                text: 'Reset Database',
                style: ButtonCustomStyle.redIconAndText(),
                onTap: () => showDeleteConfirm(
                  context,
                  "database",
                  () async {
                    await DatabaseHelper.resetDatabase();
                    if (!context.mounted) return;
                    showSnackBar(context, 'Successfully reset database');
                  },
                  () => null,
                ),
              ),
              const Padding(padding: EdgeInsets.all(10)),
              Center(
                child: Text(
                  'Version: ${AppHelper.appVersion}',
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
