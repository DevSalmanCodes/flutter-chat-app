import 'package:chat_app/constants/app_constants.dart';
import 'package:chat_app/repositories/failure.dart';
import 'package:chat_app/type_defs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/general_providers.dart';

final authRepositoryProvider =
    Provider((ref) => AuthRepository(ref.watch(firebaseAuthProvider)));

abstract class IAuthRepository {
  FutureEither<User> signUp(String email, String password);
  FutureEither<User> login(String email, String password, BuildContext context);
  FutureEitherVoid signOut();
}

class AuthRepository implements IAuthRepository {
  final FirebaseAuth _firebaseAuth;
  AuthRepository(
    this._firebaseAuth,
  );
  @override
  FutureEither<User> signUp(String email, String password) async {
    try {
      final res = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return right(res.user!);
    } on FirebaseAuthException catch (e, stackTrace) {
      return left(Failure(e.message ?? errorText, stackTrace.toString()));
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace.toString()));
    }
  }

  @override
  FutureEither<User> login(
      String email, String password, BuildContext context) async {
    try {
      final res = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      return right(res.user!);
    } on FirebaseAuthException catch (e, stackTrace) {
      return left(Failure(e.message ?? errorText, stackTrace.toString()));
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace.toString()));
    }
  }

  @override
  FutureEitherVoid signOut() async {
    try {
      await _firebaseAuth.signOut();
      return right(null);
    } on FirebaseAuthException catch (e, stackTrace) {
      return left(Failure(e.message ?? errorText, stackTrace.toString()));
    }
  }
}
