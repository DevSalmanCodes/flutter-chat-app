import 'package:chat_app/utils/routes/route_names.dart';
import 'package:chat_app/views/auth/sign_up_view.dart';
import 'package:chat_app/views/home/home_view.dart';
import 'package:chat_app/views/photo_view.dart';
import 'package:chat_app/views/search_view.dart';
import 'package:chat_app/views/splash_view.dart';
import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../views/auth/login_view.dart';
import '../../views/chat/chat_view.dart';

class AppRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.home:
        return MaterialPageRoute(builder: (context) => const HomeView());
     
      case RouteNames.chatView:
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          final chatId = args['chatId'] as String;
          final userModel = args['userModel'] as UserModel;
          return MaterialPageRoute(
              builder: (context) => ChatView(
                    userModel: userModel,
                    chatId: chatId,
                  ));
        }
        return _errorRoute(settings.name);
      case RouteNames.login:
        return MaterialPageRoute(builder: (context) => const LoginView());
      case RouteNames.signUp:
        return MaterialPageRoute(builder: (context) => const SignUpView());
      case RouteNames.splashView:
        return MaterialPageRoute(builder: (context) => const SplashView());
      case RouteNames.searchView:
        return MaterialPageRoute(builder: (context) => const SearchView());
      case RouteNames.photoView:
        if (settings.arguments is String) {
          final args = settings.arguments as String;
          return MaterialPageRoute(
              builder: (context) => PhotoView(imageUrl: args));
        }
        return _errorRoute(settings.name);
      default:
        return _errorRoute(settings.name);
    }
  }

  static Route<dynamic> _errorRoute(String? routeName) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        body: Center(child: Text("No route found for $routeName")),
      ),
    );
  }
}
