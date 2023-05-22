import 'package:clean_architecture/features/users/domain/entities/user_entity.dart';
import 'package:clean_architecture/features/users/domain/repositories/users_firebase_repository.dart';

class GetCreateCurrentUserUsecase {
  final UsersFirebaseRepository repository;

  GetCreateCurrentUserUsecase({required this.repository});

  Future<void> call(UsersEntity user) async {
    return repository.getCreateCurrentUser(user);
  }
}
