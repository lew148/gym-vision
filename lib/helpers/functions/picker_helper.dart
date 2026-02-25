import 'package:flutter/cupertino.dart';
import 'package:gymvision/helpers/functions/bottom_sheet_helper.dart';
import 'package:gymvision/widgets/components/stateless/calendar_view.dart';
import 'package:gymvision/widgets/forms/pickers/date_time_picker.dart';
import 'package:gymvision/widgets/forms/pickers/duration_picker.dart';

class PickerHelper {
  static Future showCalendarView(
    BuildContext context, {
    required Map<DateTime, List<CalendarViewEvent>> events,
    void Function(DateTime? selectedDay)? onDateSelected,
    DateTime? selectedDate,
  }) async =>
      await BottomSheetHelper.showCloseableBottomSheet(
        context,
        CalendarView(
          events: events,
          onDateSelected: onDateSelected,
          selectedDate: selectedDate,
        ),
      );

  static Future showDateTimePicker(
    BuildContext context,
    CupertinoDatePickerMode mode,
    Function(DateTime) onChange, {
    DateTime? initialDateTime,
  }) async =>
      await BottomSheetHelper.showCloseableBottomSheet(
        context,
        DateTimePicker(onChange: onChange, mode: mode, initialValue: initialDateTime),
      );

  static Future showDurationPicker(
    BuildContext context,
    CupertinoTimerPickerMode mode, {
    Function(Duration)? onChange,
    Function(Duration)? onSubmit,
    Duration? initialDuration,
    bool isTimer = false,
    List<Duration>? sampleDurations,
  }) async =>
      await BottomSheetHelper.showCloseableBottomSheet(
        context,
        DurationPicker(
          onChange: onChange,
          onSubmit: onSubmit,
          mode: mode,
          initialValue: initialDuration,
          isTimer: isTimer,
          sampleDurations: sampleDurations,
        ),
      );
}
