import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gymvision/helpers/datetime_helper.dart';

class TimeElapsed extends StatefulWidget {
  final DateTime since;
  final DateTime? end;
  final Color? color;
  final String? labelForNegativeDuration;

  const TimeElapsed({
    super.key,
    required this.since,
    this.end,
    this.color,
    this.labelForNegativeDuration,
  });

  @override
  State<TimeElapsed> createState() => _TimeElapsedState();
}

class _TimeElapsedState extends State<TimeElapsed> {
  late Duration timeSince;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timeSince = DateTimeHelper.timeBetween(widget.since, widget.end ?? DateTime.now());
    if (widget.end == null) {
      timer = Timer.periodic(
        const Duration(seconds: 1),
        (Timer t) {
          setState(() {
            timeSince = DateTimeHelper.timeBetween(widget.since, widget.end ?? DateTime.now());
          });
        },
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(Icons.hourglass_empty_rounded, size: 15, color: widget.color),
      const Padding(padding: EdgeInsetsGeometry.all(2.5)),
      Text(
        '${!timeSince.isNegative || widget.labelForNegativeDuration == null ? '' : '${widget.labelForNegativeDuration} '}${DateTimeHelper.getDurationString(timeSince, useNegativeSymbol: widget.labelForNegativeDuration == null)}',
        style: TextStyle(color: widget.color),
      ),
    ]);
  }
}
