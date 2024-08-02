import 'dart:io';

import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/providers/general_providers.dart';
import 'package:chat_app/repositories/auth_repository.dart';
import 'package:chat_app/repositories/user_repository.dart';
import 'package:chat_app/utils/methods.dart';
import 'package:chat_app/utils/routes/route_names.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/methods/storage_methods.dart';

final authViewModelProvider = StateNotifierProvider<AuthViewModel, bool>(
    (ref) => AuthViewModel(ref.watch(authRepositoryProvider),
        ref.watch(userRepositoryProvider), ref.watch(firebaseAuthProvider)));

final authStateChangesProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

class AuthViewModel extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final FirebaseAuth _auth;

  AuthViewModel(this._authRepository, this._userRepository, this._auth)
      : super(false);

  void signUp(String username, String email, String password, File? file,
      BuildContext context) async {
    state = true;
    final res = await _authRepository.signUp(email, password);

    res.fold((l) => showSnackBar(context, l.message ?? 'Something went wrong'),
        (r) async {
      String? profilePicUrl;
      if (context.mounted && file != null) {
        profilePicUrl = await StorageMethods.uploadFileToFirebase(
            file, 'profilePics', null, context);
      }
      UserModel userModel = UserModel(
          username: username,
          email: email,
          password: password,
          uid: _auth.currentUser!.uid,
          profilePic: profilePicUrl ?? '',
          isOnline: false,
          lastSeen: DateTime.now().millisecondsSinceEpoch.toString());
      final res2 = await _userRepository.storeUserData(
        userModel,
      );
      state = false;
      res2.fold(
          (l) => showSnackBar(context, l.message ?? 'Something went wrong'),
          (r) {
        if (context.mounted) {
          showSnackBar(context, "Please login to continue");
          Navigator.pushNamed(context, RouteNames.login);
        }
      });
    });
  }

  void login(String email, String password, BuildContext context) async {
    state = true;
    final res = await _authRepository.login(email, password, context);
    state = false;
    res.fold((l) => showSnackBar(context, l.message ?? 'Something went wrong'),
        (r) {
      Navigator.pushNamed(context, RouteNames.home);
      showSnackBar(context, "Logged in successfully");
    });
  }

  void signOut(BuildContext context) async {
    state = true;
    await _auth.signOut().then((_) {
      Navigator.pushReplacementNamed(context, RouteNames.login);
      state = false;
    });
  }
}
