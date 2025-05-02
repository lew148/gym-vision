import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/user_setting.dart';
import 'package:gymvision/db/db.dart';
import 'package:gymvision/models/db_models/flavour_text_schedule_model.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/pages/common/common_functions.dart';
import 'package:gymvision/pages/common/common_ui.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'models/db_models/user_settings_model.dart';
import 'globals.dart';

class UserSettingsView extends StatefulWidget {
  const UserSettingsView({super.key});

  @override
  State<UserSettingsView> createState() => _UserSettingsViewState();
}

class _UserSettingsViewState extends State<UserSettingsView> {
  @override
  Widget build(BuildContext context) {
    Future<UserSettings> userSettings = UserSettingsModel.getUserSettings();
    late ThemeSetting themeSetting;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder(
          future: userSettings,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink(); // loading
            }

            themeSetting = snapshot.data!.theme;

            return Column(
              children: [
                // dev buttons
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 5,
                  children: [
                    CommonUi.getElevatedPrimaryButton(
                      context,
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
                    CommonUi.getElevatedPrimaryButton(
                      context,
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
                    // UiHelper.getElevatedPrimaryButton(
                    //   context,
                    //   ActionButton(
                    //     onTap: () async {
                    //       try {
                    //         await DatabaseHelper.restartDbWhilePersistingData();
                    //         if (!context.mounted) return;
                    //         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Success')));
                    //       } catch (ex, stack) {
                    //         await Sentry.captureException(
                    //           ex,
                    //           stackTrace: stack,
                    //         );

                    //         if (!context.mounted) return;
                    //         ScaffoldMessenger.of(context)
                    //             .showSnackBar(SnackBar(content: Text('Failed to persist data: ${ex.toString()}')));
                    //       }
                    //     },
                    //     text: 'Update DB (keep data)',
                    //   ),
                    // ),
                    CommonUi.getOutlinedPrimaryButton(
                      context,
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
                        text: 'RESET DB',
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
                      value: themeSetting.name,
                      onChanged: (String? value) async {
                        final newTheme = stringToEnum(value!, ThemeSetting.values)!;
                        await UserSettingsModel.setTheme(newTheme);
                        setState(() {
                          themeSetting = newTheme;

                          switch (newTheme) {
                            case ThemeSetting.light:
                              EasyDynamicTheme.of(context).changeTheme(dark: false, dynamic: false);
                              break;
                            case ThemeSetting.dark:
                              EasyDynamicTheme.of(context).changeTheme(dark: true, dynamic: false);
                              break;
                            case ThemeSetting.system:
                              EasyDynamicTheme.of(context).changeTheme(dynamic: true);
                              break;
                          }
                        });
                      },
                      items: const [
                        DropdownMenuItem<String>(value: 'light', child: Text('Light')),
                        DropdownMenuItem<String>(value: 'dark', child: Text('Dark')),
                        DropdownMenuItem<String>(value: 'system', child: Text('System'))
                      ],
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.all(20)),
                const Center(child: Text('Ver: $appVersion')),
              ],
            );
          },
        ),
      ),
    );
  }
}
