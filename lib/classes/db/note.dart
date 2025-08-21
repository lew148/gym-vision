import 'package:gymvision/classes/db/_database_object.dart';
import 'package:gymvision/enums.dart';

class Note extends DatabaseObject {
  String objectId;
  NoteType type;
  String note;

  Note({
    super.id,
    super.updatedAt,
    super.createdAt,
    required this.objectId,
    required this.type,
    required this.note,
  });

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'updatedAt': DateTime.now().toString(),
        'createdAt': createdAt.toString(),
        'objectId': objectId,
        'type': type.toString(),
        'note': note,
      };
}
