import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:snapgo/blocs/settings/settings_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;

    final state = context.read<SettingsBloc>().state;

    if (state.isFirstLaunch) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else {
      Navigator.pushReplacementNamed(context, '/main');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: MediaQuery.of(context).size.height * 0.1,
                child: Text(
                  'Welcome to SnapGo',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: FadeTransition(
                  opacity: _animation,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height *
                        0.45, // <-- quan trọng
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Theme.of(context).brightness == Brightness.dark
                          ? Image.asset(
                              'assets/lottie/dark_splash.gif',
                              key: const ValueKey('dark_gif'),
                              gaplessPlayback: true,
                              width: MediaQuery.of(context).size.width * 0.8,
                              fit: BoxFit.contain,
                            )
                          : Lottie.asset(
                              'assets/lottie/splash.json',
                              key: const ValueKey('light_lottie'),
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
