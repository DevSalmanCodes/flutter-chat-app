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
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getAllChats(
      String uid);

  FutureEitherVoid markAsReadMessages(String chaId);
  FutureVoid addReactionToMessage(String messageId, String chatId,
      String reaction, Map<String, List<String>> reactions);
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
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(docId)
          .set(messageModel.toMap());

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
        if (doc.data()['senderId'] != _auth.currentUser!.uid) {
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
    return left(Failure('Something went wrong', ''));
  }

  @override
  FutureEitherVoid sendImageMessage(
      String chatId, MessageModel messageModel, String docId) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(docId)
          .set(messageModel.toMap());

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
  FutureVoid addReactionToMessage(String messageId, String chatId,
      String reaction, Map<String, List<String>> reactions) async {
    // final docRef = _firestore
    //     .collection('chats')
    //     .doc(chatId)
    //     .collection('messages')
    //     .doc(messageId);
    // final doc = await docRef.get();
    // final docData = doc.data();
    // final reactions = (docData!['reactions'] as Map<String, dynamic>).map(
    //   (key, value) => MapEntry(
    //     key,
    //     List<String>.from(value as List<dynamic>),
    //   ),
    // );
    final currentUserUid = _auth.currentUser!.uid;
    // Check if the reaction is already exists
    if (reactions.containsKey(reaction)) {
      if (!reactions[reaction]!.contains(currentUserUid)) {
        reactions[reaction]!.add(currentUserUid);
      } else {
        reactions[reaction]!.remove(currentUserUid);
        // After removing the user id check if the current reaction list is empty if empty remove the reaction also
        if (reactions[reaction]!.isEmpty) {
          reactions.remove(reaction);
        }
      }
    } else {
      // Loop through all reactions if the current user uid found in any list remove it first and then add new reaction
      for (var i = 0; i < reactions.keys.length; i++) {
        final currentValue = reactions.values.elementAt(i);

        if (currentValue.contains(currentUserUid)) {
          currentValue.remove(currentUserUid);
          if (currentValue.isEmpty) {
            final currentKey = reactions.keys.elementAt(i);
            reactions.remove(currentKey);
          }
        }
      }

      reactions[reaction] = [currentUserUid];
    }
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'reactions': reactions});
    reactions.clear();
  }

  FutureEitherVoid sendVoiceMessage(
    String chatId,
    String voicePath,
    MessageModel messageModel,
    BuildContext context,
  ) async {
    try {
      _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(messageModel.toMap());
      _updateLastMessage(chatId, 'Voice Message');
      return right(null);
    } on FirebaseException catch (e, st) {
      return left(Failure(e.message, st.toString()));
    }
  }
}
