import 'package:clean_architecture/features/notes/domain/entities/note_entity.dart';

abstract class NotesRemoteFirebaseRepository {
  Future<void> addNewNote(NotesEntity note);
  Future<void> updateNote(NotesEntity note);
  Future<void> deleteNote(NotesEntity note);
  Stream<List<NotesEntity>> getNotes(String uid);
}
