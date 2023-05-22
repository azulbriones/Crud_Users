import 'package:clean_architecture/features/notes/domain/entities/note_entity.dart';
import 'package:equatable/equatable.dart';

abstract class NoteState extends Equatable {
  const NoteState();
}

class NoteInitial extends NoteState {
  @override
  List<Object> get props => [];
}

class NoteLoading extends NoteState {
  @override
  List<Object> get props => [];
}

class NoteFailure extends NoteState {
  @override
  List<Object> get props => [];
}

class NoteLoaded extends NoteState {
  final List<NotesEntity> notes;

  NoteLoaded({required this.notes});
  @override
  List<Object> get props => [notes];
}
