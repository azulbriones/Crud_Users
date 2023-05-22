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

  @override
  void initState() {
    super.initState();
    _noteTextController = TextEditingController(text: widget.noteEntity.note);
    _noteTextController.addListener(() {
      setState(() {});
    });
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
      // No hay conexión a Internet, mostrar mensaje de error o tomar alguna acción
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

    Future.delayed(Duration(seconds: 1), () {
      Navigator.pop(context);
    });
  }
}
