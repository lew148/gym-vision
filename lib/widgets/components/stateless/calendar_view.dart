import 'package:flutter/material.dart';
import 'package:gymvision/helpers/datetime_helper.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:table_calendar/table_calendar.dart';

enum CalendarViewEvent {
  workout,
}

class CalendarView extends StatelessWidget {
  final Map<DateTime, List<CalendarViewEvent>> events;
  final void Function(DateTime? selectedDay)? onDateSelected;

  const CalendarView({
    super.key,
    required this.events,
    this.onDateSelected,
  });

  List<CalendarViewEvent> getEvent(DateTime dt) => events[DateTimeHelper.roundToDay(dt)] ?? [];

  @override
  Widget build(BuildContext context) {
    Icon geticonForEvent(CalendarViewEvent e) {
      IconData icon = Icons.circle_rounded;
      Color color = Theme.of(context).colorScheme.primary;

      switch (e) {
        case CalendarViewEvent.workout:
          icon = Icons.fitness_center_rounded;
          break;
      }

      return Icon(icon, color: color, size: 10);
    }

    void onDateSelect(DateTime? dt) {
      Navigator.pop(context);
      if (onDateSelected != null) onDateSelected!(dt);
    }

    return Column(children: [
      TableCalendar<CalendarViewEvent>(
        firstDay: DateTime.utc(2000, 1, 1),
        lastDay: DateTime.utc(2050, 12, 31),
        focusedDay: DateTime.now(),
        eventLoader: getEvent,
        headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
        calendarStyle: CalendarStyle(
          markersMaxCount: 3,
          todayDecoration: BoxDecoration(color: Theme.of(context).colorScheme.shadow, shape: BoxShape.circle),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) => events.isEmpty
              ? null
              : Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Wrap(alignment: WrapAlignment.center, children: events.map((e) => geticonForEvent(e)).toList())
                  ],
                ),
        ),
        onDaySelected: (selectedDay, focusedDay) => onDateSelect(selectedDay),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [Button.clear(onTap: () => onDateSelect(null))]),
    ]);
  }
}
