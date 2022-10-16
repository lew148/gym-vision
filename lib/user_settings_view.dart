import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/db/classes/user_settings.dart';
import 'package:gymvision/enums.dart';
import 'db/helpers/user_settings_helper.dart';

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
              return const Center(child: Text('Loading...'));
            }

            themeSetting = snapshot.data!.theme;

            return Column(
              children: [
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
                        final newTheme = EnumToString.fromString(
                            ThemeSetting.values, value!)!;
                        await UserSettingsHelper.setTheme(newTheme);
                        setState(() {
                          themeSetting = newTheme;

                          switch (newTheme) {
                            case ThemeSetting.light:
                              EasyDynamicTheme.of(context)
                                  .changeTheme(dark: false, dynamic: false);
                              break;
                            case ThemeSetting.dark:
                              EasyDynamicTheme.of(context)
                                  .changeTheme(dark: true, dynamic: false);
                              break;
                            case ThemeSetting.system:
                              EasyDynamicTheme.of(context)
                                  .changeTheme(dynamic: true);
                              break;
                          }
                        });
                      },
                      items: ThemeSetting.values
                          .map<DropdownMenuItem<String>>((ts) {
                        return DropdownMenuItem<String>(
                          value: ts.name,
                          child: Text(ts.name),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.all(20)),
                const Center(child: Text('V 1.0.0.3')),
              ],
            );
          },
        ),
      ),
    );
  }
}
