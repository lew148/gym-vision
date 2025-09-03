import 'package:gymvision/classes/db/_dbo.dart';
import 'package:gymvision/enums.dart';

class Note extends DBO {
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
}
