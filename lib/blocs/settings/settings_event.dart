part of 'settings_bloc.dart';
abstract class SettingsEvent {}

class LoadSettings extends SettingsEvent {}

class ChangeThemeMode extends SettingsEvent {
  final ThemeMode themeMode;
  
  ChangeThemeMode(this.themeMode);
}

class ChangeLanguage extends SettingsEvent {
  final String languageCode;
  ChangeLanguage(this.languageCode);
}

class ResetSettings extends SettingsEvent {}
