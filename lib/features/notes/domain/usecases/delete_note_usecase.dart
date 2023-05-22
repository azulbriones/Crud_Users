import 'package:clean_architecture/features/notes/domain/entities/note_entity.dart';
import 'package:clean_architecture/features/notes/domain/repositories/notes_firebase_repository.dart';

class DeleteNoteUseCase {
  final NotesFirebaseRepository repository;

  DeleteNoteUseCase({required this.repository});

  Future<void> call(NotesEntity note) async {
    return repository.deleteNote(note);
  }
}
