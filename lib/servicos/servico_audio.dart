import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'servico_preferencias.dart';

class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _music = AudioPlayer();
  final AudioPlayer _effects = AudioPlayer();

  SettingsService get _settings => SettingsService.instance;

  Future<void> init() async {
    final context = AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build();
    await AudioPlayer.global.setAudioContext(context);

    await _music.setAudioContext(context);
    await _effects.setAudioContext(context);
    await _music.setReleaseMode(ReleaseMode.loop);
    await _music.setVolume(_settings.musicVolume);

    if (_settings.musicOn) {
      await startMusic();
    }
  }

  Future<void> startMusic() async {
    try {
      await _music.stop();
      await _music.setSource(AssetSource('sons/musica.mp3'));
      await _music.resume();
    } catch (e) {
      debugPrint('Erro ao tocar a música: $e');
    }
  }

  Future<void> pauseMusic() async {
    await _music.pause();
  }

  Future<void> resumeMusic() async {
    if (_settings.musicOn) {
      await _music.resume();
    }
  }

  Future<void> setMusicOn(bool value) async {
    await _settings.setMusicOn(value);
    if (value) {
      await startMusic();
    } else {
      await _music.stop();
    }
  }

  Future<void> setSoundOn(bool value) async {
    await _settings.setSoundOn(value);
  }

  Future<void> previewMusicVolume(double value) async {
    _settings.musicVolume = value;
    await _music.setVolume(value);
  }

  Future<void> saveMusicVolume(double value) async {
    await _settings.setMusicVolume(value);
    await _music.setVolume(value);
  }

  Future<void> saveSoundVolume(double value) async {
    await _settings.setSoundVolume(value);
    await playCorrect();
  }

  Future<void> _playEffect(String file) async {
    if (!_settings.soundOn) return;
    try {
      await _effects.stop();
      await _effects.play(AssetSource('sons/$file'), volume: _settings.soundVolume);
    } catch (e) {
      debugPrint('Erro ao tocar o efeito: $e');
    }
  }

  Future<void> playCorrect() => _playEffect('acerto.mp3');
  Future<void> playWrong() => _playEffect('erro.mp3');
  Future<void> playGameOver() => _playEffect('fim.mp3');
}
