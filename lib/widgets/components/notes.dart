import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymvision/classes/db/note.dart';
import 'package:gymvision/helpers/common_functions.dart';
import 'package:gymvision/enums.dart';
import 'package:gymvision/models/db_models/note_model.dart';
import 'package:gymvision/widgets/components/stateless/custom_card.dart';
import 'package:gymvision/widgets/components/stateless/shimmer_load.dart';

class Notes extends StatefulWidget {
  final NoteType type;
  final String objectId;
  final bool autofocus;

  const Notes({
    super.key,
    required this.type,
    required this.objectId,
    this.autofocus = false,
  });

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  bool firstLoad = true;
  late Future<Note?> noteFuture;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    noteFuture = loadNote();
  }

  void reload() => setState(() {
        noteFuture = loadNote();
      });

  Future<Note?> loadNote() async {
    final note = await NoteModel.getNoteForObject(widget.type, widget.objectId);
    controller.text = note?.note ?? '';
    return note;
  }

  Future onSave(Note? note, {bool delete = false}) async {
    try {
      closeKeyboard();

      if (delete || controller.text.isEmpty) {
        if (note != null) {
          await NoteModel.delete(note.id!);
          controller.clear();
          reload();
        }

        return;
      }

      if (note == null) {
        await NoteModel.insert(Note(objectId: widget.objectId, type: widget.type, note: controller.text));
      } else {
        note.note = controller.text;
        await NoteModel.update(note);
      }

      reload();
    } catch (ex) {
      if (!mounted) return;
      showSnackBar(context, 'Failed to save note');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: noteFuture,
      builder: (context, snapshot) {
        return ShimmerLoad(
          height: 28,
          loading: snapshot.connectionState == ConnectionState.waiting && firstLoad,
          child: CustomCard(
            child: Padding(
              padding: const EdgeInsetsGeometry.symmetric(horizontal: 5),
              child: Row(children: [
                Expanded(
                  child: CupertinoTextField(
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
                        child: Icon(Icons.clear_rounded, size: 16, color: Theme.of(context).colorScheme.shadow),
                      ),
                      onTap: () => showDeleteConfirm(
                        context,
                        'note',
                        () {
                          controller.clear();
                          onSave(snapshot.data);
                        },
                      ).then((x) => reload()),
                    ),
                    placeholder: 'Add note...',
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 15),
                    decoration: const BoxDecoration(color: Colors.transparent),
                  ),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}
