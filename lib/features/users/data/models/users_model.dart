import 'package:clean_architecture/features/users/domain/entities/user_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersModel extends UsersEntity {
  UsersModel({
    final String? name,
    final String? email,
    final String? uid,
    final String? status,
    final String? password,
  }) : super(
            uid: uid,
            name: name,
            email: email,
            password: password,
            status: status);

  factory UsersModel.fromSnapshot(DocumentSnapshot documentSnapshot) {
    return UsersModel(
      status: documentSnapshot.get('status'),
      name: documentSnapshot.get('name'),
      uid: documentSnapshot.get('uid'),
      email: documentSnapshot.get('email'),
    );
  }

  Map<String, dynamic> toDocument() {
    return {"status": status, "uid": uid, "email": email, "name": name};
  }
}
