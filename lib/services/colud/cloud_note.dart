import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:makenote/services/colud/cloud_storage_constants.dart';

class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String text;
  final String? title;
  final String modifiedDate;

  CloudNote({
    required this.ownerUserId,
    required this.documentId,
    required this.text,
    required this.title,
    required this.modifiedDate,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        text = snapshot.data()[textFieldName] as String,
        title = snapshot.data()[titleFieldName] as String,
        modifiedDate = snapshot.data()[modifiedDateFieldName] as String;
}
