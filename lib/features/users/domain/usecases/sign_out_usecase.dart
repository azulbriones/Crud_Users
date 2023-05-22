import 'package:clean_architecture/features/users/domain/repositories/users_firebase_repository.dart';

class SignOutUseCase {
  final UsersFirebaseRepository repository;

  SignOutUseCase({required this.repository});

  Future<void> call() async {
    return repository.signOut();
  }
}
