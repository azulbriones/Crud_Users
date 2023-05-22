import 'dart:io';

import 'package:clean_architecture/features/users/domain/entities/user_entity.dart';
import 'package:clean_architecture/features/users/domain/usecases/get_current_user_usecase.dart';
import 'package:clean_architecture/features/users/domain/usecases/sign_in_usecase.dart';
import 'package:clean_architecture/features/users/domain/usecases/sign_up_usecase.dart';
import 'package:clean_architecture/features/users/presentation/cubit/user/user_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserCubit extends Cubit<UserState> {
  final SignInUseCase signInUseCase;
  final SignUPUseCase signUPUseCase;
  final GetCreateCurrentUserUsecase getCreateCurrentUserUseCase;
  UserCubit(
      {required this.signUPUseCase,
      required this.signInUseCase,
      required this.getCreateCurrentUserUseCase})
      : super(UserInitial());

  Future<void> submitSignIn({required UsersEntity user}) async {
    emit(UserLoading());
    try {
      await signInUseCase.call(user);
      emit(UserSuccess());
    } on SocketException catch (_) {
      emit(UserFailure());
    } catch (_) {
      emit(UserFailure());
    }
  }

  Future<void> submitSignUp({required UsersEntity user}) async {
    emit(UserLoading());
    try {
      await signUPUseCase.call(user);
      await getCreateCurrentUserUseCase.call(user);
      emit(UserSuccess());
    } on SocketException catch (_) {
      emit(UserFailure());
    } catch (_) {
      emit(UserFailure());
    }
  }
}
