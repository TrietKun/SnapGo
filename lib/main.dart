import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:snapgo/blocs/settings/settings_bloc.dart';
import 'package:snapgo/core/constants/app_theme.dart';
import 'package:snapgo/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //firebase
  await Firebase.initializeApp();

  // Khởi tạo Hive
  await Hive.initFlutter();

  // Khởi tạo SettingsBloc
  final settingsBloc = SettingsBloc();
  await settingsBloc.init();

  runApp(MyApp(settingsBloc: settingsBloc));
}

class MyApp extends StatelessWidget {
  final SettingsBloc settingsBloc;

  const MyApp({super.key, required this.settingsBloc});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: settingsBloc,
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
