import 'package:flutter/material.dart';
import 'package:makenote/services/colud/cloud_note.dart';
import 'package:makenote/utilities/dialogs/delete_dialog.dart';
import '../../constants/routes.dart';
import 'package:intl/intl.dart';

typedef NoteCallBack = Function(CloudNote note);

class NotesListView extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final NoteCallBack onDeleteNote;
  final NoteCallBack onTap;
  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 350.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 100,
                height: 100,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(createAndUpdateNoteRout);
                  },
                  child: const Icon(Icons.add),
                ),
              ),
            ),
            const Text(
              "Create A Note",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20.0,
              ),
            ),
          ],
        ),
      );
    } else {
      String getDate(String strDateTime) {
        DateTime dateTime = DateTime.parse(strDateTime);
        if (dateTime.day == DateTime.now().day &&
            dateTime.month == DateTime.now().month &&
            dateTime.year == DateTime.now().year) {
          return DateFormat('jm').format(dateTime);
        } else if (dateTime.year == DateTime.now().year) {
          return DateFormat('d MMM').format(dateTime);
        } else {
          return DateFormat('d MMM y').format(dateTime);
        }
      }

      String getTitle(String title, String text) {
        if (title != "") {
          return title;
        } else if (text.trimLeft() != "") {
          return text.trimLeft();
        } else {
          return "Empty Note";
        }
      }

      return ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes.elementAt(index);
          return Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
              left: 10.0,
              right: 10.0,
            ),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              shadowColor: Colors.white,
              color: Colors.black,
              child: ListTile(
                leading: Hero(
                  tag: note.documentId,
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.orange,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Colors.grey,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Text(
                        note.text,
                        style: const TextStyle(
                          fontSize: 7,
                        ),
                      ),
                    ),
                  ),
                ),
                title: Text(
                  getTitle(note.title, note.text),
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(color: Colors.orangeAccent, fontSize: 23),
                ),
                subtitle: Text(
                  getDate(note.modifiedDate),
                  style: const TextStyle(color: Colors.orangeAccent),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  iconSize: 30,
                  color: Colors.orangeAccent,
                  onPressed: () async {
                    final shouldDelete = await showDeleteDialog(context);
                    if (shouldDelete) {
                      onDeleteNote(note);
                    }
                  },
                ),
                onTap: () {
                  onTap(note);
                },
              ),
            ),
          );
        },
      );
    }
  }
}
