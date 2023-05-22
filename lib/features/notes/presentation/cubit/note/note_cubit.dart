import 'dart:convert';
import 'dart:io';
import 'package:clean_architecture/features/notes/domain/entities/note_entity.dart';
import 'package:clean_architecture/features/notes/domain/usecases/add_new_note_usecase.dart';
import 'package:clean_architecture/features/notes/domain/usecases/delete_note_usecase.dart';
import 'package:clean_architecture/features/notes/domain/usecases/get_notes_usecase.dart';
import 'package:clean_architecture/features/notes/domain/usecases/update_note_usecase.dart';
import 'package:clean_architecture/features/notes/presentation/cubit/note/note_state.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoteCubit extends Cubit<NoteState> {
  final GetNotesUseCase getNotesUseCase;
  final AddNewNoteUseCase addNewNoteUseCase;
  final UpdateNoteUseCase updateNoteUseCase;
  final DeleteNoteUseCase deleteNoteUseCase;
  final Connectivity _connectivity;
  final SharedPreferences _sharedPreferences;

  NoteCubit({
    required this.getNotesUseCase,
    required this.addNewNoteUseCase,
    required this.updateNoteUseCase,
    required this.deleteNoteUseCase,
    required Connectivity connectivity,
    required SharedPreferences sharedPreferences,
  })  : _connectivity = connectivity,
        _sharedPreferences = sharedPreferences,
        super(NoteLoading());

  Future<void> getNotes({required String uid}) async {
    emit(NoteLoading());

    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        final localNotes = await getLocalNotes();
        emit(NoteLoaded(notes: localNotes));
        emit(NoteFailure());
        return;
      }

      try {
        getNotesUseCase.call(uid).listen((notes) {
          emit(NoteLoaded(notes: notes));
        });
      } on SocketException catch (_) {
        emit(NoteFailure());
      } catch (_) {
        emit(NoteFailure());
      }
    } catch (_) {
      emit(NoteFailure());
    }
  }

  Future<void> addNote({required NotesEntity note}) async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        await saveNoteLocally(note);
        emit(NoteFailure());
        return;
      }

      await addNewNoteUseCase.call(note);
    } catch (_) {
      emit(NoteFailure());
    }
  }

  Future<void> updateNote({required NotesEntity note}) async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        await saveOperationLocally(Operation.update, note);
        emit(NoteFailure());
        return;
      }

      await updateNoteUseCase.call(note);
    } catch (_) {
      emit(NoteFailure());
    }
  }

  Future<void> deleteNote({required NotesEntity note}) async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        await saveOperationLocally(Operation.delete, note);
        emit(NoteFailure());
        return;
      }

      await deleteNoteUseCase.call(note);
    } catch (_) {
      emit(NoteFailure());
    }
  }

  Future<void> sendPendingOperations() async {
    final localOperations = await getLocalOperations();
    for (final operationData in localOperations) {
      try {
        if (operationData.operation == Operation.delete) {
          await deleteNoteUseCase.call(operationData.note);
        } else if (operationData.operation == Operation.update) {
          await updateNoteUseCase.call(operationData.note);
        }
        localOperations.remove(operationData);
        await saveLocalOperations(localOperations);
      } catch (_) {
        // Failed to send the operation to the remote service, keep it locally for retry
      }
    }
  }

  Future<void> saveNoteLocally(NotesEntity note) async {
    final localNotes = await getLocalNotes();
    localNotes.add(note);
    await saveLocalNotes(localNotes);
  }

  Future<void> saveOperationLocally(
      Operation operation, NotesEntity note) async {
    final localOperations = await getLocalOperations();
    localOperations.add(OperationData(operation: operation, note: note));
    await saveLocalOperations(localOperations);
  }

  Future<List<NotesEntity>> getLocalNotes() async {
    final notesJson = _sharedPreferences.getString('localNotes') ?? '[]';
    final notesList = json.decode(notesJson) as List<dynamic>;
    return notesList.map((json) => NotesEntity.fromJson(json)).toList();
  }

  Future<void> saveLocalNotes(List<NotesEntity> notes) async {
    final notesJson = json.encode(notes);
    await _sharedPreferences.setString('localNotes', notesJson);
  }

  Future<List<OperationData>> getLocalOperations() async {
    final operationsJson =
        _sharedPreferences.getString('localOperations') ?? '[]';
    final operationsList = json.decode(operationsJson) as List<dynamic>;
    return operationsList.map((json) => OperationData.fromJson(json)).toList();
  }

  Future<void> saveLocalOperations(List<OperationData> operations) async {
    final operationsJson = json.encode(operations);
    await _sharedPreferences.setString('localOperations', operationsJson);
  }
}

class OperationData {
  final Operation operation;
  final NotesEntity note;

  OperationData({required this.operation, required this.note});

  Map<String, dynamic> toJson() {
    return {
      'operation': operation.toString(),
      'note': note.toJson(),
    };
  }

  factory OperationData.fromJson(Map<String, dynamic> json) {
    final operation = json['operation'] as String;
    final note = NotesEntity.fromJson(json['note']);
    return OperationData(
      operation:
          operation == 'Operation.delete' ? Operation.delete : Operation.update,
      note: note,
    );
  }
}

enum Operation { delete, update }
