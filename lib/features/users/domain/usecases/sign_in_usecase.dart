import 'package:clean_architecture/features/users/domain/entities/user_entity.dart';
import 'package:clean_architecture/features/users/domain/repositories/users_firebase_repository.dart';

class SignInUseCase {
  final UsersFirebaseRepository repository;

  SignInUseCase({required this.repository});

  Future<void> call(UsersEntity user) async {
    return repository.signIn(user);
  }
}
