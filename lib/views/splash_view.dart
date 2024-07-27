import 'package:chat_app/constants/color_constants.dart';
import 'package:chat_app/providers/general_providers.dart';
import 'package:chat_app/utils/routes/route_names.dart';
import 'package:chat_app/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

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
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SvgPicture.asset(
                'assets/images/message_icon.svg',
                height: 120.0,
              ),
            ),
            const Loader(
              color: ColorConstants.whiteColor,
            ),
            const SizedBox(
              height: 60.0,
            )
          ],
        ),
      )),
    );
  }
}
