import 'package:clean_architecture/features/notes/presentation/cubit/note/note_cubit.dart';
import 'package:clean_architecture/features/notes/presentation/pages/home_page.dart';
import 'package:clean_architecture/features/users/presentation/cubit/auth/auth_cubit.dart';
import 'package:clean_architecture/features/users/presentation/cubit/auth/auth_state.dart';
import 'package:clean_architecture/features/users/presentation/cubit/user/user_cubit.dart';
import 'package:clean_architecture/features/users/presentation/pages/sign_in_page.dart';
import 'package:clean_architecture/on_generate_route.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
            create: (_) => di.sl<AuthCubit>()..appStarted()),
        BlocProvider<UserCubit>(create: (_) => di.sl<UserCubit>()),
        BlocProvider<NoteCubit>(create: (_) => di.sl<NoteCubit>()),
      ],
      child: MaterialApp(
        title: 'My Notes',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        initialRoute: '/',
        onGenerateRoute: OnGenerateRoute.route,
        routes: {
          "/": (context) {
            return BlocBuilder<AuthCubit, AuthState>(
                builder: (context, authState) {
              if (authState is Authenticated) {
                return HomePage(
                  uid: authState.uid,
                );
              }
              if (authState is UnAuthenticated) {
                return SignInPage();
              }

              return CircularProgressIndicator();
            });
          }
        },
      ),
    );
  }
}
