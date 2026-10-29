import 'package:flutter/material.dart';

import '../idiomas/textos.dart';
import '../modelos/configuracao_jogo.dart';
import '../servicos/servico_audio.dart';
import '../servicos/servico_preferencias.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final settings = SettingsService.instance;
  final audio = AudioService.instance;

  late double _musicVolume = settings.musicVolume;
  late double _soundVolume = settings.soundVolume;

  void _setMusicOn(bool value) async {
    await audio.setMusicOn(value);
    setState(() {});
  }

  void _setSoundOn(bool value) async {
    await audio.setSoundOn(value);
    setState(() {});
  }

  void _changeLanguage(String lang) async {
    await settings.setLanguage(lang);
    setState(() {});
  }

  void _changeTime(int seconds) async {
    await settings.setSeconds(seconds);
    setState(() {});
  }

  void _changeDifficulty(Difficulty difficulty) async {
    await settings.setDifficulty(difficulty);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('settings'))),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _section(tr('audioSection')),
          SwitchListTile(
            secondary: const Icon(Icons.music_note),
            title: Text(tr('music')),
            value: settings.musicOn,
            onChanged: _setMusicOn,
          ),
          _volumeSlider(
            value: _musicVolume,
            enabled: settings.musicOn,
            onChanged: (v) {
              setState(() => _musicVolume = v);
              audio.previewMusicVolume(v);
            },
            onChangeEnd: audio.saveMusicVolume,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up),
            title: Text(tr('sounds')),
            value: settings.soundOn,
            onChanged: _setSoundOn,
          ),
          _volumeSlider(
            value: _soundVolume,
            enabled: settings.soundOn,
            onChanged: (v) => setState(() => _soundVolume = v),
            onChangeEnd: audio.saveSoundVolume,
          ),
          const Divider(),

          _section(tr('language')),
          _chips<String>(
            options: {for (final e in kLanguages.entries) e.key: e.value},
            selected: settings.language,
            onSelected: _changeLanguage,
          ),
          const Divider(),

          _section(tr('timeSection')),
          _chips<int>(
            options: {for (final s in kTimeOptions) s: timeLabel(s)},
            selected: settings.seconds,
            onSelected: _changeTime,
          ),
          const Divider(),

          _section(tr('difficultySection')),
          _chips<Difficulty>(
            options: {Difficulty.easy: tr('easy'), Difficulty.hard: tr('hard')},
            selected: settings.difficulty,
            onSelected: _changeDifficulty,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Text(
              settings.difficulty == Difficulty.easy ? tr('easyDesc') : tr('hardDesc'),
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  Widget _volumeSlider({
    required double value,
    required bool enabled,
    required ValueChanged<double> onChanged,
    required ValueChanged<double> onChangeEnd,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.volume_mute, size: 20, color: Colors.black45),
          Expanded(
            child: Slider(
              value: value,
              divisions: 10,
              label: '${(value * 100).round()}%',
              onChanged: enabled ? onChanged : null,
              onChangeEnd: enabled ? onChangeEnd : null,
            ),
          ),
          SizedBox(width: 44, child: Text('${(value * 100).round()}%')),
        ],
      ),
    );
  }

  Widget _chips<T>({
    required Map<T, String> options,
    required T selected,
    required ValueChanged<T> onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Wrap(
        spacing: 8,
        children: [
          for (final entry in options.entries)
            ChoiceChip(
              label: Text(entry.value),
              selected: entry.key == selected,
              onSelected: (_) => onSelected(entry.key),
            ),
        ],
      ),
    );
  }
}
