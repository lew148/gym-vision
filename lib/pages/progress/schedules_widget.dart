import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/schedules/schedule.dart';
import 'package:gymvision/classes/db/schedules/schedule_item.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/models/db_models/schedule_model.dart';
import 'package:gymvision/pages/common/common_functions.dart';
import 'package:gymvision/pages/common/common_ui.dart';
import 'package:gymvision/pages/forms/schedule_form.dart';
import 'package:gymvision/static_data/helpers.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SchedulesWidget extends StatefulWidget {
  const SchedulesWidget({super.key});

  @override
  State<SchedulesWidget> createState() => _SchedulesWidgetState();
}

class _SchedulesWidgetState extends State<SchedulesWidget> {
  late Future<Schedule?> activeSchedule = ScheduleModel.getActiveSchedule(shallow: false);
  late Future<List<Schedule>> schedules = ScheduleModel.getSchedules();

  final biweeklyPageController = PageController(viewportFraction: 0.8, keepPage: true);

  void reloadState() => setState(() {
        activeSchedule = ScheduleModel.getActiveSchedule(shallow: false);
        schedules = ScheduleModel.getSchedules();
      });

  Widget getTextDisplayWidget(String text) => CommonUI.getCard(
        context,
        Padding(
          padding: const EdgeInsetsGeometry.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: TextStyle(color: Theme.of(context).colorScheme.shadow),
              ),
            ],
          ),
        ),
      );

  Widget getScheduleItemWidget(String title, ScheduleItem? si) => CommonUI.getCard(
        context,
        Padding(
          padding: const EdgeInsetsGeometry.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              si?.scheduleCategories == null || si!.scheduleCategories!.isEmpty
                  ? CommonUI.getRestWidget()
                  : Expanded(
                      child: Wrap(
                        alignment: WrapAlignment.end,
                        children: si.scheduleCategories!
                            .map((c) => Padding(
                                  padding: const EdgeInsetsGeometry.only(left: 10),
                                  child: Text(c.category.displayName),
                                ))
                            .toList(),
                      ),
                    ),
            ],
          ),
        ),
      );

  Widget getWeeklyScheduleWidget(List<ScheduleItem> items) {
    return Column(
      children: [
        getScheduleItemWidget('Monday', items.firstWhereOrNull((si) => si.itemOrder == 1)),
        getScheduleItemWidget('Tuesday', items.firstWhereOrNull((si) => si.itemOrder == 2)),
        getScheduleItemWidget('Wednesday', items.firstWhereOrNull((si) => si.itemOrder == 3)),
        getScheduleItemWidget('Thursday', items.firstWhereOrNull((si) => si.itemOrder == 4)),
        getScheduleItemWidget('Friday', items.firstWhereOrNull((si) => si.itemOrder == 5)),
        getScheduleItemWidget('Saturday', items.firstWhereOrNull((si) => si.itemOrder == 6)),
        getScheduleItemWidget('Sunday', items.firstWhereOrNull((si) => si.itemOrder == 7)),
      ],
    );
  }

  Widget getBiWeeklyScheduleWidget(List<ScheduleItem> items) {
    final pages = [
      Column(children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('Week 1', style: TextStyle(fontWeight: FontWeight.w600))],
        ),
        getScheduleItemWidget('Monday', items.firstWhereOrNull((si) => si.itemOrder == 1)),
        getScheduleItemWidget('Tuesday', items.firstWhereOrNull((si) => si.itemOrder == 2)),
        getScheduleItemWidget('Wednesday', items.firstWhereOrNull((si) => si.itemOrder == 3)),
        getScheduleItemWidget('Thursday', items.firstWhereOrNull((si) => si.itemOrder == 4)),
        getScheduleItemWidget('Friday', items.firstWhereOrNull((si) => si.itemOrder == 5)),
        getScheduleItemWidget('Saturday', items.firstWhereOrNull((si) => si.itemOrder == 6)),
        getScheduleItemWidget('Sunday', items.firstWhereOrNull((si) => si.itemOrder == 7)),
      ]),
      Column(children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('Week 2', style: TextStyle(fontWeight: FontWeight.w600))],
        ),
        getScheduleItemWidget('Monday', items.firstWhereOrNull((si) => si.itemOrder == 8)),
        getScheduleItemWidget('Tuesday', items.firstWhereOrNull((si) => si.itemOrder == 9)),
        getScheduleItemWidget('Wednesday', items.firstWhereOrNull((si) => si.itemOrder == 10)),
        getScheduleItemWidget('Thursday', items.firstWhereOrNull((si) => si.itemOrder == 11)),
        getScheduleItemWidget('Friday', items.firstWhereOrNull((si) => si.itemOrder == 12)),
        getScheduleItemWidget('Saturday', items.firstWhereOrNull((si) => si.itemOrder == 13)),
        getScheduleItemWidget('Sunday', items.firstWhereOrNull((si) => si.itemOrder == 14)),
      ]),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(children: [
          SizedBox(
            height: 370,
            child: PageView.builder(
              controller: biweeklyPageController,
              itemCount: pages.length,
              itemBuilder: (_, index) => pages[index % pages.length],
            ),
          ),
        ]),
        const Padding(padding: EdgeInsets.all(5)),
        SmoothPageIndicator(
          controller: biweeklyPageController,
          count: pages.length,
          effect: const WormEffect(
            activeDotColor: Colors.white,
            dotHeight: 8,
            dotWidth: 8,
          ),
        ),
      ],
    );
  }

  Widget getSplitScheduleWidget(List<ScheduleItem> items) {
    var widgets = <Widget>[];

    for (int i = 1; i <= items.length; i++) {
      widgets.add(getScheduleItemWidget('Day $i', items.firstWhereOrNull((si) => si.itemOrder == i)));
    }

    return Column(children: widgets);
  }

  Widget getScheduleDsiplay(Schedule schedule) {
    Widget? widget;

    if (schedule.items == null || schedule.items!.isEmpty) return getTextDisplayWidget('This sechedule is empty');

    switch (schedule.type) {
      case ScheduleType.weekly:
        widget = getWeeklyScheduleWidget(schedule.items!);
        break;
      case ScheduleType.biweekly:
        widget = getBiWeeklyScheduleWidget(schedule.items!);
        break;
      case ScheduleType.split:
        widget = getSplitScheduleWidget(schedule.items!);
        break;
    }

    return Row(children: [Expanded(child: widget)]);
  }

  void addSchedule() {
    Navigator.pop(context);
    CommonFunctions.showBottomSheet(context, ScheduleForm(reloadParent: reloadState));
  }

  void editSchedule(Schedule schedule) {
    Navigator.pop(context);
    CommonFunctions.showBottomSheet(context, ScheduleForm(reloadParent: reloadState, schedule: schedule));
  }

  void setActiveSchedule(int newActiveScheduleId, int? currentActiveScheduleId) async {
    Navigator.pop(context);
    if (newActiveScheduleId == currentActiveScheduleId) return;

    try {
      await ScheduleModel.setActiveSchedule(newActiveScheduleId);
    } catch (ex) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to set active Schedule')));
    }

    reloadState();
  }

  void showMoreMenu(Schedule activeSchedule) {
    CommonFunctions.showOptionsMenu(context, [
      ButtonDetails(
        icon: Icons.edit_rounded,
        text: 'Edit Schedule',
        style: ButtonDetailsStyle(iconColor: Theme.of(context).colorScheme.primary),
        onTap: () => editSchedule(activeSchedule),
      ),
      CommonUI.getDeleteButtonDetails(
        () => CommonFunctions.showDeleteConfirm(
          context,
          'Schedule',
          () async => await ScheduleModel.deleteSchedule(activeSchedule.id!),
          reloadState,
          popCaller: true,
        ),
        text: 'Delete Schedule',
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: activeSchedule,
      builder: (context, activeScheduleSnapshot) {
        return FutureBuilder(
            future: schedules,
            builder: (context, schedulesSnapshot) {
              return Column(
                children: [
                  CommonUI.getSectionTitleWithActions(
                    context,
                    activeScheduleSnapshot.hasData ? activeScheduleSnapshot.data!.name : 'Schedule',
                    [
                      ButtonDetails(
                        icon: Icons.format_list_bulleted_rounded,
                        onTap: () => CommonFunctions.showOptionsMenu(
                            context,
                            [
                              ButtonDetails(
                                text: 'Add Schedule',
                                icon: Icons.add_rounded,
                                onTap: addSchedule,
                                style: ButtonDetailsStyle.primaryIconAndText(context),
                              ),
                              if (schedulesSnapshot.hasData && schedulesSnapshot.data!.isNotEmpty)
                                ...schedulesSnapshot.data!.map(
                                  (s) => ButtonDetails(
                                    text: s.name,
                                    icon: s.active ? Icons.chevron_right_rounded : null,
                                    onTap: () => setActiveSchedule(s.id!, activeScheduleSnapshot.data?.id),
                                    style: s.active ? ButtonDetailsStyle.primaryIcon(context) : null,
                                  ),
                                ),
                            ],
                            menuName: 'Schedules'),
                      ),
                      if (activeScheduleSnapshot.hasData)
                        ButtonDetails(
                          onTap: () => showMoreMenu(activeScheduleSnapshot.data!),
                          icon: Icons.more_vert_rounded,
                        ),
                    ],
                  ),
                  activeScheduleSnapshot.hasData
                      ? getScheduleDsiplay(activeScheduleSnapshot.data!)
                      : getTextDisplayWidget('No active schedule set'),
                ],
              );
            });
      },
    );
  }
}
