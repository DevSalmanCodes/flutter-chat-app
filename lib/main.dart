import 'package:chat_app/constants/color_constants.dart';
import 'package:chat_app/utils/routes/app_routes.dart';
import 'package:chat_app/view_models.dart/auth_view_model.dart';
import 'package:chat_app/views/auth/login_view.dart';
import 'package:chat_app/views/auth/sign_up_view.dart';
import 'package:chat_app/views/home/home_view.dart';
import 'package:chat_app/widgets/loader.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    final userStateAsyncValue = ref.watch(authStateChangesProvider);
    return MaterialApp(
        onGenerateRoute: AppRoutes.onGenerateRoute,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
              iconTheme: IconThemeData(color: ColorConstants.whiteColor)),
          iconTheme: const IconThemeData(color: ColorConstants.whiteColor),
          scaffoldBackgroundColor: ColorConstants.scaffoldBackgroundColor,
          indicatorColor: ColorConstants.whiteColor,
          hintColor: ColorConstants.whiteColor,
        ),
        home: userStateAsyncValue.when(
            data: (value) =>
                value != null ? const HomeView() : const LoginView(),
            error: (e, statckTrace) => Text(e.toString()),
            loading: () => const Loader()));
  }
}
