import 'package:flutter/material.dart';
import 'package:makenote/constants/routes.dart';
import 'package:makenote/services/auth/auth_service.dart';
import 'package:makenote/services/colud/cloud_note.dart';
import 'package:makenote/services/colud/firebase_cloud_storage.dart';
import 'package:makenote/utilities/dialogs/logout_dialog.dart';
import 'package:makenote/views/notes/notes_list_view.dart';
import '../../enums/menu_action.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesServices;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesServices = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Your Notes'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createAndUpdateNoteRout);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        loginRoute,
                        (_) => false,
                      );
                    }
                  }
                  break;
                case MenuAction.login:
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('logout'),
                ),
              ];
            },
            color: Colors.grey,
          )
        ],
      ),
      body: Center(
        child: StreamBuilder(
          stream: _notesServices.allNotes(ownerUserId: userId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.active:
                if (snapshot.hasData) {
                  Iterable<CloudNote> sortNotes(List<CloudNote> notes) {
                    for (int i = 0; i < notes.length; i++) {
                      for (int j = i; j < notes.length; j++) {
                        DateTime dt1 = DateTime.parse(notes[i].modifiedDate);
                        DateTime dt2 = DateTime.parse(notes[j].modifiedDate);
                        if (dt1.compareTo(dt2) < 0) {
                          CloudNote cpy = notes[i];
                          notes[i] = notes[j];
                          notes[j] = cpy;
                        }
                      }
                    }
                    Iterable<CloudNote> sortedNotes = notes;
                    return sortedNotes;
                  }

                  final allNotes = snapshot.data as Iterable<CloudNote>;
                  final allSortedNotes = sortNotes(allNotes.toList());
                  return NotesListView(
                    notes: allSortedNotes,
                    onDeleteNote: (note) async {
                      await _notesServices.deleteNote(
                          documentId: note.documentId);
                    },
                    onTap: (note) {
                      Navigator.of(context).pushNamed(
                        createAndUpdateNoteRout,
                        arguments: note,
                      );
                    },
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              default:
                return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
