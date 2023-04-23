import 'package:flutter/material.dart';
import 'package:makenote/services/auth/auth_service.dart';
import 'package:makenote/services/crud/notes_service.dart';
import 'package:makenote/utilities/generics/get_arguments.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  DatabaseNote? _note;
  late final NotesServices _notesServices;
  late final TextEditingController _textController;
  late final TextEditingController _titleTextController;
  bool _isFirstTime = true;
  bool _isTextControllerSettedUp = false;
  late final String _initialText;

  @override
  void initState() {
    _notesServices = NotesServices();
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
      note: note,
      title: title,
      text: text,
      date: DateTime.now().toString(),
    );
  }

  void _setUpTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
    _titleTextController.removeListener(_textControllerListener);
    _titleTextController.addListener(_textControllerListener);
  }

  Future<DatabaseNote?> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<DatabaseNote>();

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
    final email = currentUser.email;
    final owner = await _notesServices.getUser(email: email);
    final newNote = await _notesServices.createNote(owner: owner);
    _note = newNote;
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (note != null && _textController.text.isEmpty) {
      _notesServices.deleteNote(id: note.id);
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
        note: note,
        text: text,
        title: title,
        date: DateTime.now().toString(),
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
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Hero(
                      tag: _note?.id ?? 'newNote',
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
