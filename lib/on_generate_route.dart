import 'package:clean_architecture/app_const.dart';
import 'package:clean_architecture/features/notes/domain/entities/note_entity.dart';
import 'package:clean_architecture/features/notes/presentation/pages/add_new_note_page.dart';
import 'package:clean_architecture/features/notes/presentation/pages/update_note_page.dart';
import 'package:clean_architecture/features/users/presentation/pages/sign_in_page.dart';
import 'package:clean_architecture/features/users/presentation/pages/sign_up.dart';
import 'package:flutter/material.dart';

class OnGenerateRoute {
  static Route<dynamic> route(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case PageConst.signInPage:
        {
          return materialBuilder(widget: SignInPage());
        }
      case PageConst.signUpPage:
        {
          return materialBuilder(widget: SignUpPage());
        }
      case PageConst.addNotePage:
        {
          if (args is String) {
            return materialBuilder(
                widget: AddNewNotePage(
              uid: args,
            ));
          } else {
            return materialBuilder(
              widget: ErrorPage(),
            );
          }
        }
      case PageConst.updateNotePage:
        {
          if (args is NotesEntity) {
            return materialBuilder(
                widget: UpdateNotePage(
              noteEntity: args,
            ));
          } else {
            return materialBuilder(
              widget: ErrorPage(),
            );
          }
        }
      default:
        return materialBuilder(widget: ErrorPage());
    }
  }
}

class ErrorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("error"),
      ),
      body: Center(
        child: Text("error"),
      ),
    );
  }
}

MaterialPageRoute materialBuilder({required Widget widget}) {
  return MaterialPageRoute(builder: (_) => widget);
}
