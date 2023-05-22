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

enum Operation { delete, update }

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
        setNotes(localNotes);
        return;
      }

      try {
        getNotesUseCase.call(uid).listen((notes) {
          setNotes(notes);
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
      await syncChanges();
    } catch (_) {
      emit(NoteFailure());
    }
  }

  Future<void> updateNote({required NotesEntity note}) async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        await saveNoteLocally(note);
        emit(NoteFailure());
        return;
      }

      await updateNoteUseCase.call(note);
      await syncChanges();
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
      await syncChanges();
    } catch (_) {
      emit(NoteFailure());
    }
  }

  Future<List<NotesEntity>> getLocalNotes() async {
    final notesJson = _sharedPreferences.getString('local_notes');
    if (notesJson != null) {
      final notesData = jsonDecode(notesJson) as List<dynamic>;
      final localNotes =
          notesData.map((data) => NotesEntity.fromJson(data)).toList();
      return localNotes;
    }
    return [];
  }

  Future<void> saveNoteLocally(NotesEntity note) async {
    final localNotes = await getLocalNotes();
    localNotes.add(note);

    final notesData = localNotes.map((note) => note.toJson()).toList();
    final notesJson = jsonEncode(notesData);
    await _sharedPreferences.setString('local_notes', notesJson);
  }

  Future<void> saveOperationLocally(
      Operation operation, NotesEntity note) async {
    final operationData = OperationData(operation: operation, note: note);
    final operationsJson = _sharedPreferences.getString('local_operations');
    List<OperationData> operations = [];
    if (operationsJson != null) {
      final operationsData = jsonDecode(operationsJson) as List<dynamic>;
      operations =
          operationsData.map((data) => OperationData.fromJson(data)).toList();
    }
    operations.add(operationData);

    final operationsData =
        operations.map((operation) => operation.toJson()).toList();
    final operationsJsonAux = jsonEncode(operationsData);
    await _sharedPreferences.setString('local_operations', operationsJsonAux);
  }

  Future<void> syncChanges() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      final operationsJson = _sharedPreferences.getString('local_operations');
      if (operationsJson != null) {
        final operationsData = jsonDecode(operationsJson) as List<dynamic>;
        final operations =
            operationsData.map((data) => OperationData.fromJson(data)).toList();

        for (final operation in operations) {
          try {
            if (operation.operation == Operation.delete) {
              await deleteNoteUseCase.call(operation.note);
            } else if (operation.operation == Operation.update) {
              await updateNoteUseCase.call(operation.note);
            }
          } catch (_) {
            // Error al sincronizar la operación, se mantiene en almacenamiento local
            continue;
          }
        }

        // Se eliminan las operaciones sincronizadas del almacenamiento local
        await _sharedPreferences.remove('local_operations');
      }

      // Obtener las notas locales pendientes y enviarlas al servidor
      final localNotes = await getLocalNotes();
      for (final note in localNotes) {
        try {
          await addNewNoteUseCase.call(note);
        } catch (_) {
          // Error al sincronizar la nota, se mantiene en almacenamiento local
          continue;
        }
      }

      // Se eliminan las notas locales pendientes del almacenamiento local
      await _sharedPreferences.remove('local_notes');
    }
  }

  Future<void> setNotes(List<NotesEntity> notes) async {
    emit(NoteLoaded(notes: notes));
  }
}
