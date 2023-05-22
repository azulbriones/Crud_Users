import 'package:clean_architecture/features/users/data/datasources/users_firebase_data_source.dart';
import 'package:clean_architecture/features/users/domain/entities/user_entity.dart';
import 'package:clean_architecture/features/users/domain/repositories/users_firebase_repository.dart';

class UsersFirebaseRepositoryImpl extends UsersFirebaseRepository {
  final UsersFirebaseDataSource userFirebaseDataSource;

  UsersFirebaseRepositoryImpl({required this.userFirebaseDataSource});
  @override
  Future<void> getCreateCurrentUser(UsersEntity user) async =>
      userFirebaseDataSource.getCreateCurrentUser(user);

  @override
  Future<String> getCurrentUId() async =>
      userFirebaseDataSource.getCurrentUId();

  @override
  Future<bool> isSignIn() async => userFirebaseDataSource.isSignIn();

  @override
  Future<void> signIn(UsersEntity user) async =>
      userFirebaseDataSource.signIn(user);

  @override
  Future<void> signOut() async => userFirebaseDataSource.signOut();

  @override
  Future<void> signUp(UsersEntity user) async =>
      userFirebaseDataSource.signUp(user);
}
