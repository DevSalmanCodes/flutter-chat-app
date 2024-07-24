import 'package:chat_app/constants/color_constants.dart';
import 'package:chat_app/constants/text_style_constants.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/providers/general_providers.dart';
import 'package:chat_app/utils/routes/route_names.dart';
import 'package:chat_app/view_models.dart/chat_view_model.dart';
import 'package:chat_app/view_models.dart/user_view_model.dart';
import 'package:chat_app/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  late TextEditingController _controller;
  String _query = '';
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  void _onChanged(String newQuery) {
    setState(() {
      _query = newQuery.trim();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onGetOrCreateChat(String userUid, String currentUserUid,
      UserModel userModel, context) async {
    if (userUid != currentUserUid) {
      final chatId = await ref
          .read(chatViewModelProvider.notifier)
          .getOrCreateChat(userUid, currentUserUid, context);

      if (context.mounted) {
        Navigator.pushNamed(context, RouteNames.chatView, arguments: {
          'userModel': userModel,
          'chatId': chatId,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchUsersAsyncValue = ref.watch(getSearchUsersProvider(_query));
    final currentUserUid = ref.watch(firebaseAuthProvider).currentUser!.uid;
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Column(
          children: [
            TextFormField(
              onChanged: _onChanged,
              controller: _controller,
              style: TextStyleConstants.regularTextStyle,
              decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: ColorConstants.whiteColor)),
                border: OutlineInputBorder(),
                hintText: 'Search',
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            searchUsersAsyncValue.when(
                data: (data) => Expanded(
                      child: ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final user = data[index];
                            return ListTile(
                              onTap: () => _onGetOrCreateChat(
                                  user.uid, currentUserUid, user, context),
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(user.profilePic ?? ''),
                                radius: 35,
                              ),
                              title: Text(
                                user.username,
                                style: TextStyleConstants.semiBoldTextStyle,
                              ),
                            );
                          }),
                    ),
                error: (e, st) => Text(e.toString()),
                loading: () => const Loader())
          ],
        ),
      )),
    );
  }
}
