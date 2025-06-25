import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/schedules/schedule.dart';
import 'package:gymvision/classes/db/schedules/schedule_item.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/models/db_models/schedule_model.dart';
import 'package:gymvision/pages/common/common_functions.dart';
import 'package:gymvision/pages/common/common_ui.dart';
import 'package:gymvision/static_data/helpers.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SchedulesWidget extends StatefulWidget {
  const SchedulesWidget({super.key});

  @override
  State<SchedulesWidget> createState() => _SchedulesWidgetState();
}

class _SchedulesWidgetState extends State<SchedulesWidget> {
  late Future<Schedule?> activeSchedule = ScheduleModel.getActiveSchedule();
  late Future<List<Schedule>?> schedules = ScheduleModel.getSchedules();

  final biweeklyPageController = PageController(viewportFraction: 0.8, keepPage: true);

  @override
  void initState() {
    super.initState();
  }

  Widget getNoActiveScheduleWidget() => CommonUI.getCard(
        context,
        const Padding(
          padding: EdgeInsetsGeometry.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('No active schedule set'),
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
                  ? const Row(children: [
                      Icon(
                        Icons.hotel_rounded,
                        size: 20,
                      ),
                      Padding(padding: EdgeInsets.all(5)),
                      Text('Rest Day'),
                    ])
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
        getScheduleItemWidget('Monday', items.firstWhereOrNull((si) => si.order == 1)),
        getScheduleItemWidget('Tuesday', items.firstWhereOrNull((si) => si.order == 2)),
        getScheduleItemWidget('Wednesday', items.firstWhereOrNull((si) => si.order == 3)),
        getScheduleItemWidget('Thursday', items.firstWhereOrNull((si) => si.order == 4)),
        getScheduleItemWidget('Friday', items.firstWhereOrNull((si) => si.order == 5)),
        getScheduleItemWidget('Saturday', items.firstWhereOrNull((si) => si.order == 6)),
        getScheduleItemWidget('Sunday', items.firstWhereOrNull((si) => si.order == 7)),
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
        getScheduleItemWidget('Monday', items.firstWhereOrNull((si) => si.order == 1)),
        getScheduleItemWidget('Tuesday', items.firstWhereOrNull((si) => si.order == 2)),
        getScheduleItemWidget('Wednesday', items.firstWhereOrNull((si) => si.order == 3)),
        getScheduleItemWidget('Thursday', items.firstWhereOrNull((si) => si.order == 4)),
        getScheduleItemWidget('Friday', items.firstWhereOrNull((si) => si.order == 5)),
        getScheduleItemWidget('Saturday', items.firstWhereOrNull((si) => si.order == 6)),
        getScheduleItemWidget('Sunday', items.firstWhereOrNull((si) => si.order == 7)),
      ]),
      Column(children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('Week 2', style: TextStyle(fontWeight: FontWeight.w600))],
        ),
        getScheduleItemWidget('Monday', items.firstWhereOrNull((si) => si.order == 8)),
        getScheduleItemWidget('Tuesday', items.firstWhereOrNull((si) => si.order == 9)),
        getScheduleItemWidget('Wednesday', items.firstWhereOrNull((si) => si.order == 10)),
        getScheduleItemWidget('Thursday', items.firstWhereOrNull((si) => si.order == 11)),
        getScheduleItemWidget('Friday', items.firstWhereOrNull((si) => si.order == 12)),
        getScheduleItemWidget('Saturday', items.firstWhereOrNull((si) => si.order == 13)),
        getScheduleItemWidget('Sunday', items.firstWhereOrNull((si) => si.order == 14)),
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
      widgets.add(getScheduleItemWidget('Day $i', items.firstWhereOrNull((si) => si.order == i)));
    }

    return Column(children: widgets);
  }

  Widget getScheduleDsiplay(Schedule schedule) {
    Widget? widget;

    if (schedule.items == null || schedule.items!.isEmpty) {
      return Text(
        'This sechedule is not finished.',
        style: TextStyle(color: Theme.of(context).colorScheme.shadow),
      );
    }

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

  void addSchedule() {}

  void setActiveSchedule(int? newActiveScheduleId, int? activeScheduleId) {
    if (newActiveScheduleId == activeScheduleId) return;

    return;
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
                  CommonUI.getSectionTitleWithAction(
                    context,
                    activeScheduleSnapshot.hasData ? activeScheduleSnapshot.data!.name : 'Schedule',
                    ButtonDetails(
                      icon: Icons.format_list_bulleted_rounded,
                      onTap: () => CommonFunctions.showOptionsMenu(
                          context,
                          [
                            ButtonDetails(text: 'Add Schedule', icon: Icons.add_rounded, onTap: addSchedule),
                            if (schedulesSnapshot.hasData && schedulesSnapshot.data!.isNotEmpty)
                              ...schedulesSnapshot.data!.map(
                                (s) => ButtonDetails(
                                    text: s.name,
                                    icon: s.active ? Icons.chevron_right_rounded : null,
                                    onTap: () => setActiveSchedule(s.id, activeScheduleSnapshot.data?.id),
                                    style: ButtonDetailsStyle(
                                      iconColor: s.active ? Theme.of(context).colorScheme.primary : null,
                                      textColor: s.active ? Theme.of(context).colorScheme.primary : null,
                                    )),
                              ),
                          ],
                          menuName: 'Schedules'),
                    ),
                  ),
                  activeScheduleSnapshot.hasData
                      ? getScheduleDsiplay(activeScheduleSnapshot.data!)
                      : getNoActiveScheduleWidget(),
                ],
              );
            });
      },
    );
  }
}
