import 'package:clean_architecture/features/users/domain/entities/user_entity.dart';

abstract class UsersFirebaseRepository {
  Future<bool> isSignIn();
  Future<void> signIn(UsersEntity user);
  Future<void> signUp(UsersEntity user);
  Future<void> signOut();
  Future<String> getCurrentUId();
  Future<void> getCreateCurrentUser(UsersEntity user);
}
