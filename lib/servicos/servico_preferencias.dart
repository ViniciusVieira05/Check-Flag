import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/configuracao_jogo.dart';

class SettingsService {
  SettingsService._();
  static final SettingsService instance = SettingsService._();

  static const _keyLanguage = 'language';
  static const _keySeconds = 'seconds';
  static const _keyDifficulty = 'difficulty';
  static const _keyPlayerName = 'playerName';
  static const _keyMusicOn = 'musicOn';
  static const _keySoundOn = 'soundOn';
  static const _keyMusicVolume = 'musicVolume';
  static const _keySoundVolume = 'soundVolume';

  String language = 'pt';
  int seconds = 60;
  Difficulty difficulty = Difficulty.easy;
  String playerName = '';
  bool musicOn = true;
  bool soundOn = true;
  double musicVolume = 0.7;
  double soundVolume = 1.0;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    language = prefs.getString(_keyLanguage) ?? 'pt';
    seconds = prefs.getInt(_keySeconds) ?? 60;
    difficulty = prefs.getString(_keyDifficulty) == 'hard' ? Difficulty.hard : Difficulty.easy;
    playerName = prefs.getString(_keyPlayerName) ?? '';
    musicOn = prefs.getBool(_keyMusicOn) ?? true;
    soundOn = prefs.getBool(_keySoundOn) ?? true;
    musicVolume = prefs.getDouble(_keyMusicVolume) ?? 0.7;
    soundVolume = prefs.getDouble(_keySoundVolume) ?? 1.0;
  }

  Future<void> setLanguage(String value) async {
    language = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, value);
  }

  Future<void> setSeconds(int value) async {
    seconds = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySeconds, value);
  }

  Future<void> setDifficulty(Difficulty value) async {
    difficulty = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDifficulty, value.name);
  }

  Future<void> setPlayerName(String value) async {
    playerName = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPlayerName, value);
  }

  Future<void> setMusicOn(bool value) async {
    musicOn = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMusicOn, value);
  }

  Future<void> setSoundOn(bool value) async {
    soundOn = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySoundOn, value);
  }

  Future<void> setMusicVolume(double value) async {
    musicVolume = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyMusicVolume, value);
  }

  Future<void> setSoundVolume(double value) async {
    soundVolume = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keySoundVolume, value);
  }
}
