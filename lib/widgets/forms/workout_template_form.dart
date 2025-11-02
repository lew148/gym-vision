import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/helpers/enum_helper.dart';
import 'package:gymvision/models/db_models/workout_template_model.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/static_data/helpers.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/header.dart';
import 'package:gymvision/widgets/components/stateless/prop_display.dart';
import 'package:gymvision/widgets/forms/fields/category_picker.dart';
import 'package:gymvision/widgets/forms/fields/custom_form_field.dart';

class WorkoutTemplateForm extends StatefulWidget {
  final int? templateId;

  const WorkoutTemplateForm({
    super.key,
    this.templateId,
  });

  @override
  State<StatefulWidget> createState() => _WorkoutTemplateFormState();
}

class _WorkoutTemplateFormState extends State<WorkoutTemplateForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  List<Category> _categories = [];
  List<String> _existingNames = ['lol'];

  @override
  void initState() {
    super.initState();
  }

  void onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context);

    await WorkoutTemplateModel.insert(WorkoutTemplate(
      name: _nameController.text,
      categories: _categories.map((c) => EnumHelper.enumToString(c)).toList().join(','),
      exerciseOrder: '',
    ));
  }

  @override
  Widget build(BuildContext context) {
    // return FutureBuilder(
    //   future: _future,
    //   builder: (context, snapshot) {
    return Form(
      key: _formKey,
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Button.check(onTap: onSubmit),
          ],
        ),
        const Padding(padding: EdgeInsetsGeometry.all(5)),
        Row(children: [
          Expanded(
            child: CustomFormField.string(
              controller: _nameController,
              label: 'Name',
              autofocus: true,
              canBeBlank: false,
              maxLength: 250,
              validator: (s) => _existingNames.contains(s) ? 'Name must be unique' : null,
            ),
          ),
          const Padding(padding: EdgeInsetsGeometry.symmetric(horizontal: 10)),
          Button(
            icon: Icons.category_rounded,
            onTap: () => showCloseableBottomSheet(
              context,
              CategoryPicker(
                selectedCategories: _categories,
                onChange: (c) => setState(() {
                  _categories = c;
                }),
                includeMiscCategories: false,
              ),
            ),
            style: ButtonCustomStyle(padding: const EdgeInsets.all(10)),
          ),
        ]),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              alignment: WrapAlignment.start,
              spacing: 5,
              children: _categories.map((c) => PropDisplay(text: c.displayName, onCard: true)).toList(),
            ),
          ],
        ),
        Padding(padding: const EdgeInsetsGeometry.only(top: 10)),
        Header(title: 'Exercises')
      ]),
    );
    //   },
    // );
  }
}
