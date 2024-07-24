import 'package:chat_app/constants/app_constants.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/providers/general_providers.dart';
import 'package:chat_app/utils/routes/route_names.dart';
import 'package:chat_app/view_models.dart/chat_view_model.dart';
import 'package:chat_app/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/text_style_constants.dart';
import '../../../widgets/chat_list_tile.dart';
import '../../constants/size_constants.dart';
import '../../view_models.dart/user_view_model.dart';

class ChatListView extends ConsumerWidget {
  const ChatListView({super.key});

  static const largeRadius = SizeConstants.largeRadius;
  static const smallPadding = SizeConstants.smallPadding;

  void _onGetOrCreateChat(
    String userUid,
    String currentUserUid,
    UserModel userModel,
    WidgetRef ref,
    BuildContext context,
  ) async {
    final chatRef = ref.watch(chatViewModelProvider.notifier);
    final chatId =
        await chatRef.getOrCreateChat(userUid, currentUserUid, context);
    if (context.mounted) {
      Navigator.pushNamed(context, RouteNames.chatView, arguments: {
        'chatId': chatId,
        'userModel': userModel,
      });
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenHeight = SizeConstants.height(context);
    final isSmallScreen = SizeConstants.isSmallScreen(context);
    final currentUserUid = ref.watch(firebaseAuthProvider).currentUser!.uid;
    final usersAsyncValue = ref.watch(getAllUsersProvider);
    final chatsAsyncValue = ref.watch(getAllChatsProvider(currentUserUid));
    return usersAsyncValue.when(
        data: (data) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: smallPadding + 4.0,
                      vertical: smallPadding + 2.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Active Users",
                          style: TextStyleConstants.mediumTextStyle),
                      const SizedBox(
                        height: 12.0,
                      ),
                      SizedBox(
                        height: isSmallScreen
                            ? screenHeight * 0.20
                            : screenHeight * 0.25,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: data
                                .where((userValue) => userValue.isOnline)
                                .length,
                            itemBuilder: (context, index) {
                              final onlineUsers = data
                                  .where((userValue) => userValue.isOnline)
                                  .toList();
                              final user = onlineUsers[index];
                              return Padding(
                                padding: const EdgeInsets.only(
                                    right: smallPadding + 2.0),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: largeRadius + 11.0,
                                      backgroundImage:
                                          user.profilePic!.isNotEmpty
                                              ? NetworkImage(user.profilePic!)
                                              : const NetworkImage(
                                                  defaultProfilePic),
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    Text(
                                      user.username,
                                      style:
                                          TextStyleConstants.regularTextStyle,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  ],
                                ),
                              );
                            }),
                      )
                    ],
                  ),
                ),
                chatsAsyncValue.when(
                    data: (data) => data.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              final chat = data[index];
                              final currentUser = chat.participantIds
                                  .firstWhere((id) => id == currentUserUid,
                                      orElse: () => 'Something went wrong');
                              final otherUser = chat.participantIds.firstWhere(
                                  (id) => id != currentUser,
                                  orElse: () => 'Something went wrong');
                              return ref
                                  .watch(userDetailsProvider(otherUser))
                                  .when(
                                      data: (data) => ChatListTile(
                                            title: data.username,
                                            subtitleText: Text(
                                             chat.lastMessage,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                            profilePic:
                                                data.profilePic!.isNotEmpty
                                                    ? data.profilePic!
                                                    : defaultProfilePic,
                                            isOnline: data.isOnline,
                                            onTap: () => _onGetOrCreateChat(
                                              otherUser,
                                              currentUser,
                                              data,
                                              ref,
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
                    error: (e, stackTrace) =>
                        const Text("Something went wrong"),
                    loading: () => const Loader())
              ],
            ),
        error: (e, st) => Text(e.toString()),
        loading: () => const Loader());
  }
}
