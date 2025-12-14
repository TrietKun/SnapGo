import 'package:flutter/material.dart';
import 'package:snapgo/screens/login_screen.dart';
import 'package:snapgo/screens/main_screen.dart';
import 'package:snapgo/screens/profile_screen.dart';
import 'package:snapgo/screens/settings_screen.dart';
import 'package:snapgo/screens/onboarding_screen.dart'; // Thêm import
import 'package:snapgo/screens/signup_screen.dart';
import 'package:snapgo/screens/top_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';

class AppRoutes {
  // ---------------------------
  // Route names
  // ---------------------------
  static const String splash = '/splash';
  static const String onboarding = '/onboarding'; // Thêm dòng này
  static const String home = '/home';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String top = '/top';
  static const String main = '/main';
  static const String login = '/login';
  static const String signup = '/signup';

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

      case onboarding: // Thêm case này
        return _animatedRoute(
          routeSettings,
          const OnboardingScreen(),
        );

      case home:
        return _animatedRoute(
          routeSettings,
          HomeScreen(),
        );

      case settings:
        return _animatedRoute(
          routeSettings,
          const SettingsScreen(),
        );

      case profile:
        return _animatedRoute(
          routeSettings,
          const ProfileScreen(),
        );

      case top:
        return _animatedRoute(
          routeSettings,
          const TopScreen(),
        );

      case main:
        return _animatedRoute(
          routeSettings,
          const MainScreen(),
        );

      case login:
        return _animatedRoute(
          routeSettings,
          const LoginScreen(),
        );

      case signup:
        return _animatedRoute(
          routeSettings,
          const SignUpScreen(),
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
              begin: const Offset(0, 0.05),
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
