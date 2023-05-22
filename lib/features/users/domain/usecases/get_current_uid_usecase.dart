import 'package:clean_architecture/features/users/domain/repositories/users_firebase_repository.dart';

class GetCurrentUidUseCase {
  final UsersFirebaseRepository repository;

  GetCurrentUidUseCase({required this.repository});

  Future<String> call() async {
    return repository.getCurrentUId();
  }
}
