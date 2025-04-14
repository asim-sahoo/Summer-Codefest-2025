import 'package:flutter/cupertino.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<T?> navigateTo<T>(Widget page) {
    return navigatorKey.currentState!.push<T>(
      CupertinoPageRoute<T>(builder: (BuildContext context) => page),
    );
  }

  static Future<T?> navigateToReplacement<T>(Widget page) {
    return navigatorKey.currentState!.pushReplacement<T, dynamic>(
      CupertinoPageRoute<T>(builder: (BuildContext context) => page),
    );
  }

  static Future<T?> navigateToAndRemoveUntil<T>(Widget page) {
    return navigatorKey.currentState!.pushAndRemoveUntil<T>(
      CupertinoPageRoute<T>(builder: (BuildContext context) => page),
      (Route<dynamic> route) => false,
    );
  }

  static void goBack<T>([T? result]) {
    return navigatorKey.currentState!.pop<T>(result);
  }
}