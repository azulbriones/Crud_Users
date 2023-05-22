import 'package:clean_architecture/features/notes/domain/entities/note_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotesModel extends NotesEntity {
  NotesModel({
    final String? noteId,
    final String? note,
    final Timestamp? time,
    final String? uid,
  }) : super(uid: uid, time: time, note: note, noteId: noteId);
  factory NotesModel.fromSnapshot(DocumentSnapshot documentSnapshot) {
    return NotesModel(
      noteId: documentSnapshot.get('noteId'),
      note: documentSnapshot.get('note'),
      uid: documentSnapshot.get('uid'),
      time: documentSnapshot.get('time'),
    );
  }

  Map<String, dynamic> toDocument() {
    return {"uid": uid, "time": time, "note": note, "noteId": noteId};
  }
}
