import 'package:chat_app/constants/app_constants.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/providers/general_providers.dart';
import 'package:chat_app/utils/routes/route_names.dart';
import 'package:chat_app/view_models.dart/chat_view_model.dart';
import 'package:chat_app/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/chat_list_tile.dart';
import '../../view_models.dart/user_view_model.dart';

class ChatListView extends ConsumerWidget {
  const ChatListView({super.key});

  void _onNavigateToChatView(
    String chatId,
    UserModel userModel,
    BuildContext context,
  ) async {
    if (context.mounted) {
      Navigator.pushNamed(context, RouteNames.chatView, arguments: {
        'chatId': chatId,
        'userModel': userModel,
      });
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserUid = ref.watch(firebaseAuthProvider).currentUser!.uid;
    final chatsAsyncValue = ref.watch(getAllChatsProvider(currentUserUid));
    return chatsAsyncValue.when(
        data: (data) => data.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final chat = data[index];

                  final otherUser = chat.participantIds.firstWhere(
                      (id) => id != currentUserUid,
                      orElse: () => 'Something went wrong');
                  return ref.watch(userDetailsProvider(otherUser)).when(
                      data: (data) => ChatListTile(
                            title: data.username,
                            subtitleText: Text(
                              chat.lastMessage,
                              style: const TextStyle(color: Colors.white),
                            ),
                            profilePic: data.profilePic!.isNotEmpty
                                ? data.profilePic!
                                : defaultProfilePic,
                            isOnline: data.isOnline,
                            onTap: () => _onNavigateToChatView(
                              chat.id,
                              data,
                              context,
                            ),
                          ),
                      error: (e, st) => Center(
                            child: Text(e.toString()),
                          ),
                      loading: () => const Loader());
                })
            : const Center(
                child: Text("No chats found"),
              ),
        error: (e, stackTrace) => const Text("Something went wrong"),
        loading: () => const Loader());
  }
}
