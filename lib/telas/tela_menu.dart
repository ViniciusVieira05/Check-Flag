import 'package:flutter/material.dart';

import '../idiomas/textos.dart';
import '../modelos/configuracao_jogo.dart';
import '../servicos/servico_preferencias.dart';
import '../servicos/servico_ranking.dart';
import 'tela_configuracoes.dart';
import 'tela_continentes.dart';
import 'tela_galeria.dart';
import 'tela_jogo.dart';
import 'tela_ranking.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final settings = SettingsService.instance;

  void _openSettings() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
    setState(() {});
  }

  void _openContinents() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ContinentScreen()));
  }

  void _startRandomGame() {
    final config = GameConfig(
      continent: null,
      totalSeconds: settings.seconds,
      difficulty: settings.difficulty,
    );
    Navigator.push(context, MaterialPageRoute(builder: (_) => GameScreen(config: config)));
  }

  void _openGallery() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryScreen()));
  }

  void _openRanking() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const RankingScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Flag'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: tr('settings'),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(child: Image.asset('assets/imagens/logo.png', width: 180, height: 180)),
          const SizedBox(height: 8),
          Text(
            tr('subtitle'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<int>(
            valueListenable: ScoreService.instance.best,
            builder: (context, best, _) => Text(
              tr('record', {'n': '$best'}),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),

          _title(tr('modeSection')),
          ElevatedButton.icon(
            onPressed: _openContinents,
            icon: const Icon(Icons.public),
            label: Text(tr('byContinent')),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _startRandomGame,
            icon: const Icon(Icons.shuffle),
            label: Text(tr('random')),
          ),
          const SizedBox(height: 24),

          Text(
            '${tr('timeSection')}: ${timeLabel(settings.seconds)}   •   '
            '${tr('difficultySection')}: ${difficultyLabel(settings.difficulty.name)}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),

          OutlinedButton.icon(
            onPressed: _openGallery,
            icon: const Icon(Icons.grid_view),
            label: Text(tr('gallery')),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _openRanking,
            icon: const Icon(Icons.emoji_events),
            label: Text(tr('ranking')),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings),
            label: Text(tr('settings')),
          ),
        ],
      ),
    );
  }

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}
