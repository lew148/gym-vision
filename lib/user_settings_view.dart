import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/user_settings.dart';
import 'package:gymvision/db/db.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/shared/ui_helper.dart';
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

            return Column(
              children: [
                // dev buttons
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 5,
                  children: [
                    // ElevatedButton(
                    //   onPressed: () async {
                    //     await FlavourTextHelper.setRecentFlavourTextScheduleNotDismissed();
                    //   },
                    //   child: const Text('Un-Dismiss Flavour Text'),
                    // ),
                    getElevatedPrimaryButton(
                      context,
                      ActionButton(
                        onTap: () async => await DatabaseHelper.updateExercises(),
                        text: 'Update Exercises',
                      ),
                    ),
                    getElevatedPrimaryButton(
                      context,
                      ActionButton(
                        onTap: () async => await DatabaseHelper.restartDbWhilePersistingData(),
                        text: 'Update DB (keep data)',
                      ),
                    ),
                    // ElevatedButton(
                    //   onPressed: () async => await DatabaseHelper.deleteDb(),
                    //   style: ButtonStyle(
                    //     backgroundColor: MaterialStatePropertyAll<Color>(
                    //       Theme.of(context).colorScheme.tertiary,
                    //     ),
                    //   ),
                    //   child: const Text('Delete DB'),
                    // ),
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
