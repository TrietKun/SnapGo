import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:snapgo/blocs/auth/auth_bloc.dart';
import 'package:snapgo/blocs/auth/auth_event.dart';
import 'package:snapgo/blocs/settings/settings_bloc.dart';
import 'package:snapgo/core/constants/app_theme.dart';
import 'package:snapgo/repositories/auth_repositories/firebase_auth_repository.dart';
import 'package:snapgo/repositories/auth_repositories/user_repository.dart';
import 'package:snapgo/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp();

  // Khởi tạo Hive
  await Hive.initFlutter();

  // Khởi tạo Repositories
  final authRepository = FirebaseAuthRepository();
  final userRepository = FirebaseUserRepository();

  // Khởi tạo SettingsBloc
  final settingsBloc = SettingsBloc();
  await settingsBloc.init();

  // Khởi tạo AuthBloc
  final authBloc = AuthBloc(
    authRepository: authRepository,
    userRepository: userRepository,
  )..add(const AuthStarted()); // Check auth ngay khi start

  runApp(MyApp(
    settingsBloc: settingsBloc,
    authBloc: authBloc,
  ));
}

class MyApp extends StatelessWidget {
  final SettingsBloc settingsBloc;
  final AuthBloc authBloc;

  const MyApp({
    super.key,
    required this.settingsBloc,
    required this.authBloc,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // SettingsBloc
        BlocProvider.value(value: settingsBloc),

        // AuthBloc - Available cho toàn app
        BlocProvider.value(value: authBloc),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: state.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            onGenerateTitle: (BuildContext context) =>
                AppLocalizations.of(context)!.appTitle,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRoutes.generateRoute,
            restorationScopeId: 'app',
          );
        },
      ),
    );
  }
}
