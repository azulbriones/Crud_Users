import 'package:clean_architecture/features/notes/data/datasources/notes_firebase_data_source.dart';
import 'package:clean_architecture/features/notes/data/datasources/notes_firebase_data_source_impl.dart';
import 'package:clean_architecture/features/notes/data/repositories/notes_firebase_repository_impl.dart';
import 'package:clean_architecture/features/notes/domain/repositories/notes_firebase_repository.dart';
import 'package:clean_architecture/features/notes/domain/usecases/add_new_note_usecase.dart';
import 'package:clean_architecture/features/notes/domain/usecases/delete_note_usecase.dart';
import 'package:clean_architecture/features/notes/domain/usecases/get_notes_usecase.dart';
import 'package:clean_architecture/features/notes/domain/usecases/update_note_usecase.dart';
import 'package:clean_architecture/features/notes/presentation/cubit/note/note_cubit.dart';
import 'package:clean_architecture/features/users/data/datasources/users_firebase_data_source.dart';
import 'package:clean_architecture/features/users/data/datasources/users_firebase_data_source_impl.dart';
import 'package:clean_architecture/features/users/data/repositories/users_firebase_repository_impl.dart';
import 'package:clean_architecture/features/users/domain/repositories/users_firebase_repository.dart';
import 'package:clean_architecture/features/users/domain/usecases/get_current_uid_usecase.dart';
import 'package:clean_architecture/features/users/domain/usecases/get_current_user_usecase.dart';
import 'package:clean_architecture/features/users/domain/usecases/is_sign_in_usecase.dart';
import 'package:clean_architecture/features/users/domain/usecases/sign_in_usecase.dart';
import 'package:clean_architecture/features/users/domain/usecases/sign_out_usecase.dart';
import 'package:clean_architecture/features/users/domain/usecases/sign_up_usecase.dart';
import 'package:clean_architecture/features/users/presentation/cubit/auth/auth_cubit.dart';
import 'package:clean_architecture/features/users/presentation/cubit/user/user_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

GetIt sl = GetIt.instance;

Future<void> init() async {
  //Cubit/Bloc
  sl.registerFactory<AuthCubit>(() => AuthCubit(
      isSignInUseCase: sl.call(),
      signOutUseCase: sl.call(),
      getCurrentUidUseCase: sl.call()));
  sl.registerFactory<UserCubit>(() => UserCubit(
        getCreateCurrentUserUseCase: sl.call(),
        signInUseCase: sl.call(),
        signUPUseCase: sl.call(),
      ));
  sl.registerFactory<NoteCubit>(() => NoteCubit(
        updateNoteUseCase: sl.call(),
        getNotesUseCase: sl.call(),
        deleteNoteUseCase: sl.call(),
        addNewNoteUseCase: sl.call(),
        sharedPreferences: sl.call(),
        connectivity: sl.call(),
      ));

  //useCase
  sl.registerLazySingleton<AddNewNoteUseCase>(
      () => AddNewNoteUseCase(repository: sl.call()));
  sl.registerLazySingleton<DeleteNoteUseCase>(
      () => DeleteNoteUseCase(repository: sl.call()));
  sl.registerLazySingleton<GetCreateCurrentUserUsecase>(
      () => GetCreateCurrentUserUsecase(repository: sl.call()));
  sl.registerLazySingleton<GetCurrentUidUseCase>(
      () => GetCurrentUidUseCase(repository: sl.call()));
  sl.registerLazySingleton<GetNotesUseCase>(
      () => GetNotesUseCase(repository: sl.call()));
  sl.registerLazySingleton<IsSignInUseCase>(
      () => IsSignInUseCase(repository: sl.call()));
  sl.registerLazySingleton<SignInUseCase>(
      () => SignInUseCase(repository: sl.call()));
  sl.registerLazySingleton<SignOutUseCase>(
      () => SignOutUseCase(repository: sl.call()));
  sl.registerLazySingleton<SignUPUseCase>(
      () => SignUPUseCase(repository: sl.call()));
  sl.registerLazySingleton<UpdateNoteUseCase>(
      () => UpdateNoteUseCase(repository: sl.call()));

  //repository
  sl.registerLazySingleton<NotesFirebaseRepository>(
      () => NotesFirebaseRepositoryImpl(notesDataSource: sl.call()));
  sl.registerLazySingleton<UsersFirebaseRepository>(
      () => UsersFirebaseRepositoryImpl(userFirebaseDataSource: sl.call()));

  //data source
  sl.registerLazySingleton<NotesFirebaseDataSource>(
      () => NotesFirebaseDataSourceImpl(auth: sl.call(), firestore: sl.call()));
  sl.registerLazySingleton<UsersFirebaseDataSource>(
      () => UsersFirebaseDataSourceImpl(auth: sl.call(), firestore: sl.call()));

  //External
  final auth = FirebaseAuth.instance;
  final fireStore = FirebaseFirestore.instance;
  final sharedPreferences = await SharedPreferences.getInstance();
  final connectivity = Connectivity();

  sl.registerLazySingleton(() => auth);
  sl.registerLazySingleton(() => fireStore);

  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerLazySingleton(() => connectivity);
}
