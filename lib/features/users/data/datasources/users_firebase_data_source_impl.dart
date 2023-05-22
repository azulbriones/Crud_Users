import 'package:clean_architecture/features/users/data/datasources/users_firebase_data_source.dart';
import 'package:clean_architecture/features/users/data/models/users_model.dart';
import 'package:clean_architecture/features/users/domain/entities/user_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UsersFirebaseDataSourceImpl implements UsersFirebaseDataSource {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  UsersFirebaseDataSourceImpl({required this.auth, required this.firestore});

  @override
  Future<void> getCreateCurrentUser(UsersEntity user) async {
    final userCollectionRef = firestore.collection("users");
    final uid = await getCurrentUId();
    userCollectionRef.doc(uid).get().then((value) {
      final newUser = UsersModel(
        uid: uid,
        status: user.status,
        email: user.email,
        name: user.name,
      ).toDocument();
      if (!value.exists) {
        userCollectionRef.doc(uid).set(newUser);
      }
      return;
    });
  }

  @override
  Future<String> getCurrentUId() async => auth.currentUser!.uid;

  @override
  Future<bool> isSignIn() async => auth.currentUser?.uid != null;

  @override
  Future<void> signIn(UsersEntity user) async => auth
      .signInWithEmailAndPassword(email: user.email!, password: user.password!);

  @override
  Future<void> signOut() async => auth.signOut();

  @override
  Future<void> signUp(UsersEntity user) async =>
      auth.createUserWithEmailAndPassword(
          email: user.email!, password: user.password!);
}
