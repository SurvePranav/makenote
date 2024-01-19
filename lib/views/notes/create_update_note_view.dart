import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:makenote/services/auth/auth_service.dart';
import 'package:makenote/services/colud/firebase_cloud_storage.dart';
import 'package:makenote/utilities/dialogs/empty_note_dialog.dart';
import "package:makenote/services/colud/cloud_note.dart";
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  final CloudNote? widgetNote;
  const CreateUpdateNoteView({super.key, this.widgetNote});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesServices;
  late final TextEditingController _textController;
  late final TextEditingController _titleTextController;
  bool isFirstTime = true;

  @override
  void initState() {
    _notesServices = FirebaseCloudStorage();
    _textController = TextEditingController();
    _titleTextController = TextEditingController();
    createOrGeteNote();
    super.initState();
  }

  void _textControllerListener() {
    log('i am text controller listener');
    if (_note == null) {
      log('note was null');
      return;
    }
    final text = _textController.text;
    final title = _titleTextController.text.trimLeft();
    _notesServices.updateNote(
      documentId: _note!.documentId,
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

  void createOrGeteNote() async {
    if (widget.widgetNote != null) {
      // getting existing note
      log('got the existing note');
      _note = widget.widgetNote;
      _textController.text = widget.widgetNote?.text ?? '';
      _titleTextController.text = widget.widgetNote?.title ?? '';
    } else {
      // creating a new note if not pervious and assigning to the _note variable
      log('creating a new note');
      _note = await _notesServices.createNewNote(
          ownerUserId: AuthService.firebase().currentUser!.id);
    }
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (note != null &&
        _textController.text.isEmpty &&
        _titleTextController.text.isEmpty) {
      log('deleting note');
      _notesServices.deleteNote(documentId: note.documentId);
    }
  }

  void _saveNoteIfTextIsNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    final title = _titleTextController.text.trimLeft();
    if (note != null &&
        text == widget.widgetNote?.text &&
        title == widget.widgetNote?.title) {
      log('exiting without saving');
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
    log('building whole screen');
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Hero(
                tag: _note?.documentId ?? 'New Note',
                child: Container(
                  height: 50,
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(left: 10),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      size: 26,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Container(
                        height: 60,
                        width: MediaQuery.of(context).size.width * 0.68,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.center,
                        color: Colors.grey.shade400,
                        child: TextFormField(
                          controller: _titleTextController,
                          cursorColor: Colors.black,
                          decoration: const InputDecoration.collapsed(
                            hintText: "Enter Title",
                          ),
                          style: const TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                          ),
                          onChanged: (value) async {
                            if (isFirstTime) {
                              log('value changed for first time');
                              _setUpTextControllerListener();
                              isFirstTime = false;
                            }
                          },
                          onTapOutside: (event) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                        ),
                      ),
                    ),
                    const Spacer(),
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey.shade400,
                      child: IconButton(
                        icon: const Icon(
                          Icons.share,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          final text = _textController.text;
                          if (_note == null || text == "") {
                            cannotShareEmptyNoteDialog(
                                context, "Cannot share empty note");
                          } else {
                            Share.share(text);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey.shade400,
                ),
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
                    onChanged: (value) async {
                      if (isFirstTime) {
                        log('value changed for first time');
                        _setUpTextControllerListener();
                        isFirstTime = false;
                      }
                    },
                    onTapOutside: (event) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
