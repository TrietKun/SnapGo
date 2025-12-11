import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  static const String _boxName = 'settings';
  static const String _themeModeKey = 'themeMode';
  static const String _languageKey = 'language';

  late Box _settingsBox;

  SettingsBloc() : super(SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<ChangeThemeMode>(_onChangeThemeMode);
    on<ChangeLanguage>(_onChangeLanguage);
    on<ResetSettings>(_onResetSettings);
  }

  Future<void> init() async {
    _settingsBox = await Hive.openBox(_boxName);
    add(LoadSettings());
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    final themeModeString =
        _settingsBox.get(_themeModeKey, defaultValue: 'system');

    ThemeMode themeMode;
    switch (themeModeString) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
    }

    final languageCode = _settingsBox.get(_languageKey, defaultValue: 'en');

    emit(state.copyWith(
      themeMode: themeMode,
      languageCode: languageCode,
      isLoading: false,
    ));
  }

  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(languageCode: event.languageCode));
    await _settingsBox.put(_languageKey, event.languageCode);
  }

  Future<void> _onChangeThemeMode(
    ChangeThemeMode event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(themeMode: event.themeMode));

    String themeModeString;
    switch (event.themeMode) {
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      case ThemeMode.system:
        themeModeString = 'system';
        break;
    }

    await _settingsBox.put(_themeModeKey, themeModeString);
  }

  Future<void> _onResetSettings(
    ResetSettings event,
    Emitter<SettingsState> emit,
  ) async {
    await _settingsBox.clear();
    emit(state.copyWith(
      themeMode: ThemeMode.system,
      languageCode: 'en',
    ));
  }
}
