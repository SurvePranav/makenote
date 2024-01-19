import 'package:flutter/material.dart';
import 'package:makenote/constants/routes.dart';
import 'package:makenote/services/auth/auth_service.dart';
import 'package:makenote/services/colud/firebase_cloud_storage.dart';
import 'package:makenote/utilities/dialogs/logout_dialog.dart';
import 'package:makenote/views/notes/create_update_note_view.dart';
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
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                  height: 40,
                  width: 40,
                  child: Image.asset('assets/Notes_Icon.jpg')),
            ),
            const SizedBox(
              width: 20,
            ),
            const Text(
              'Take A Note!',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ],
        ),
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
      body: StreamBuilder(
        stream: _notesServices.allNotes(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                return NotesListView(
                  notes: snapshot.data ?? [],
                  onDeleteNote: (note) async {
                    await _notesServices.deleteNote(
                        documentId: note.documentId);
                  },
                  onTap: (note) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CreateUpdateNoteView(
                          widgetNote: note,
                        ),
                      ),
                    );
                  },
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey.shade300,
        onPressed: () {
          Navigator.of(context).pushNamed(createAndUpdateNoteRout);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
