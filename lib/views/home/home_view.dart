import 'package:chat_app/utils/routes/route_names.dart';
import 'package:chat_app/view_models.dart/auth_view_model.dart';
import 'package:chat_app/view_models.dart/user_view_model.dart';
import 'package:chat_app/views/chat/chat_list_view.dart';
import 'package:chat_app/widgets/custom_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _changeUserStatus(false);
    } else if (state == AppLifecycleState.resumed) {
      _changeUserStatus(true);
    }
  }

  void _changeUserStatus(bool status) {
    ref.read(userViewModelProvider).changeUserStatus(status);
  }

  void _onSignOut() {
    ref.read(authViewModelProvider.notifier).signOut();
  }

  void _onNavigateToSearch() {
    Navigator.pushNamed(context, RouteNames.searchView);
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: CustomAppBar(title: "Chats", actionItemsList: [
        IconButton(
          onPressed: _onSignOut,
          icon: const Icon(
            Icons.logout,
            size: 30.0,
          ),
        ),
        IconButton(
            onPressed: _onNavigateToSearch,
            icon: const Icon(
              CupertinoIcons.search,
              size: 30.0,
            ))
      ]),
      body: const SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: ChatListView(),
      ),
    );
  }
}
