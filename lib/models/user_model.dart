import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String username;
  final String email;
  final String password;
  final String uid;
  final String? profilePic;
  final Timestamp lastSeen;
  final bool isOnline;

  UserModel(
      {required this.username,
      required this.email,
      required this.password,
      required this.uid,
      required this.profilePic,
      required this.isOnline,
      required this.lastSeen});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': username,
      'email': email,
      'password': password,
      'uid': uid,
      'profilePic': profilePic,
      'isOnline': isOnline,
      'lastSeen': lastSeen.toDate(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      username: map['username'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      uid: map['uid'] as String,
      profilePic: map['profilePic'] as String,
      isOnline: map['isOnline'] as bool,
      lastSeen: map['lastSeen'] as Timestamp,
    );
  }
}
