part of 'settings_bloc.dart';

class SettingsState {
  final ThemeMode themeMode;
  final String languageCode;
  final bool isLoading;
  final bool isFirstLaunch;

  SettingsState({
    this.themeMode = ThemeMode.system,
    this.languageCode = 'en',
    this.isLoading = true,
    this.isFirstLaunch = true,
  });

  bool get isDarkMode {
    if (themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return themeMode == ThemeMode.dark;
  }

  Locale get locale => Locale(languageCode);

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? languageCode,
    bool? isLoading,
    bool? isFirstLaunch,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      isLoading: isLoading ?? this.isLoading,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
    );
  }
}
