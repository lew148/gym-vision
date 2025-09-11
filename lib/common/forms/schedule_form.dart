import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/schedules/schedule.dart';
import 'package:gymvision/classes/db/schedules/schedule_item.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/models/db_models/schedule_model.dart';
import 'package:gymvision/common/common_functions.dart';
import 'package:gymvision/common/common_ui.dart';
import 'package:gymvision/common/forms/category_picker.dart';
import 'package:gymvision/common/forms/fields/custom_form_fields.dart';
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
        showSnackBar(context, 'Schedule is empty!');
        return;
      }

      int? scheduleId;
      var activeSchedule = await ScheduleModel.getActiveSchedule();

      if (isEdit && activeSchedule != null) {
        if (activeSchedule.name != nameController.text) {
          activeSchedule.name = nameController.text;
          await ScheduleModel.update(activeSchedule);
        }

        scheduleId = activeSchedule.id!;
        var success = await ScheduleModel.deleteScheduleItemsAndCategories(scheduleId);
        if (!success) return;
      } else {
        scheduleId = await ScheduleModel.insert(Schedule(
          name: nameController.text,
          type: selectedType!,
          active: activeSchedule == null,
          startDate: DateTime.now(),
        ));
      }

      if (scheduleId == null) throw Exception('Failed to add or edit Schedule');

      for (int order = 1; order <= categoriesByDay.length; order++) {
        var itemId = await ScheduleModel.insertScheduleItem(ScheduleItem(scheduleId: scheduleId, itemOrder: order));
        if (itemId == null) continue;

        var key = categoriesByDay.keys.toList()[order - 1];
        await ScheduleModel.insertScheduleCategories(itemId, categoriesByDay[key]);
      }
    } catch (ex) {
      if (!mounted) return;
      showSnackBar(context, 'Failed to add Schedule');
    }

    if (!mounted) return;
    Navigator.pop(context);
    if (widget.reloadParent != null) widget.reloadParent!();
  }

  void onTypeTap(ScheduleType type) {
    closeKeyboard();
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
        onTap: () => showCloseableBottomSheet(
          context,
          CateogryPicker(
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
                Text(selectedType == ScheduleType.split ? 'Day $day' : DateTimeHelper.dayStrings[day - 1]),
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: IntrinsicHeight(
        child: Column(
          children: [
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
                    Column(children: getFieldsScheduleItemFields().toList()),
                    const Padding(padding: EdgeInsetsGeometry.all(5)),
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
                        CommonUI.getDoneButton(onSubmit, isAdd: !isEdit),
                      ],
                    ),
                  ]),
          ],
        ),
      ),
    );
  }
}
