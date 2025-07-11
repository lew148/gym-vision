import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/schedules/schedule.dart';
import 'package:gymvision/classes/db/schedules/schedule_item.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/globals.dart';
import 'package:gymvision/models/db_models/schedule_model.dart';
import 'package:gymvision/pages/common/common_functions.dart';
import 'package:gymvision/pages/common/common_ui.dart';
import 'package:gymvision/pages/forms/add_category_to_workout_form.dart';
import 'package:gymvision/pages/forms/fields/custom_form_fields.dart';
import 'package:gymvision/static_data/enums.dart';
import 'package:gymvision/static_data/helpers.dart';

const splitMinDays = 3;
const weeklyDays = 7;
const biweeklyDays = 14;

class ScheduleForm extends StatefulWidget {
  final Function()? reloadParent;
  final Schedule? schedule;

  const ScheduleForm({
    super.key,
    this.reloadParent,
    this.schedule,
  });

  @override
  State<ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<ScheduleForm> {
  final formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  ScheduleType? selectedType;
  Map<int, List<Category>> categoriesByDay = {};
  late bool isEdit;

  @override
  void initState() {
    super.initState();

    isEdit = widget.schedule != null;
    if (isEdit) {
      final schedule = widget.schedule!;
      nameController.text = schedule.name;
      selectedType = schedule.type;

      if (schedule.items != null && schedule.items!.isNotEmpty) {
        for (int i = 0; i < schedule.items!.length; i++) {
          var item = schedule.items![i];
          categoriesByDay[item.itemOrder] = item.scheduleCategories!.map((sc) => sc.category).toList();
        }
      } else {
        onTypeTap(schedule.type);
      }
    }
  }

  void onSubmit() async {
    try {
      if (!formKey.currentState!.validate() || nameController.text.isEmpty) return;
      if (categoriesByDay.entries.every((e) => e.value.isEmpty)) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Schedule was empty!')));
        return;
      }

      if (isEdit) {
        //todo: do edit

        return;
      }

      if (selectedType == ScheduleType.weekly) {
        final sundayEntry = categoriesByDay.entries.first;
        categoriesByDay.remove(sundayEntry.key);
        categoriesByDay[sundayEntry.key] = sundayEntry.value;
      } else if (selectedType == ScheduleType.biweekly) {
        // todo swap both sundays
      }

      var activeSchedule = await ScheduleModel.getActiveSchedule();

      var scheduleId = await ScheduleModel.insertSchedule(Schedule(
        name: nameController.text,
        type: selectedType!,
        active: activeSchedule == null,
      ));

      if (scheduleId == null) throw Exception('Failed to insert Schedule');

      for (int order = 1; order <= categoriesByDay.length; order++) {
        var itemId = await ScheduleModel.insertScheduleItem(ScheduleItem(scheduleId: scheduleId, itemOrder: order));
        if (itemId == null) continue;

        var key = categoriesByDay.keys.toList()[order - 1];
        await ScheduleModel.insertScheduleCategories(itemId, categoriesByDay[key]);
      }
    } catch (ex) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add Schedule')));
    }

    if (!mounted) return;
    Navigator.pop(context);
    if (widget.reloadParent != null) widget.reloadParent!();
  }

  void onTypeTap(ScheduleType type) {
    CommonFunctions.closeKeyboard();
    int numDays;

    switch (type) {
      case ScheduleType.weekly:
        numDays = weeklyDays;
        break;
      case ScheduleType.biweekly:
        numDays = biweeklyDays;
        break;
      case ScheduleType.split:
        numDays = splitMinDays;
        break;
    }

    List<int> nums = List.generate(numDays, (i) => i + 1);

    setState(() {
      selectedType = type;
      categoriesByDay = {
        for (var i in nums) i: [] // empty category list for rest day
      };
    });
  }

  Widget getDayField(int day) {
    final categoriesForDay = categoriesByDay[day];
    return CommonUI.getCard(
      context,
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => CommonFunctions.showBottomSheet(
          context,
          CateogryPickerModal(
            selectedCategories: categoriesForDay,
            onChange: (c) {
              setState(() {
                categoriesByDay[day] = c;
              });
            },
          ),
        ),
        child: Padding(
          padding: const EdgeInsetsGeometry.all(10),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(selectedType == ScheduleType.split ? 'Day $day' : getDayStringFromInt(day)),
                categoriesForDay == null || categoriesForDay.isEmpty
                    ? CommonUI.getRestWidget()
                    : Expanded(
                        child: Padding(
                          padding: const EdgeInsetsGeometry.only(left: 10),
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            children: categoriesForDay
                                .map((c) => Padding(
                                      padding: const EdgeInsetsGeometry.fromLTRB(10, 0, 0, 2.5),
                                      child: Text(c.displayName),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
              ],
            ),
            const Padding(padding: EdgeInsetsGeometry.all(5)),
            CommonUI.getDivider(height: 0)
          ]),
        ),
      ),
    );
  }

  Iterable<Widget> getFieldsScheduleItemFields() sync* {
    for (int i = 1; i <= categoriesByDay.length; i++) {
      yield getDayField(i);
    }
  }

  Widget getWeeklyForm() {
    final fields = getFieldsScheduleItemFields().toList();

    // move sunday (day 1) to end of list
    final sunday = fields.first;
    fields.removeAt(0);
    fields.add(sunday);
    return Column(children: fields);
  }

  Widget getSplitForm() => Column(children: getFieldsScheduleItemFields().toList());

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: IntrinsicHeight(
        child: Column(
          children: [
            CommonUI.getSectionTitle(context, 'Add Schedule'),
            CommonUI.getDivider(),
            CustomFormFields.stringField(controller: nameController, label: 'Name', autofocus: !isEdit, maxLength: 25),
            const Padding(padding: EdgeInsetsGeometry.all(5)),
            selectedType == null
                ? SizedBox(
                    height: 80,
                    child: Row(children: [
                      Expanded(
                        child: CommonUI.getCard(
                          context,
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () => onTypeTap(ScheduleType.weekly),
                            child: const Padding(
                              padding: EdgeInsetsGeometry.all(20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.calendar_month_rounded),
                                  Padding(padding: EdgeInsetsGeometry.all(2.5)),
                                  Text('Weekly'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: CommonUI.getCard(
                          context,
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () => onTypeTap(ScheduleType.split),
                            child: const Padding(
                              padding: EdgeInsetsGeometry.all(20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.repeat_rounded),
                                  Padding(padding: EdgeInsetsGeometry.all(2.5)),
                                  Text('Split'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  )
                : Column(children: [
                    switch (selectedType!) {
                      ScheduleType.weekly => getWeeklyForm(),
                      ScheduleType.split => getSplitForm(),
                      ScheduleType.biweekly => throw UnimplementedError(),
                    },
                    Row(
                      mainAxisAlignment:
                          selectedType == ScheduleType.split ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
                      children: [
                        if (selectedType == ScheduleType.split)
                          Row(children: [
                            CommonUI.getTextButton(
                              ButtonDetails(
                                disabled: categoriesByDay.length >= weeklyDays,
                                onTap: () {
                                  setState(() {
                                    categoriesByDay[categoriesByDay.length + 1] = [];
                                  });
                                },
                                icon: Icons.add_rounded,
                              ),
                            ),
                            if (categoriesByDay.length > splitMinDays)
                              CommonUI.getTextButton(
                                ButtonDetails(
                                  onTap: () {
                                    setState(() {
                                      categoriesByDay.remove(categoriesByDay.entries.last.key);
                                    });
                                  },
                                  icon: Icons.horizontal_rule_rounded,
                                  style: ButtonDetailsStyle.redIcon,
                                ),
                              ),
                          ]),
                        CommonUI.getDoneButton(onSubmit),
                      ],
                    ),
                  ]),
          ],
        ),
      ),
    );
  }
}
