import 'package:flutter/material.dart';
import 'package:makenote/constants/routes.dart';
import 'package:makenote/services/auth/auth_service.dart';
import 'package:makenote/services/crud/notes_service.dart';
import 'package:makenote/utilities/dialogs/logout_dialog.dart';
import 'package:makenote/views/notes/notes_list_view.dart';
import '../../enums/menu_action.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesServices _notesServices;
  String get userEmail => AuthService.firebase().currentUser!.email;

  @override
  void initState() {
    _notesServices = NotesServices();
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
          child: FutureBuilder(
              future: _notesServices.getOrCreateUser(email: userEmail),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    return StreamBuilder(
                        stream: _notesServices.allNotes,
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                            case ConnectionState.active:
                              if (snapshot.hasData) {
                                final allNotes =
                                    snapshot.data as List<DatabaseNote>;
                                return NotesListView(
                                  notes: allNotes,
                                  onDeleteNote: (note) async {
                                    await _notesServices.deleteNote(
                                        id: note.id);
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
                        });
                  default:
                    return const CircularProgressIndicator();
                }
              }),
        ));
  }
}
