import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snapgo/blocs/auth/auth_bloc.dart';
import 'package:snapgo/blocs/auth/auth_event.dart';
import 'package:snapgo/blocs/home/home_bloc.dart';
import 'package:snapgo/repositories/auth_repositories/firebase_auth_repository.dart';
import 'package:snapgo/repositories/auth_repositories/user_repository.dart';
import 'package:snapgo/repositories/spot_repositories/spot_repository.dart';
import 'package:snapgo/screens/profile_screen.dart';
import 'package:snapgo/screens/top_screen.dart';
import 'package:snapgo/services/spot/spot_service.dart';
import 'home_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Tạo repositories
    final spotRepository =
        SpotRepository(SpotService(FirebaseFirestore.instance));
    final authRepository = FirebaseAuthRepository();
    final userRepository = FirebaseUserRepository();

    return MultiRepositoryProvider(
      providers: [
        // Provide repositories trước
        RepositoryProvider<FirebaseAuthRepository>.value(value: authRepository),
        RepositoryProvider<FirebaseUserRepository>.value(value: userRepository),
        RepositoryProvider<SpotRepository>.value(value: spotRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => HomeBloc(
              context.read<SpotRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<FirebaseAuthRepository>(),
              userRepository: context.read<FirebaseUserRepository>(),
            )..add(const AuthStarted()),
          ),
        ],
        child: const _MainScreenView(),
      ),
    );
  }
}

class _MainScreenView extends StatefulWidget {
  const _MainScreenView();

  @override
  State<_MainScreenView> createState() => _MainScreenViewState();
}

class _MainScreenViewState extends State<_MainScreenView> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TopScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context)
            .elevatedButtonTheme
            .style
            ?.backgroundColor
            ?.resolve({}),
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.explore),
            label: l10n.explore,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.leaderboard),
            label: l10n.top,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
