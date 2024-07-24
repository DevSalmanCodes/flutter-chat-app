import 'dart:io';

import 'package:chat_app/constants/app_constants.dart';
import 'package:chat_app/constants/color_constants.dart';
import 'package:chat_app/constants/size_constants.dart';
import 'package:chat_app/constants/text_style_constants.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/providers/general_providers.dart';
import 'package:chat_app/utils/methods.dart';
import 'package:chat_app/view_models.dart/chat_view_model.dart';
import 'package:chat_app/widgets/chat_bubble.dart';
import 'package:chat_app/widgets/custom_app_bar.dart';
import 'package:chat_app/widgets/loader.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';

import '../../utils/date_time.dart';

class ChatView extends ConsumerStatefulWidget {
  final String chatId;
  final UserModel userModel;
  const ChatView({
    super.key,
    required this.chatId,
    required this.userModel,
  });

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  late TextEditingController _controller;
  final recorder = AudioRecorder();

  File? _file;
  final _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    _markAsReadMessages();
  }

  void _onSendMessage() async {
    final message = _controller.text.trim();
    if (_file != null) {
      ref
          .watch(chatViewModelProvider.notifier)
          .sendImageMessage(widget.chatId, _file!, context);
    } else {
      if (_controller.text.isNotEmpty) {
        ref
            .watch(chatViewModelProvider.notifier)
            .sendTextMessage(widget.chatId, message, context);
      }
    }
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _jumpToLatestMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onPickImage() async {
    final image = await pickImage(context);
    setState(() {
      _file = image;
    });
  }

  Future<void> _markAsReadMessages() async {
    await ref
        .read(chatViewModelProvider.notifier)
        .markAsReadMessages(widget.chatId);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSize = MediaQuery.of(context).viewInsets.bottom;
    final messagesAsyncValue = ref.watch(getAllMessagesProvider(widget.chatId));
    final chatRef = ref.watch(chatViewModelProvider.notifier);
    final recordingState = ref.watch(chatViewModelProvider);
    final currentUserUid = ref.watch(firebaseAuthProvider).currentUser!.uid;
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.userModel.username,
        fontSize: 16.0,
        leading: CircleAvatar(
            backgroundImage: widget.userModel.profilePic!.isNotEmpty
                ? NetworkImage(widget.userModel.profilePic!)
                : const NetworkImage(defaultProfilePic)),
        lastSeen: widget.userModel.isOnline
            ? 'Active now'
            : 'Last seen: ${formatDate(widget.userModel.lastSeen)}',
      ),
      body: SizedBox(
        width: SizeConstants.width(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: SizeConstants.height(context) * 0.05,
            ),
            Expanded(
                flex: 6,
                child: messagesAsyncValue.when(
                    data: (data) {
                      data.sort((a, b) => a.timestamp!.compareTo(b.timestamp!));
                      _jumpToLatestMessage();
                      return ListView.builder(
                          controller: _scrollController,
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final message = data[index];
                           
                            final messageDate = message.timestamp!.toDate();
                            bool showDateHeader = false;

                            // Display the date header if it's the first message of the day or if the previous message was from a different day
                            if (index == 0) {
                              showDateHeader = true;
                            } else {
                              final previousMessageDate =
                                  data[index - 1].timestamp!.toDate();
                              if (messageDate.day != previousMessageDate.day ||
                                  messageDate.month !=
                                      previousMessageDate.month ||
                                  messageDate.year !=
                                      previousMessageDate.year) {
                                showDateHeader = true;
                              }
                            }
                            return Column(
                              children: [
                                if (showDateHeader)
                                  Text(
                                    formatDate(message.timestamp!),
                                    style: TextStyleConstants.semiBoldTextStyle,
                                  ),
                                ChatBubble(
                                  isSender: message.senderId == currentUserUid,
                                  messageModel: message,
                                  currentUseUid: currentUserUid,
                                  chatId: widget.chatId,
                                ),
                              ],
                            );
                          });
                    },
                    error: (e, st) => Text(e.toString()),
                    loading: () => const Loader())),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin:
            EdgeInsets.only(bottom: keyboardSize + 8.0, right: 8.0, left: 8.0),
        child: Expanded(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 200),
            padding: const EdgeInsets.all(SizeConstants.smallPadding),
            decoration: BoxDecoration(
                color: ColorConstants.messageTextFieldColor,
                borderRadius:
                    BorderRadius.circular(SizeConstants.smallRadius + 4.0)),
            child: Row(
              children: [
                IconButton(
                    onPressed: _onPickImage,
                    icon: const Icon(
                      Icons.image,
                      color: ColorConstants.whiteColor,
                    )),
                GestureDetector(
                  onLongPress: () {
                    if (context.mounted) chatRef.startRecording(context);
                  },
                  child: const Icon(
                    Icons.mic,
                  ),
                  onLongPressEnd: (value) {
                    if (context.mounted) {
                      chatRef.sendVoiceMessage(widget.chatId, context);
                    }
                  },
                ),
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(
                          left: SizeConstants.smallPadding + 4.0),
                      child: _file == null
                          ? TextFormField(
                              readOnly: recordingState,
                              style: const TextStyle(
                                  color: ColorConstants.whiteColor),
                              controller: _controller,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: recordingState == true
                                      ? 'Recording...'
                                      : "Message",
                                  hintStyle:
                                      TextStyleConstants.regularTextStyle),
                            )
                          : Image.file(File(_file!.path))),
                ),
                IconButton(
                    onPressed: _onSendMessage,
                    icon: const Icon(
                      Icons.send,
                      color: Color(0XFF9398A7),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
