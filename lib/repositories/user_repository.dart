import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/repositories/failure.dart';
import 'package:chat_app/type_defs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../providers/general_providers.dart';

abstract class IUserRepository {
  FutureEitherVoid storeUserData(UserModel userModel);
  FutureVoid changeUserStatus(bool status);
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getAllUsers();
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserById(String id);
}

final userRepositoryProvider = Provider((ref) => UserRepository(
      ref.watch(firebaseFirestoreProvider),
      ref.watch(firebaseAuthProvider),
    ));

class UserRepository implements IUserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  UserRepository(this._firestore, this._auth);
  @override
  FutureEitherVoid storeUserData(UserModel userModel) async {
    try {
      _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .set(userModel.toMap());
      return right(null);
    } on FirebaseException catch (e, stackTrace) {
      return left(Failure(e.message.toString(), stackTrace.toString()));
    }
  }

  @override
  FutureVoid changeUserStatus(bool status) async {
    final user = _auth.currentUser?.uid;
    await _firestore.collection('users').doc(user).update({
      'isOnline': status,
    });
  }

  @override
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getAllUsers() {
    final res = _firestore.collection('users').snapshots();
    return res.map((users) => users.docs);
  }

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserById(String id) async {
    final res = await _firestore.collection('users').doc(id).get();
    return res;
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getSearchUsers(
      String query) {
    return _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: '$query\uf8ff')
        .snapshots()
        .map((data) => data.docs);
  }
}
