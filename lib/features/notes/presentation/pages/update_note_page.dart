import 'package:clean_architecture/features/notes/domain/entities/note_entity.dart';
import 'package:clean_architecture/features/notes/presentation/cubit/note/note_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class UpdateNotePage extends StatefulWidget {
  final NotesEntity noteEntity;

  const UpdateNotePage({Key? key, required this.noteEntity}) : super(key: key);

  @override
  _UpdateNotePageState createState() => _UpdateNotePageState();
}

class _UpdateNotePageState extends State<UpdateNotePage> {
  late TextEditingController _noteTextController;
  final Connectivity _connectivity = Connectivity();
  String _tempNoteText = '';

  @override
  void initState() {
    super.initState();
    _noteTextController = TextEditingController(text: widget.noteEntity.note);
    _noteTextController.addListener(() {
      _tempNoteText = _noteTextController.text;
    });
    _tempNoteText = _noteTextController.text;

    _checkConnectivity();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _noteTextController.text = _tempNoteText;
  }

  @override
  void dispose() {
    _noteTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Note"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${DateFormat("dd MMM hh:mm a").format(DateTime.now())} | ${_noteTextController.text.length} Characters",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withOpacity(.5),
              ),
            ),
            Expanded(
              child: Scrollbar(
                child: TextFormField(
                  controller: _noteTextController,
                  maxLines: null,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Start your note",
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: _submitUpdateNote,
              child: Container(
                height: 45,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.deepOrange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Update",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitUpdateNote() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // No hay conexión a Internet, mostrar contenido local temporalmente
      _showLocalContent();
      return;
    }

    final noteCubit = context.read<NoteCubit>();

    noteCubit.updateNote(
      note: NotesEntity(
        note: _noteTextController.text,
        noteId: widget.noteEntity.noteId,
        time: Timestamp.now(),
        uid: widget.noteEntity.uid,
      ),
    );

    // Mostrar un indicador de carga o mensaje de éxito aquí

    try {
      // Simular un tiempo de espera para mostrar el indicador de carga
      await Future.delayed(Duration(seconds: 1));

      // Actualizar la nota en el servidor

      // Mostrar mensaje de éxito y navegar de vuelta
      Navigator.pop(context);
    } catch (error) {
      // Mostrar mensaje de error en caso de fallo de actualización en el servidor
    }
  }

  void _showLocalContent() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("No hay conexión"),
          content: Text("Mostrando contenido local"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // No hay conexión a Internet, manejar el caso sin conexión aquí
    }
  }
}
