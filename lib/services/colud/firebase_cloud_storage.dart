import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makenote/services/colud/cloud_note.dart';
import 'package:makenote/services/colud/cloud_services_exceptions.dart';
import 'package:makenote/services/colud/cloud_storage_constants.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNote({
    required String documentId,
    required String text,
    required String title,
    required String modifiedDate,
  }) async {
    try {
      await notes.doc(documentId).update(
        {
          textFieldName: text,
          titleFieldName: title,
          modifiedDateFieldName: modifiedDate,
        },
      );
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
    return notes.snapshots().map((event) => event.docs
        .map((doc) => CloudNote.fromSnapshot(doc))
        .where((note) => note.ownerUserId == ownerUserId));
  }

  Future<Iterable<CloudNote>> getNotes({required String ownerUserId}) async {
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
            (value) => value.docs.map(
              (doc) {
                return CloudNote(
                    documentId: doc.id,
                    ownerUserId: doc.data()[ownerUserId] as String,
                    text: doc.data()[textFieldName] as String,
                    title: doc.data()[titleFieldName] as String,
                    modifiedDate: doc.data()[modifiedDateFieldName] as String);
              },
            ),
          );
    } catch (e) {
      throw CouldNotGetAllNoteException();
    }
  }

  void createNewNote({required String ownerUserId}) async {
    await notes.add({
      ownerUserIdFieldName: ownerUserId,
      textFieldName: "",
    });
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
