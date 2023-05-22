import 'package:clean_architecture/features/notes/data/datasources/notes_firebase_data_source.dart';
import 'package:clean_architecture/features/notes/data/models/notes_model.dart';
import 'package:clean_architecture/features/notes/domain/entities/note_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotesFirebaseDataSourceImpl implements NotesFirebaseDataSource {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  NotesFirebaseDataSourceImpl({required this.auth, required this.firestore});

  @override
  Future<void> addNewNote(NotesEntity noteEntity) async {
    final noteCollectionRef =
        firestore.collection("users").doc(noteEntity.uid).collection("notes");

    final noteId = noteCollectionRef.doc().id;

    noteCollectionRef.doc(noteId).get().then((note) {
      final newNote = NotesModel(
        uid: noteEntity.uid,
        noteId: noteId,
        note: noteEntity.note,
        time: noteEntity.time,
      ).toDocument();

      if (!note.exists) {
        noteCollectionRef.doc(noteId).set(newNote);
      }
      return;
    });
  }

  @override
  Future<void> deleteNote(NotesEntity noteEntity) async {
    final noteCollectionRef =
        firestore.collection("users").doc(noteEntity.uid).collection("notes");

    noteCollectionRef.doc(noteEntity.noteId).get().then((note) {
      if (note.exists) {
        noteCollectionRef.doc(noteEntity.noteId).delete();
      }
      return;
    });
  }

  @override
  Stream<List<NotesEntity>> getNotes(String uid) {
    final noteCollectionRef =
        firestore.collection("users").doc(uid).collection("notes");

    return noteCollectionRef.snapshots().map((querySnap) {
      return querySnap.docs
          .map((docSnap) => NotesModel.fromSnapshot(docSnap))
          .toList();
    });
  }

  @override
  Future<void> updateNote(NotesEntity note) async {
    Map<String, dynamic> noteMap = Map();
    final noteCollectionRef =
        firestore.collection("users").doc(note.uid).collection("notes");

    if (note.note != null) noteMap['note'] = note.note;
    if (note.time != null) noteMap['time'] = note.time;

    noteCollectionRef.doc(note.noteId).update(noteMap);
  }
}
