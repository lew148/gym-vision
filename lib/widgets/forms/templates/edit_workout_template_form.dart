import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/models/db_models/workout_template_model.dart';
import 'package:gymvision/static_data/helpers.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/custom_divider.dart';
import 'package:gymvision/widgets/components/stateless/prop_display.dart';
import 'package:gymvision/widgets/components/stateless/shimmer_load.dart';
import 'package:gymvision/widgets/forms/templates/template_exercises.dart';
import 'package:gymvision/widgets/forms/templates/workout_template_core_form.dart';

class EditWorkoutTemplateForm extends StatefulWidget {
  final int templateId;

  const EditWorkoutTemplateForm({
    super.key,
    required this.templateId,
  });

  @override
  State<StatefulWidget> createState() => _EditWorkoutTemplateFormState();
}

class _EditWorkoutTemplateFormState extends State<EditWorkoutTemplateForm> {
  late Future<WorkoutTemplate?> _future;

  @override
  void initState() {
    super.initState();
    _future = WorkoutTemplateModel.getTemplate(widget.templateId);
  }

  void reload() => setState(() {
        _future = WorkoutTemplateModel.getTemplate(widget.templateId);
      });

  Widget getActionRow() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Button(icon: Icons.refresh, onTap: reload),
          Button.done(onTap: () => Navigator.pop(context)),
        ],
      );

  Widget getNameAndCategoryForm(WorkoutTemplate template) => Column(children: [
        Row(children: [
          Expanded(
            child: Padding(
              padding: EdgeInsetsGeometry.only(left: 5),
              child: Text(template.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ),
          const Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 5)),
          Button.edit(onTap: () => showCloseableBottomSheet(context, WorkoutTemplateCoreForm(template: template))),
        ]),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              alignment: WrapAlignment.start,
              spacing: 5,
              children: template
                  .getCategories()
                  .map((c) => PropDisplay(
                        text: c.displayName,
                        size: PropDisplaySize.small,
                      ))
                  .toList(),
            ),
          ],
        ),
      ]);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
          return Column(children: [
            ShimmerLoad(height: 50),
            ShimmerLoad(height: 50),
            ShimmerLoad(height: 200),
          ]);
        }

        final template = snapshot.data!;
        return Column(children: [
          getActionRow(),
          CustomDivider(shadow: true),
          getNameAndCategoryForm(template),
          Expanded(child: TemplateExercises(template: template, reload: reload)),
        ]);
      },
    );
  }
}
