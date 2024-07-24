

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider=Provider((ref) => FirebaseAuth.instance);

final firebaseFirestoreProvider=Provider((ref) => FirebaseFirestore.instance);

final firebaseStorageProvider=Provider((ref) => FirebaseStorage.instance);
final obsecureProvider=StateProvider<bool>((ref) => true);
