import 'package:chat_app/constants/color_constants.dart';
import 'package:chat_app/utils/routes/app_routes.dart';
import 'package:chat_app/utils/routes/route_names.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        onGenerateRoute: AppRoutes.onGenerateRoute,
        initialRoute: RouteNames.splashView,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
              iconTheme: IconThemeData(color: ColorConstants.whiteColor)),
          iconTheme: const IconThemeData(color: ColorConstants.whiteColor),
          scaffoldBackgroundColor: ColorConstants.scaffoldBackgroundColor,
          indicatorColor: ColorConstants.whiteColor,
          hintColor: ColorConstants.whiteColor,
        ),
      );
  }
}
