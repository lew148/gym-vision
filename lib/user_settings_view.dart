import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/user_settings.dart';
import 'package:gymvision/db/db.dart';
import 'package:gymvision/db/helpers/flavour_text_helper.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/shared/ui_helper.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'db/helpers/user_settings_helper.dart';
import 'globals.dart';

class UserSettingsView extends StatefulWidget {
  const UserSettingsView({super.key});

  @override
  State<UserSettingsView> createState() => _UserSettingsViewState();
}

class _UserSettingsViewState extends State<UserSettingsView> {
  @override
  Widget build(BuildContext context) {
    Future<UserSettings> userSettings = UserSettingsHelper.getUserSettings();
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

            void showResetDatabaseConfirm() {
              Widget cancelButton = TextButton(
                child: const Text("No"),
                onPressed: () {
                  Navigator.pop(context);
                },
              );

              Widget continueButton = TextButton(
                child: const Text(
                  "Yes",
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await DatabaseHelper.deleteDb();
                    await DatabaseHelper.openDb();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('DB successfully reset!')));
                  } catch (ex) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Failed reset DB: ${ex.toString()}')));
                  }
                },
              );

              AlertDialog alert = AlertDialog(
                title: const Text("Reset DB?"),
                content: const Text("Are you sure you would like PERMANENTLY delete your data?"),
                backgroundColor: Theme.of(context).cardColor,
                actions: [
                  cancelButton,
                  continueButton,
                ],
              );

              showDialog(
                context: context,
                builder: (context) => alert,
              );
            }

            return Column(
              children: [
                // dev buttons
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 5,
                  children: [
                    getElevatedPrimaryButton(
                      context,
                      ActionButton(
                        onTap: () async {
                          await FlavourTextHelper.setRecentFlavourTextScheduleNotDismissed();
                          if (!context.mounted) return;
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(content: Text('Flavour Text Un-dismissed!')));
                        },
                        text: 'Un-Dismiss Flavour Text',
                      ),
                    ),
                    getElevatedPrimaryButton(
                      context,
                      ActionButton(
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
                    getElevatedPrimaryButton(
                      context,
                      ActionButton(
                        onTap: () async {
                          try {
                            await DatabaseHelper.updateExercises();

                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(content: Text('Exercises updated successfully!')));
                          } catch (ex, stack) {
                            await Sentry.captureException(
                              ex,
                              stackTrace: stack,
                            );

                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(content: Text('Failed to update Exercises!')));
                          }
                        },
                        text: 'Update Exercises',
                      ),
                    ),
                    getElevatedPrimaryButton(
                      context,
                      ActionButton(
                        onTap: () async {
                          try {
                            await DatabaseHelper.restartDbWhilePersistingData();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Success')));
                          } catch (ex, stack) {
                            await Sentry.captureException(
                              ex,
                              stackTrace: stack,
                            );

                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text('Failed to persist data: ${ex.toString()}')));
                          }
                        },
                        text: 'Update DB (keep data)',
                      ),
                    ),
                    getOutlinedPrimaryButton(
                      ActionButton(
                        onTap: showResetDatabaseConfirm,
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
                        final newTheme = EnumToString.fromString(ThemeSetting.values, value!)!;
                        await UserSettingsHelper.setTheme(newTheme);
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
                Center(child: Text(appVersion)),
              ],
            );
          },
        ),
      ),
    );
  }
}
