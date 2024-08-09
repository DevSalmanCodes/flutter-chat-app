import 'package:chat_app/constants/app_constants.dart';
import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/providers/general_providers.dart';
import 'package:chat_app/repositories/failure.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../type_defs.dart';

abstract class IChatRepository {
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getAllMessages(
      String chatId);
  FutureEitherVoid sendTextMessage(
      String chaId, MessageModel messageModel, String docId);
  FutureEitherVoid sendImageMessage(
      String chatId, MessageModel messageModel, String docId);
  FutureEitherVoid sendVoiceMessage(
    String chatId,
    String meessageId,
    String voicePath,
    MessageModel messageModel,
    BuildContext context,
  );
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getAllChats(
      String uid);

  FutureEitherVoid markAsReadMessages(String chaId);
  FutureVoid addReactionToMessage(
      String messageId, String chatId, String reaction);
}

final chatRepositoryProvider = Provider((ref) => ChatRepository(
      ref.watch(firebaseFirestoreProvider),
      ref.watch(firebaseAuthProvider),
    ));

class ChatRepository implements IChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  ChatRepository(
    this._firestore,
    this._auth,
  );
  @override
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getAllMessages(
      String chatId) {
    final chatRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .snapshots();
    return chatRef.map((data) => data.docs);
  }

  @override
  FutureEitherVoid sendTextMessage(
      String chatId, MessageModel messageModel, String docId) async {
    try {
      await _sendMessage(chatId, docId, messageModel);

      _updateLastMessage(chatId, messageModel.content);
      return right(null);
    } on FirebaseException catch (e, st) {
      return left(Failure(e.message, st.toString()));
    }
  }

  @override
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getAllChats(
      String uid) {
    final res = _firestore
        .collection('chats')
        .where('participantIds', arrayContains: uid)
        .snapshots();
    return res.map((chats) => chats.docs);
  }

  @override
  FutureEitherVoid markAsReadMessages(String chatId) async {
    try {
      final messagesDocs = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      // Use a batch write to update all documents
      final batch = _firestore.batch();

      for (var doc in messagesDocs.docs) {
        if (doc.data()['senderId'] != _auth.currentUser!.uid &&
            doc.data()['status'] != 'seen') {
          batch.update(
              _firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .doc(doc.id),
              {'status': 'seen'});
        }
      }
      await batch.commit();
    } on FirebaseException catch (e, st) {
      return left(Failure(e.message, st.toString()));
    } catch (e, st) {
      return left(Failure(e.toString(), st.toString()));
    }
    return left(Failure(errorText, ''));
  }

  @override
  FutureEitherVoid sendImageMessage(
      String chatId, MessageModel messageModel, String docId) async {
    try {
      await _sendMessage(chatId, docId, messageModel);

      _updateLastMessage(chatId, 'Photo');
      return right(null);
    } on FirebaseException catch (e, st) {
      return left(Failure(e.message, st.toString()));
    } catch (e, st) {
      return left(Failure(e.toString(), st.toString()));
    }
  }

  FutureEitherVoid _updateLastMessage(String chatId, String lastMessage) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .update({'lastMessage': lastMessage});
      return right(null);
    } on FirebaseException catch (e, st) {
      return left(Failure(e.message, st.toString()));
    } catch (e, st) {
      return left(Failure(e.toString(), st.toString()));
    }
  }

  @override
  FutureVoid addReactionToMessage(
      String messageId, String chatId, String reaction) async {
    final docRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);
    final doc = await docRef.get();

    final docData = doc.data();
    if (docData == null || !docData.containsKey('reactions')) return;

    final reactions = (docData['reactions'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        key,
        List<String>.from(value as List<dynamic>),
      ),
    );
    final currentUserUid = _auth.currentUser!.uid;
    bool isUpdated = false;
    if (reactions.containsKey(reaction)) {
      final userList = reactions[reaction]!;
      if (!userList.contains(currentUserUid)) {
        userList.add(currentUserUid);
        isUpdated = true;
      } else {
        userList.remove(currentUserUid);
        if (userList.isEmpty) {
          reactions.remove(reaction);
        }
        isUpdated = true;
      }
    } else {
      // Loop through all reactions if the current user uid found in any list remove it first and then add new reaction
      reactions.forEach((key, value) {
        if (value.contains(currentUserUid)) {
          value.remove(currentUserUid);
        }
      });
      reactions.removeWhere((key, value) => value.isEmpty);
      reactions[reaction] = [currentUserUid];
      isUpdated = true;
    }
    if (isUpdated) {
      docRef.update({'reactions': reactions});
    }
  }

  @override
  FutureEitherVoid sendVoiceMessage(
    String chatId,
    String meessageId,
    String voicePath,
    MessageModel messageModel,
    BuildContext context,
  ) async {
    try {
      await _sendMessage(chatId, meessageId, messageModel);
      _updateLastMessage(chatId, 'Voice Message');
      return right(null);
    } on FirebaseException catch (e, st) {
      return left(Failure(e.message, st.toString()));
    }
  }

  FutureVoid _sendMessage(
      String chatId, String docId, MessageModel messageModel) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(docId)
        .set(messageModel.toMap());
  }
}
