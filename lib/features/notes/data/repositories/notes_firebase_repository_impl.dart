import 'package:clean_architecture/features/notes/data/datasources/notes_firebase_data_source.dart';
import 'package:clean_architecture/features/notes/domain/entities/note_entity.dart';
import 'package:clean_architecture/features/notes/domain/repositories/notes_firebase_repository.dart';

class NotesFirebaseRepositoryImpl extends NotesFirebaseRepository {
  final NotesFirebaseDataSource notesDataSource;

  NotesFirebaseRepositoryImpl({required this.notesDataSource});
  @override
  Future<void> addNewNote(NotesEntity note) async =>
      notesDataSource.addNewNote(note);

  @override
  Future<void> deleteNote(NotesEntity note) async =>
      notesDataSource.deleteNote(note);

  @override
  Stream<List<NotesEntity>> getNotes(String uid) =>
      notesDataSource.getNotes(uid);

  @override
  Future<void> updateNote(NotesEntity note) async =>
      notesDataSource.updateNote(note);
}
