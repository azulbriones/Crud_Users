import 'package:clean_architecture/app_const.dart';
import 'package:clean_architecture/features/notes/presentation/cubit/note/note_cubit.dart';
import 'package:clean_architecture/features/notes/presentation/cubit/note/note_state.dart';
import 'package:clean_architecture/features/users/presentation/cubit/auth/auth_cubit.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final String uid;

  const HomePage({Key? key, required this.uid}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<NoteCubit>(context).getNotes(uid: widget.uid);
    clearSharedPrefs();

    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        _handleConnectivityChange();
      }
    });
  }

  Future<void> clearSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('newLaunch');
  }

  Future<void> _handleConnectivityChange() async {
    final noteCubit = BlocProvider.of<NoteCubit>(context);
    final hasConnectivity = await _connectivity.checkConnectivity();

    if (hasConnectivity == ConnectivityResult.none) {
      return;
    }

    await noteCubit.sendPendingOperations();
    noteCubit.getNotes(uid: widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Notes",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () => BlocProvider.of<AuthCubit>(context).loggedOut(),
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, PageConst.addNotePage,
              arguments: widget.uid);
        },
      ),
      body: BlocBuilder<NoteCubit, NoteState>(
        builder: (context, noteState) {
          if (noteState is NoteLoaded) {
            if (noteState.notes.isEmpty) {
              return _noNotesWidget();
            } else {
              return _bodyWidget(noteState);
            }
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _noNotesWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 80,
            child: Image.asset('assets/images/notebook.png'),
          ),
          SizedBox(height: 10),
          Text("No notes here yet"),
        ],
      ),
    );
  }

  Widget _bodyWidget(NoteLoaded noteLoadedState) {
    return Column(
      children: [
        Expanded(
          child: noteLoadedState.notes.isEmpty
              ? _noNotesWidget()
              : GridView.builder(
                  itemCount: noteLoadedState.notes.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                  ),
                  itemBuilder: (_, index) {
                    final note = noteLoadedState.notes[index];

                    return GestureDetector(
                      onTap: () => Navigator.pushNamed(
                          context, PageConst.updateNotePage,
                          arguments: note),
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Delete Note"),
                              content: Text(
                                  "Are you sure you want to delete this note?"),
                              actions: [
                                TextButton(
                                  child: Text("Delete"),
                                  onPressed: () {
                                    BlocProvider.of<NoteCubit>(context)
                                        .deleteNote(note: note);
                                    Navigator.pop(context);
                                  },
                                ),
                                TextButton(
                                  child: Text("No"),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.2),
                              blurRadius: 2,
                              spreadRadius: 2,
                              offset: Offset(0, 1.5),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.all(6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${noteLoadedState.notes[index].note}",
                              maxLines: 6,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              DateFormat("dd MMM yyy hh:mm a")
                                  .format(note.time!.toDate()),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
