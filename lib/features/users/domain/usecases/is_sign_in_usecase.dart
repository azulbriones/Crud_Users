import 'package:clean_architecture/features/users/domain/repositories/users_firebase_repository.dart';

class IsSignInUseCase {
  final UsersFirebaseRepository repository;

  IsSignInUseCase({required this.repository});

  Future<bool> call() async {
    return repository.isSignIn();
  }
}
