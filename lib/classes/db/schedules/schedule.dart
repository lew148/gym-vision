import 'package:gymvision/classes/db/database_object.dart';
import 'package:gymvision/classes/db/schedules/schedule_item.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/globals.dart';

class Schedule extends DatabaseObject {
  String name;
  ScheduleType type;
  bool active;

  List<ScheduleItem>? items;

  Schedule({
    super.id,
    super.updatedAt,
    super.createdAt,
    required this.name,
    required this.type,
    required this.active,
    this.items,
  });

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'updatedAt': DateTime.now().toString(),
        'createdAt': createdAt.toString(),
        'name': name,
        'type': enumToString(type),
        'active': active ? 1 : 0,
      };
}
