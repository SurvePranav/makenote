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
    // Convert the Iterable to a List for sorting
    List<CloudNote> sortedNotes = notes.toList();

    // Sort the list
    sortedNotes.sort((a, b) => b.modifiedDate.compareTo(a.modifiedDate));

    if (sortedNotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "You Don't Have Any Notes",
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey.shade900,
              ),
            ),
            const SizedBox(
              height: 100,
            ),
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

      return GridView.builder(
        itemCount: sortedNotes.length,
        itemBuilder: (context, index) {
          final note = sortedNotes.elementAt(index);
          return Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
              left: 10.0,
              right: 10.0,
            ),
            child: GestureDetector(
              onTap: () {
                onTap(note);
              },
              child: Hero(
                tag: note.documentId,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                  color: Colors.grey.shade400,
                  // child: ListTile(
                  //   leading: Container(
                  //     width: 45,
                  //     height: 45,
                  //     decoration: BoxDecoration(
                  //       border: Border.all(
                  //         width: 1,
                  //         color: Colors.grey.shade900,
                  //       ),
                  //       borderRadius: const BorderRadius.all(Radius.circular(10)),
                  //       color: Colors.grey,
                  //     ),
                  //     child: Padding(
                  //       padding: const EdgeInsets.all(2),
                  //       child: Text(
                  //         note.text,
                  //         style: const TextStyle(
                  //           fontSize: 7,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  //   title: Text(
                  //     getTitle(note.title, note.text),
                  //     maxLines: 1,
                  //     softWrap: true,
                  //     overflow: TextOverflow.ellipsis,
                  //     style: const TextStyle(fontSize: 23),
                  //   ),
                  //   subtitle: Text(
                  //     getDate(note.modifiedDate),
                  //   ),
                  //   trailing: IconButton(
                  //     icon: const Icon(Icons.delete),
                  //     iconSize: 30,
                  //     onPressed: () async {
                  //       final shouldDelete = await showDeleteDialog(context);
                  //       if (shouldDelete) {
                  //         onDeleteNote(note);
                  //       }
                  //     },
                  //   ),
                  //   onTap: () {
                  //     onTap(note);
                  //   },
                  // ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          // margin: const EdgeInsets.all(10),
                          height: 180,
                          padding: const EdgeInsets.only(
                            bottom: 20,
                            left: 10,
                            right: 10,
                            top: 10,
                          ),
                          child: Text(
                            note.text,
                            style: const TextStyle(fontSize: 21),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                gradient: LinearGradient(
                                  begin: Alignment
                                      .bottomCenter, // Start of the gradient
                                  end: Alignment
                                      .topCenter, // End of the gradient
                                  colors: <Color>[
                                    Colors.transparent.withOpacity(0.7),
                                    Colors.transparent.withOpacity(0.3),
                                    Colors.grey.shade400.withOpacity(0.0),
                                  ],
                                ),
                              ),
                              alignment: Alignment.bottomLeft,
                              padding: const EdgeInsets.only(
                                left: 6,
                                right: 6,
                                bottom: 15,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getDate(note.modifiedDate),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  Text(
                                    getTitle(note.title, note.text),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey.shade400,
                          child: IconButton(
                            icon: const Icon(Icons.delete),
                            iconSize: 40,
                            onPressed: () async {
                              final shouldDelete =
                                  await showDeleteDialog(context);
                              if (shouldDelete) {
                                onDeleteNote(note);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns
            crossAxisSpacing: 4.0, // Horizontal space between items
            mainAxisSpacing: 4.0, // Vertical space between items
            childAspectRatio: (30 / 40) // child aspect ratio
            ),
      );
    }
  }
}
