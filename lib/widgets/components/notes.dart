import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/note.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/widgets/common/common_ui.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/models/db_models/note_model.dart';

class Notes extends StatefulWidget {
  final NoteType type;
  final String objectId;
  final bool autofocus;
  final String? notesOverride;

  const Notes({
    super.key,
    required this.type,
    required this.objectId,
    this.autofocus = false,
    this.notesOverride,
  });

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  late Future<Note?> note;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = widget.notesOverride ?? '';
    note = NoteModel.getNoteForObject(widget.type, widget.objectId);
  }

  void reloadState() => setState(() {
        note = NoteModel.getNoteForObject(widget.type, widget.objectId);
      });

  void onSave(Note? note) async {
    try {
      closeKeyboard();

      if (note == null) {
        await NoteModel.insert(Note(
          objectId: widget.objectId,
          type: widget.type,
          note: controller.text,
        ));
      } else {
        note.note = controller.text;
        if (note.note == '') {
          await NoteModel.delete(note.id!);
        } else {
          await NoteModel.update(note);
        }
      }

      reloadState();
    } catch (ex) {
      if (!mounted) return;
      showSnackBar(context, 'Failed to save note');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonUI.getCard(
      context,
      Padding(
        padding: const EdgeInsetsGeometry.symmetric(horizontal: 5),
        child: Row(children: [
          Expanded(
            child: FutureBuilder(
                future: note,
                builder: (context, snapshot) {
                  if (snapshot.hasData && widget.notesOverride == null) {
                    controller.text = snapshot.data!.note;
                  }

                  return CupertinoTextField(
                    controller: controller,
                    keyboardType: TextInputType.multiline,
                    autofocus: widget.autofocus,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: () => onSave(snapshot.data),
                    padding: const EdgeInsetsGeometry.all(10),
                    minLines: 1,
                    maxLines: 3,
                    suffixMode: OverlayVisibilityMode.editing,
                    suffix: GestureDetector(
                      child: Padding(
                        padding: const EdgeInsetsGeometry.all(5),
                        child: Icon(
                          Icons.clear_rounded,
                          size: 16,
                          color: Theme.of(context).colorScheme.shadow,
                        ),
                      ),
                      onTap: () => showDeleteConfirm(
                        context,
                        'note',
                        () {
                          controller.clear();
                          onSave(snapshot.data);
                        },
                        reloadState,
                      ),
                    ),
                    placeholder: 'Add note...',
                    style: TextStyle(color: Theme.of(context).colorScheme.shadow, fontSize: 15),
                    decoration: const BoxDecoration(color: Colors.transparent),
                  );
                }),
          ),
        ]),
      ),
    );
  }
}
