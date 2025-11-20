import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/workout_templates/workout_template.dart';
import 'package:gymvision/helpers/functions/app_helper.dart';
import 'package:gymvision/helpers/functions/bottom_sheet_helper.dart';
import 'package:gymvision/helpers/functions/dialog_helper.dart';
import 'package:gymvision/helpers/functions/workout_helper.dart';
import 'package:gymvision/models/db_models/workout_template_model.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/static_data/helpers.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/components/stateless/category_filter.dart';
import 'package:gymvision/widgets/components/stateless/custom_card.dart';
import 'package:gymvision/widgets/components/stateless/options_menu.dart';
import 'package:gymvision/widgets/components/stateless/prop_display.dart';
import 'package:gymvision/widgets/components/stateless/shimmer_load.dart';
import 'package:gymvision/widgets/components/stateless/splash_text.dart';
import 'package:gymvision/widgets/debug_scaffold.dart';
import 'package:gymvision/widgets/forms/templates/workout_template_core_form.dart';
import 'package:gymvision/widgets/forms/templates/edit_workout_template_form.dart';

class Templates extends StatefulWidget {
  final List<Category>? filterCategories;
  final Function(int templateId)? onAddTap;

  const Templates({
    super.key,
    this.filterCategories,
    this.onAddTap,
  });

  @override
  State<Templates> createState() => _TemplatesState();
}

class _TemplatesState extends State<Templates> {
  final TextEditingController _searchTextController = TextEditingController();
  late List<Category> _filterCategories;
  late Future<List<WorkoutTemplate>> _templatesFuture;
  late bool _isSelect;
  String? searchString;

  @override
  void initState() {
    super.initState();
    _filterCategories = widget.filterCategories ?? [];
    _templatesFuture = WorkoutTemplateModel.getAll(withNote: true, filterCategories: _filterCategories);
    _isSelect = widget.onAddTap != null;
  }

  void reload() => setState(() {
        _templatesFuture = WorkoutTemplateModel.getAll(withNote: true, filterCategories: _filterCategories);
      });

  Future onAddTemplate({String? name}) async {
    final int? newId = await BottomSheetHelper.showCloseableBottomSheet(
      context,
      WorkoutTemplateCoreForm(initialName: name),
      title: 'Add Template',
    );
    if (newId == null) return;
    await onEditTemplate(newId);
  }

  Future onEditTemplate(int templateId) async {
    await BottomSheetHelper.showFullScreenBottomSheet(context, child: EditWorkoutTemplateForm(templateId: templateId));
    reload();
  }

  Future onDeleteTemplate(int id) async {
    await WorkoutTemplateModel.delete(id);
    reload();
  }

  void setSearchValue(String? s) => setState(() {
        searchString = s;
      });

  Widget getLoadingView() => const Column(
        children: [
          ShimmerLoad(height: 80),
          ShimmerLoad(height: 80),
          ShimmerLoad(height: 80),
        ],
      );

  Widget getEmptyTemplatesView() => searchString != null
      ? Column(children: [
          Text('No results for: ${_searchTextController.text}'),
          const Padding(padding: EdgeInsetsGeometry.all(5)),
          Button.elevated(
            icon: Icons.add_rounded,
            text: 'Add ${_searchTextController.text}',
            onTap: () => onAddTemplate(name: _searchTextController.text),
          ),
        ])
      : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _filterCategories.isNotEmpty
              ? [
                  SplashText(
                    title: 'No Template for these Categories',
                    description: 'Tap + to get started',
                  ),
                  Button.elevated(
                    icon: Icons.add_rounded,
                    text: 'Add a Template',
                    onTap: onAddTemplate,
                  ),
                ]
              : [
                  SplashText.none(item: 'Templates'),
                  Button.elevated(
                    icon: Icons.add_rounded,
                    text: 'Add a Template',
                    onTap: onAddTemplate,
                  ),
                ],
        );

  Widget getTemplatesList(List<WorkoutTemplate> templates) => ListView(
        children: templates
            .map((wt) => GestureDetector(
                  onTap: () => onEditTemplate(wt.id!),
                  child: CustomCard(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 10,
                                runSpacing: 5,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsGeometry.only(left: 2.5),
                                    child: Text(wt.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ),
                                  if (wt.categories != '')
                                    Wrap(
                                      alignment: WrapAlignment.start,
                                      spacing: 5,
                                      children: wt
                                          .getCategories()
                                          .map((c) => PropDisplay(
                                                text: c.displayName,
                                                onCard: true,
                                                size: PropDisplaySize.small,
                                              ))
                                          .toList(),
                                    ),
                                ],
                              ),
                              if (wt.note != null)
                                Text(
                                  wt.note!.note,
                                  style: TextStyle(color: Theme.of(context).colorScheme.shadow),
                                  softWrap: true,
                                  textAlign: TextAlign.start,
                                ),
                            ],
                          ),
                        ),
                        _isSelect
                            ? Button(
                                icon: Icons.copy_rounded,
                                onTap: () => widget.onAddTap!(wt.id!),
                                style: ButtonCustomStyle.primaryIconOnly(),
                              )
                            : OptionsMenu(
                                title: wt.name,
                                buttons: [
                                  Button.add(
                                    onTap: () async {
                                      Navigator.pop(context);
                                      await WorkoutHelper.createActiveWorkoutFromTemplate(context, templateId: wt.id!);
                                    },
                                    text: 'Create Workout from Template',
                                  ),
                                  Button.edit(
                                    onTap: () async {
                                      Navigator.pop(context);
                                      await onEditTemplate(wt.id!);
                                    },
                                    text: 'Edit Template',
                                  ),
                                  Button.delete(
                                    text: 'Delete Template',
                                    onTap: () async {
                                      Navigator.pop(context);
                                      await DialogHelper.showDeleteConfirm(
                                        context,
                                        'Template',
                                        () => onDeleteTemplate(wt.id!),
                                      );
                                    },
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      );

  @override
  Widget build(BuildContext context) {
    return DebugScaffold(
      ignoreDefaults: true,
      customAppBarTitle: Text(_isSelect ? 'Select Template' : 'Templates'),
      body: FutureBuilder(
        future: _templatesFuture,
        builder: (context, snapshot) {
          var templates = snapshot.data;
          if (templates != null && searchString != null) {
            templates = templates.where((t) => t.name.contains(RegExp(searchString!, caseSensitive: false))).toList();
          }

          return Column(children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: CategoryFilter(
                    filterCategories: _filterCategories,
                    onChange: (cs) => setState(() {
                      _filterCategories = cs;
                      _templatesFuture = WorkoutTemplateModel.getAll(withNote: true, filterCategories: cs);
                    }),
                  ),
                ),
                Button.add(onTap: onAddTemplate),
              ],
            ),
            Row(children: [
              Expanded(
                child: CupertinoSearchTextField(
                  controller: _searchTextController,
                  placeholder: 'Search for exercise...',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  onChanged: (s) => setSearchValue(s),
                  suffixIcon: const Icon(Icons.clear_rounded),
                  onSuffixTap: () {
                    AppHelper.closeKeyboard();
                    setSearchValue(null);
                    _searchTextController.clear();
                  },
                ),
              ),
            ]),
            const Padding(padding: EdgeInsetsGeometry.all(5)),
            Expanded(
              child: snapshot.connectionState == ConnectionState.waiting
                  ? getLoadingView()
                  : templates == null || templates.isEmpty
                      ? getEmptyTemplatesView()
                      : getTemplatesList(templates),
            ),
          ]);
        },
      ),
    );
  }
}
