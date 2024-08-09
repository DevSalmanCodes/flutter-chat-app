import 'dart:io';

import 'package:chat_app/constants/app_constants.dart';
import 'package:chat_app/models/chat_model.dart';
import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/providers/general_providers.dart';
import 'package:chat_app/repositories/chat_repository.dart';
import 'package:chat_app/repositories/methods/storage_methods.dart';
import 'package:chat_app/type_defs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import '../utils/methods.dart';

final chatViewModelProvider = StateNotifierProvider<ChatViewModel, bool>(
    (ref) => ChatViewModel(
        ref.watch(firebaseFirestoreProvider),
        ref.watch(chatRepositoryProvider),
        ref.watch(firebaseAuthProvider),
        AudioRecorder()));

final getAllMessagesProvider = StreamProvider.family((ref, String chatId) =>
    ref.watch(chatViewModelProvider.notifier).getAllMessages(chatId));

final getAllChatsProvider = StreamProvider.family((ref, String uid) =>
    ref.watch(chatViewModelProvider.notifier).getAllChats(uid));

class ChatViewModel extends StateNotifier<bool> {
  final FirebaseFirestore _firestore;
  final ChatRepository _chatRepository;
  final FirebaseAuth _auth;
  final AudioRecorder _recorder;

  ChatViewModel(
      this._firestore, this._chatRepository, this._auth, this._recorder)
      : super(false);

  Future<String> getOrCreateChat(
      String userUid, String currentUserUid, BuildContext context) async {
    final chatId = _generateChatId(userUid, currentUserUid);
    final chatRef = await _firestore.collection('chats').doc(chatId).get();

    if (!chatRef.exists) {
      ChatModel chat = ChatModel(
          id: chatId,
          participantIds: [userUid, currentUserUid],
          timestamp: Timestamp.now(),
          lastMessage: '');
      await _firestore.collection('chats').doc(chatId).set(chat.toMap());
    }
    return chatId;
  }

  String _generateChatId(String uid1, String uid2) {
    final uids = [uid1, uid2];
    uids.sort();
    final chatId = uids.join('-');
    return chatId;
  }

  Stream<List<MessageModel>> getAllMessages(String chatId) {
    final messageDocs = _chatRepository.getAllMessages(chatId);
    return messageDocs.map((data) =>
        data.map((message) => MessageModel.fromMap(message.data())).toList());
  }

  void sendTextMessage(
      String chatId, String content, BuildContext context) async {
    final messageId = const Uuid().v4();
    final messageModel = _sendMessage(messageId, '', 'text', content);

    final res =
        await _chatRepository.sendTextMessage(chatId, messageModel, messageId);
    res.fold((l) => showSnackBar(context, l.message ?? errorText), (r) => null);
  }

  Stream<List<ChatModel>> getAllChats(String uid) {
    return _chatRepository.getAllChats(uid).map(
        (data) => data.map((chat) => ChatModel.fromMap(chat.data())).toList());
  }

  FutureVoid markAsReadMessages(String chatId) async {
    await _chatRepository.markAsReadMessages(chatId);
  }

  void sendImageMessage(String chatId, File file, BuildContext context) async {
    final messageId = const Uuid().v4();
    final url = await StorageMethods.uploadFileToFirebase(
      file,
      'chatPics',
      null,
      context,
    );
    final messageModel = _sendMessage(messageId, url ?? '', 'image', '');
    final res =
        await _chatRepository.sendImageMessage(chatId, messageModel, messageId);
    res.fold((l) => showSnackBar(context, l.message ?? errorText), (r) => null);
  }

  void addReactionToMessage(
    String messageId,
    String chatId,
    String reaction,
  ) async {
    _chatRepository.addReactionToMessage(messageId, chatId, reaction);
  }

  Future<void> sendVoiceMessage(String chatId, BuildContext context) async {
    final uid = const Uuid().v4();
    final voicePath = await _stopRecording();

    if (voicePath != null) {
      final url = await StorageMethods.uploadFileToFirebase(
          null, '', File(voicePath), context);
      final messageModel = _sendMessage(uid, url ?? '', 'voice', '');
      await _chatRepository.sendVoiceMessage(
          chatId, uid, voicePath, messageModel, context);
    }
  }

  Future<void> startRecording(BuildContext context) async {
    final id = const Uuid().v4();
    final bool hasPermission = await _recorder.hasPermission();
    if (hasPermission) {
      final tempDir = await _getTemporaryDirectory();

      await _recorder.start(const RecordConfig(), path: '$tempDir/$id.acc');
      state = true;
    }
  }

  Future<String?> _stopRecording() async {
    if (await isRecording()) {
      final outputPath = await _recorder.stop();
      state = false;
      return outputPath;
    }
    return null;
  }

  Future<String> _getTemporaryDirectory() async {
    final dir = await getTemporaryDirectory();
    return dir.path;
  }

  Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }

  MessageModel _sendMessage(
      String uid, String url, String type, String content) {
    return MessageModel(
      id: uid,
      senderId: _auth.currentUser!.uid,
      content: content,
      timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
      status: 'sent',
      type: type,
      contentUrl: url,
      reactions: {},
    );
  }
}
