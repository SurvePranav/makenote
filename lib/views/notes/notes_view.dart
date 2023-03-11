import 'package:flutter/material.dart';
import 'package:makenote/constants/routes.dart';
import 'package:makenote/services/auth/auth_service.dart';
import 'package:makenote/services/crud/notes_service.dart';
import '../../enums/menu_action.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesServices _notesServices;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesServices = NotesServices();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Notes'),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(newNotesRoute);
              },
              icon: const Icon(Icons.add),
            ),
            PopupMenuButton<MenuAction>(onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (_) => false,
                    );
                  }
                  break;
                case MenuAction.login:
                  break;
              }
            }, itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('logout'),
                ),
              ];
            })
          ],
        ),
        body: FutureBuilder(
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
                              return ListView.builder(
                                itemCount: allNotes.length,
                                itemBuilder: (context, index) {
                                  // if (snapshot.data?.isEmpty ?? false) {
                                  //   return Center(
                                  //     child: Padding(
                                  //       padding:
                                  //           const EdgeInsets.only(top: 350.0),
                                  //       child: Column(
                                  //         children: [
                                  //           Padding(
                                  //             padding:
                                  //                 const EdgeInsets.all(8.0),
                                  //             child: SizedBox(
                                  //               width: 100,
                                  //               height: 100,
                                  //               child: ElevatedButton(
                                  //                 style:
                                  //                     ElevatedButton.styleFrom(
                                  //                   shape: const CircleBorder(),
                                  //                 ),
                                  //                 onPressed: () {
                                  //                   Navigator.of(context)
                                  //                       .pushNamed(
                                  //                           newNotesRoute);
                                  //                 },
                                  //                 child: const Icon(Icons.add),
                                  //               ),
                                  //             ),
                                  //           ),
                                  //           const Text(
                                  //             "Create Your First Note",
                                  //             style: TextStyle(
                                  //               color: Colors.deepPurple,
                                  //               fontSize: 20.0,
                                  //             ),
                                  //           ),
                                  //         ],
                                  //       ),
                                  //     ),
                                  //   );
                                  // } else {
                                  final note = allNotes[index];
                                  print(allNotes);
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      top: 10.0,
                                      left: 10.0,
                                      right: 10.0,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple,
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          note.text,
                                          maxLines: 1,
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
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
            }));
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
              await AuthService.firebase().logOut();
            },
            child: const Text('Yes'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
