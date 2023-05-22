import 'package:clean_architecture/features/notes/domain/entities/note_entity.dart';
import 'package:clean_architecture/features/notes/presentation/cubit/note/note_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddNewNotePage extends StatefulWidget {
  final String uid;

  const AddNewNotePage({Key? key, required this.uid}) : super(key: key);

  @override
  _AddNewNotePageState createState() => _AddNewNotePageState();
}

class _AddNewNotePageState extends State<AddNewNotePage> {
  final TextEditingController _noteTextController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Connectivity _connectivity = Connectivity();

  @override
  void dispose() {
    _noteTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New note"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Form(
          key: _formKey,
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
                      hintText: "start typing...",
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              InkWell(
                onTap: _submitNewNote,
                child: Container(
                  height: 45,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 156, 34, 255),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Save",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitNewNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // No hay conexión a Internet, guardar nota localmente
      _saveNoteLocally();
      return;
    }

    final noteCubit = context.read<NoteCubit>();

    noteCubit.addNote(
      note: NotesEntity(
        note: _noteTextController.text,
        time: Timestamp.now(),
        uid: widget.uid,
      ),
    );

    Navigator.pop(context);
  }

  void _saveNoteLocally() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? localNotes = prefs.getStringList('localNotes');

    if (localNotes == null) {
      localNotes = [_noteTextController.text];
    } else {
      localNotes.add(_noteTextController.text);
    }

    prefs.setStringList('localNotes', localNotes);

    Navigator.pop(context);
  }
}
