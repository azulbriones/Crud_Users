import 'package:clean_architecture/features/notes/domain/entities/note_entity.dart';
import 'package:clean_architecture/features/notes/domain/repositories/notes_firebase_repository.dart';

class GetNotesUseCase {
  final NotesFirebaseRepository repository;

  GetNotesUseCase({required this.repository});

  Stream<List<NotesEntity>> call(String uid) {
    return repository.getNotes(uid);
  }
}
