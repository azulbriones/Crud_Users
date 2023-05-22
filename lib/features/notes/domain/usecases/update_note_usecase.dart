import 'package:clean_architecture/features/notes/domain/entities/note_entity.dart';
import 'package:clean_architecture/features/notes/domain/repositories/notes_firebase_repository.dart';

class UpdateNoteUseCase {
  final NotesFirebaseRepository repository;

  UpdateNoteUseCase({required this.repository});

  Future<void> call(NotesEntity note) async {
    return repository.updateNote(note);
  }
}
