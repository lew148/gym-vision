import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/user_setting.dart';
import 'package:gymvision/db/db.dart';
import 'package:gymvision/models/db_models/flavour_text_schedule_model.dart';
import 'package:gymvision/pages/common/common_functions.dart';
import 'package:gymvision/pages/common/common_ui.dart';
import 'package:gymvision/pages/common/debug_scaffold.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'models/db_models/user_settings_model.dart';
import 'globals.dart';

const String system = 'system';
const String dark = 'dark';
const String light = 'light';

class UserSettingsView extends StatefulWidget {
  const UserSettingsView({super.key});

  @override
  State<UserSettingsView> createState() => _UserSettingsViewState();
}

class _UserSettingsViewState extends State<UserSettingsView> {
  Future<UserSettings> userSettings = UserSettingsModel.getUserSettings();

  @override
  Widget build(BuildContext context) {
    return DebugScaffold(
      body: FutureBuilder(
        future: userSettings,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.shrink(); // loading
          }

          return Column(
            children: [
              // dev buttons
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 5,
                children: [
                  CommonUI.getElevatedPrimaryButton(
                    ButtonDetails(
                      onTap: () async {
                        await FlavourTextScheduleModel.setRecentFlavourTextScheduleNotDismissed();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Flavour Text Un-dismissed!')));
                      },
                      text: 'Un-Dismiss Flavour Text',
                    ),
                  ),
                  CommonUI.getElevatedPrimaryButton(
                    ButtonDetails(
                      onTap: () async {
                        try {
                          throw ("(IGNORE) This error was sent manually by a developer!");
                        } catch (ex, stack) {
                          await Sentry.captureException(
                            ex,
                            stackTrace: stack,
                          );

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(content: Text('Error sent to Sentry!')));
                        }
                      },
                      text: 'Send Error to sentry',
                    ),
                  ),
                  const Divider(),
                  CommonUI.getElevatedPrimaryButton(
                    ButtonDetails(
                      onTap: () => CommonFunctions.showDeleteConfirm(
                        context,
                        "DATABASE",
                        () async {
                          DatabaseHelper.resetWhilePersistingData().then((s) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(s
                                    ? 'Successfully reset DB, while persisting data'
                                    : 'Failed to reset DB, while persisting data')));
                          });
                        },
                        () => null,
                      ),
                      text: 'RESET DB (WHILE KEEPING DATA)',
                    ),
                  ),
                  CommonUI.getElevatedPrimaryButton(
                    ButtonDetails(
                      onTap: () => CommonFunctions.showDeleteConfirm(
                        context,
                        "DATABASE",
                        () async {
                          await DatabaseHelper.deleteDb();
                          await DatabaseHelper.openDb();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(content: Text('Successfully reset DB')));
                        },
                        () => null,
                      ),
                      text: 'DELETE DB',
                      style: ButtonDetailsStyle.redIconAndText,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Theme',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  DropdownButton<String>(
                    value: system,
                    onChanged: (String? value) async {
                      switch (value) {
                        case light:
                          EasyDynamicTheme.of(context).changeTheme(dark: false, dynamic: false);
                          break;
                        case dark:
                          EasyDynamicTheme.of(context).changeTheme(dark: true, dynamic: false);
                          break;
                        case system:
                          EasyDynamicTheme.of(context).changeTheme(dynamic: true);
                          break;
                      }
                    },
                    items: const [
                      DropdownMenuItem<String>(value: system, child: Text('System')),
                      DropdownMenuItem<String>(value: light, child: Text('Light')),
                      DropdownMenuItem<String>(value: dark, child: Text('Dark')),
                    ],
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.all(20)),
              const Center(child: Text('Version: $appVersion')),
            ],
          );
        },
      ),
    );
  }
}
