import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/utils/routes/route_names.dart';
import 'package:chat_app/view_models.dart/chat_view_model.dart';
import 'package:chat_app/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:voice_message_package/voice_message_package.dart';

import '../constants/color_constants.dart';
import '../constants/size_constants.dart';
import '../constants/text_style_constants.dart';

class ChatBubble extends ConsumerWidget {
  final bool isSender;
  final MessageModel messageModel;
  final String currentUserUid;
  final String chatId;
  const ChatBubble({
    super.key,
    required this.isSender,
    required this.messageModel,
    required this.currentUserUid,
    required this.chatId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Align(
          alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
          child: IntrinsicWidth(
            child: GestureDetector(
              onLongPress: () => _showReactionPicker(
                  context, messageModel.id, chatId, ref, messageModel),
              child: Stack(
                children: [
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width - 30),
                    alignment: Alignment.topRight,
                    margin: EdgeInsets.only(
                        top: 10.0,
                        bottom: 10.0,
                        left: isSender
                            ? SizeConstants.smallPadding + 60.0
                            : SizeConstants.smallPadding - 2.0,
                        right: isSender
                            ? SizeConstants.smallPadding - 2.0
                            : SizeConstants.smallPadding + 10),
                    padding:
                        const EdgeInsets.all(SizeConstants.smallPadding + 4.0),
                    decoration: BoxDecoration(
                        color: isSender
                            ? ColorConstants.senderChatColor
                            : ColorConstants.receiverChatColor,
                        borderRadius: BorderRadius.circular(12.0)),
                    child: messageModel.type == 'text'
                        ? _buildTextWidget(messageModel, currentUserUid)
                        : messageModel.type == 'voice'
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (messageModel.contentUrl.isNotEmpty)
                                    VoiceMessageView(
                                        controller: VoiceController(
                                            audioSrc: messageModel.contentUrl,
                                            maxDuration:
                                                const Duration(minutes: 5),
                                            isFile: false,
                                            onComplete: () {},
                                            onPause: () {},
                                            onPlaying: () {})),
                                  if (messageModel.senderId == currentUserUid)
                                    ..._messageStatusWidget(messageModel,
                                        height: 4.0)
                                ],
                              )
                            : _buildImageWidget(
                                context, messageModel, currentUserUid),
                  ),
                  Positioned(
                    bottom: 0,
                    right: isSender ? 0 : 15,
                    child: Row(
                      children: messageModel.reactions.entries
                          .map((e) => Text(e.key))
                          .toList(),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

void _showReactionPicker(BuildContext context, String messageId, String chatId,
    WidgetRef ref, MessageModel messageModel) {
  showModalBottomSheet(
    backgroundColor: ColorConstants.messageTextFieldColor,
    context: context,
    builder: (context) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          '👍',
          '❤️',
          '😂',
          '😮',
          '😢',
          '😡',
        ].map((reaction) {
          return IconButton(
              icon: Text(reaction, style: const TextStyle(fontSize: 24)),
              onPressed: () async {
                ref.read(chatViewModelProvider.notifier).addReactionToMessage(
                      messageId,
                      chatId,
                      reaction,
                    );
                Navigator.pop(context);
              });
        }).toList(),
      );
    },
  );
}

Widget _buildImageWidget(
    BuildContext context, MessageModel messageModel, String currentUserUid) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      GestureDetector(
        onTap: () => Navigator.pushNamed(context, RouteNames.photoView,
            arguments: messageModel.contentUrl),
        child: CachedNetworkImage(
          imageUrl: messageModel.contentUrl,
          fit: BoxFit.cover,
          height: 150,
          width: 150,
          placeholder: (context, url) => const Loader(),
        ),
      ),
      if (messageModel.senderId == currentUserUid)
        ..._messageStatusWidget(messageModel, height: 8.0)
    ],
  );
}

Widget _buildTextWidget(MessageModel messageModel, String currentUserUid) {
  return Row(
    children: [
      Flexible(
        child: Text(
          messageModel.content,
          style: TextStyleConstants.regularTextStyle,
        ),
      ),
      if (messageModel.senderId == currentUserUid)
        ..._messageStatusWidget(messageModel, width: 8.0)
    ],
  );
}

List<Widget> _messageStatusWidget(MessageModel messageModel,
    {double? height, double? width}) {
  return [
    SizedBox(
      height: height,
      width: width,
    ),
    Icon(
      messageModel.status == 'sent' ? Icons.done : Icons.done_all,
      size: 15.0,
      color: messageModel.status == 'seen' ? Colors.blue : null,
    ),
  ];
}
