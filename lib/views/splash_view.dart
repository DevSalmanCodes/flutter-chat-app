import 'package:chat_app/providers/general_providers.dart';
import 'package:chat_app/utils/routes/route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  void _navigate() {
    final userState = ref.read(firebaseAuthProvider).authStateChanges();
    userState.listen((user) {
      if (user != null) {
        Future.delayed(const Duration(milliseconds: 2500),
            () => Navigator.pushReplacementNamed(context, RouteNames.home));
      } else {
        Future.delayed(const Duration(milliseconds: 2500),
            () => Navigator.pushReplacementNamed(context, RouteNames.login));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
          child: Column(
        children: [],
      )),
    );
  }
}
