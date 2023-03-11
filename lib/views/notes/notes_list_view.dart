import 'package:flutter/material.dart';
import 'package:makenote/services/crud/notes_service.dart';
import 'package:makenote/utilities/dialogs/delete_dialog.dart';

import '../../constants/routes.dart';

typedef DeleteNoteCallBack = Function(DatabaseNote note);

class NotesListView extends StatelessWidget {
  final List<DatabaseNote> notes;
  final DeleteNoteCallBack onDeleteNote;
  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
  });

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return Center(
        child: Padding(
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
                      Navigator.of(context).pushNamed(newNotesRoute);
                    },
                    child: const Icon(Icons.add),
                  ),
                ),
              ),
              const Text(
                "Create A Note",
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 20.0,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
              left: 10.0,
              right: 10.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: ListTile(
                title: Text(
                  note.text,
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  color: Colors.white,
                  onPressed: () async {
                    final sholudDelete = await showDeleteDialog(context);
                    if (sholudDelete) {
                      onDeleteNote(note);
                    }
                  },
                ),
              ),
            ),
          );
        },
      );
    }
  }
}
