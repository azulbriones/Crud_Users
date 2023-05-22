import 'package:clean_architecture/features/notes/domain/entities/note_entity.dart';
import 'package:clean_architecture/features/notes/domain/repositories/notes_firebase_repository.dart';

class AddNewNoteUseCase {
  final NotesFirebaseRepository repository;

  AddNewNoteUseCase({required this.repository});

  Future<void> call(NotesEntity note) async {
    return repository.addNewNote(note);
  }
}
