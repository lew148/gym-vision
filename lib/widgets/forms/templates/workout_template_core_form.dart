import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/helpers/enum_helper.dart';
import 'package:gymvision/models/db_models/workout_template_model.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/static_data/helpers.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/prop_display.dart';
import 'package:gymvision/widgets/forms/fields/category_picker.dart';
import 'package:gymvision/widgets/forms/fields/custom_form_field.dart';

class WorkoutTemplateCoreForm extends StatefulWidget {
  final String? initialName;
  final WorkoutTemplate? template;

  const WorkoutTemplateCoreForm({
    super.key,
    this.initialName,
    this.template,
  });

  @override
  State<StatefulWidget> createState() => _WorkoutTemplateCoreFormState();
}

class _WorkoutTemplateCoreFormState extends State<WorkoutTemplateCoreForm> {
  late bool _isEdit;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  List<Category> _categories = [];
  List<String> _existingNames = [];

  @override
  void initState() {
    super.initState();

    _isEdit = widget.template != null;
    if (_isEdit) {
      _nameController.text = widget.template!.name;
      _categories = widget.template!.getCategories();
    } else {
      _nameController.text = widget.initialName ?? '';
    }

    loadExistingNames();
  }

  Future<void> loadExistingNames() async {
    final List<String> names = await WorkoutTemplateModel.getExistingNames();
    names.remove(_nameController.text);
    setState(() {
      _existingNames = names;
    });
  }

  void onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text;
    final categories = _categories.map((c) => EnumHelper.enumToString(c)).toList().join(',');

    if (_isEdit) {
      Navigator.pop(context);
      final template = widget.template!;
      template.name = name;
      template.categories = categories;
      await WorkoutTemplateModel.update(template);
      return;
    }

    var nav = Navigator.of(context);

    final id = await WorkoutTemplateModel.insert(WorkoutTemplate(
      name: name,
      categories: categories,
      exerciseOrder: '',
    ));

    nav.pop(id);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(children: [
        Row(children: [
          Expanded(
            child: CustomFormField.string(
              controller: _nameController,
              label: 'Name',
              autofocus: true,
              canBeBlank: false,
              maxLength: 100,
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
              children: _categories
                  .map((c) => PropDisplay(
                        text: c.displayName,
                        onCard: true,
                        size: PropDisplaySize.small,
                      ))
                  .toList(),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsetsGeometry.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [Button.done(isAdd: !_isEdit, onTap: onSubmit)],
          ),
        )
      ]),
    );
  }
}
