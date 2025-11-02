import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/models/db_models/workout_template_model.dart';
import 'package:gymvision/static_data/helpers.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/custom_card.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/components/stateless/header.dart';
import 'package:gymvision/widgets/components/stateless/options_menu.dart';
import 'package:gymvision/widgets/components/stateless/prop_display.dart';
import 'package:gymvision/widgets/components/stateless/shimmer_load.dart';
import 'package:gymvision/widgets/components/stateless/splash_text.dart';
import 'package:gymvision/widgets/debug_scaffold.dart';
import 'package:gymvision/widgets/forms/workout_template_form.dart';

class Templates extends StatefulWidget {
  const Templates({super.key});

  @override
  State<Templates> createState() => _TemplatesState();
}

class _TemplatesState extends State<Templates> {
  Future<List<WorkoutTemplate>> _workoutTemplateFuture = WorkoutTemplateModel.getAll();

  void reload() => setState(() {
        _workoutTemplateFuture = WorkoutTemplateModel.getAll();
      });

  Future onAddEditTemplate({int? templateId}) async {
    await showFullScreenBottomSheet(context, child: WorkoutTemplateForm(templateId: templateId));
    reload();
  }

  Future onDeleteTemplate(int id) async {
    await WorkoutTemplateModel.delete(id);
    reload();
  }

  @override
  Widget build(BuildContext context) {
    return DebugScaffold(
      ignoreDefaults: true,
      body: Column(children: [
        Header(
          title: 'Templates',
          actions: [
            Button.add(onTap: onAddEditTemplate),
          ],
        ),
        CustomDivider(),
        Expanded(
          child: FutureBuilder(
              future: _workoutTemplateFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
                  return const Column(
                    children: [
                      ShimmerLoad(height: 80),
                      ShimmerLoad(height: 80),
                      ShimmerLoad(height: 80),
                      ShimmerLoad(height: 80),
                    ],
                  );
                }

                final templates = snapshot.data!;
                if (templates.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SplashText.none(item: 'Templates'),
                      Button.elevated(
                        icon: Icons.add_rounded,
                        text: 'Add a Template',
                        onTap: onAddEditTemplate,
                      ),
                    ],
                  );
                }

                return ListView(
                  children: templates
                      .map((wt) => GestureDetector(
                            onTap: () => onAddEditTemplate(templateId: wt.id!),
                            child: CustomCard(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(wt.name, style: TextStyle(fontWeight: FontWeight.bold)),
                                      if (wt.categories != '')
                                        Padding(
                                          padding: EdgeInsetsGeometry.only(top: 5),
                                          child: Wrap(
                                            alignment: WrapAlignment.start,
                                            spacing: 5,
                                            children: wt
                                                .getCategories()
                                                .map((c) => PropDisplay(text: c.displayName, onCard: true))
                                                .toList(),
                                          ),
                                        ),
                                    ],
                                  ),
                                  OptionsMenu(
                                    title: 'Template: ${wt.name}',
                                    buttons: [
                                      Button.add(onTap: () => null, text: 'Create Workout from Template'),
                                      Button.edit(
                                        onTap: () => onAddEditTemplate(templateId: wt.id!),
                                        text: 'Edit Template',
                                      ),
                                      Button.delete(
                                          text: 'Delete Template', onTap: () async => onDeleteTemplate(wt.id!)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                );
              }),
        ),
      ]),
    );
  }
}
