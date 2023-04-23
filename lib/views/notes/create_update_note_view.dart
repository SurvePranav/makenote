import 'package:flutter/material.dart';
import 'package:makenote/services/auth/auth_service.dart';
import 'package:makenote/services/colud/firebase_cloud_storage.dart';
import 'package:makenote/utilities/dialogs/empty_note_dialog.dart';
import 'package:makenote/utilities/generics/get_arguments.dart';
import "package:makenote/services/colud/cloud_note.dart";
import "package:makenote/services/colud/cloud_services_exceptions.dart";
import "package:makenote/services/colud/cloud_storage_constants.dart";
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesServices;
  late final TextEditingController _textController;
  late final TextEditingController _titleTextController;
  bool _isFirstTime = true;
  bool _isTextControllerSettedUp = false;
  late final String _initialText;

  @override
  void initState() {
    _notesServices = FirebaseCloudStorage();
    _textController = TextEditingController();
    _titleTextController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    final title = _titleTextController.text.trimLeft();
    await _notesServices.updateNote(
      documentId: note.documentId,
      title: title,
      text: text,
      modifiedDate: DateTime.now().toString(),
    );
  }

  void _setUpTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
    _titleTextController.removeListener(_textControllerListener);
    _titleTextController.addListener(_textControllerListener);
  }

  Future<CloudNote?> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      _titleTextController.text = widgetNote.title;
      _initialText = widgetNote.text;
      return widgetNote;
    } else {
      _initialText = "";
      return null;
    }
  }

  void createNewNote() async {
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newNote = await _notesServices.createNewNote(
        ownerUserId: userId, text: "", title: "", modifiedDate: "");
    _note = newNote;
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (note != null && _textController.text.isEmpty) {
      _notesServices.deleteNote(documentId: note.documentId);
    }
  }

  void _saveNoteIfTextIsNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    final title = _titleTextController.text.trimLeft();
    if (note != null && text == _initialText) {
      return;
    }
    if (note != null && text.isNotEmpty) {
      await _notesServices.updateNote(
        documentId: note.documentId,
        text: text,
        title: title,
        modifiedDate: DateTime.now().toString(),
      );
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextIsNotEmpty();
    _textController.dispose();
    _titleTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: TextField(
          controller: _titleTextController,
          cursorColor: Colors.black,
          decoration: const InputDecoration.collapsed(
            hintText: "Enter Title",
          ),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          onChanged: (value) {
            if (!_isTextControllerSettedUp) {
              _setUpTextControllerListener();
              _isTextControllerSettedUp = true;
            }
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              final text = _textController.text;
              if (_note == null || text == "") {
                cannotShareEmptyNoteDialog(context, "Cannot share empty note");
              } else {
                Share.share(text);
              }
            },
            icon: const Icon(Icons.share),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width / 25,
          )
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Hero(
                tag: _note?.documentId ?? 'newNote',
                flightShuttleBuilder: (flightContext, animation, direction,
                    fromContext, toContext) {
                  return Container(
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
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Start typing your note..',
                      ),
                      style: const TextStyle(fontSize: 20),
                      onChanged: (value) {
                        if (_isFirstTime) {
                          if (_note == null) {
                            createNewNote();
                          }
                          _setUpTextControllerListener();
                          _isFirstTime = false;
                          _isTextControllerSettedUp = true;
                        }
                      },
                      onTapOutside: (event) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                  ),
                ),
              );

            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
