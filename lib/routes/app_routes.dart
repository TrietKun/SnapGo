import 'package:flutter/material.dart';
import 'package:snapgo/screens/settings_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';

class AppRoutes {
  // ---------------------------
  // Route names
  // ---------------------------
  static const String splash = '/splash';
  static const String home = '/home';
  static const String settings = '/settings';

  // ---------------------------
  // Main Router
  // ---------------------------
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return _animatedRoute(
          routeSettings,
          const SplashScreen(),
        );

      case home:
        return _animatedRoute(
          routeSettings,
          const HomeScreen(),
        );

      case settings:
        // Placeholder for SettingsScreen
        return _animatedRoute(
          routeSettings,
          const SettingsScreen(),
        );

      default:
        return _animatedRoute(
          routeSettings,
          const Scaffold(
            body: Center(child: Text('No route defined')),
          ),
        );
    }
  }

  // ---------------------------
  // Default Transition Animation
  // Fade + Slide Up
  // ---------------------------
  static PageRouteBuilder _animatedRoute(
    RouteSettings settings,
    Widget page,
  ) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05), // hơi đẩy lên nhẹ
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: page,
          ),
        );
      },
    );
  }
}
