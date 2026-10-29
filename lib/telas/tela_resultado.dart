import 'package:flutter/material.dart';

import '../componentes/imagem_bandeira.dart';
import '../idiomas/textos.dart';
import '../modelos/configuracao_jogo.dart';
import '../modelos/erro_resposta.dart';
import '../modelos/resultado_jogo.dart';
import '../servicos/servico_preferencias.dart';
import '../servicos/servico_ranking.dart';
import '../tema/tema_app.dart';
import 'tela_jogo.dart';

class ResultScreen extends StatefulWidget {
  final GameResult result;
  final GameConfig config;
  final List<Mistake> mistakes;

  const ResultScreen({
    super.key,
    required this.result,
    required this.config,
    required this.mistakes,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _nameController = TextEditingController(text: SettingsService.instance.playerName);

  bool _saved = false;
  String? _nameError;
  late final bool _isNewRecord;

  @override
  void initState() {
    super.initState();
    _isNewRecord = ScoreService.instance.isNewRecord(widget.result);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveScore() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = tr('nameEmpty'));
      return;
    }

    await ScoreService.instance.saveResult(widget.result.withName(name));
    await SettingsService.instance.setPlayerName(name);

    if (!mounted) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _saved = true;
      _nameError = null;
    });
  }

  void _playAgain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => GameScreen(config: widget.config)),
    );
  }

  void _backToMenu() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final lang = SettingsService.instance.language;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _backToMenu();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr('resultTitle')),
          automaticallyImplyLeading: false,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              tr('timeUp'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              '${modeLabel(result.continentKey)} - ${difficultyLabel(result.difficulty)} - '
              '${timeLabel(result.totalSeconds)}',
              textAlign: TextAlign.center,
            ),
            if (_isNewRecord)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  tr('newRecord'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ),
            const SizedBox(height: 16),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: Text(tr('answered')),
                    trailing: Text('${result.answered}', style: _numberStyle),
                  ),
                  ListTile(
                    leading: const Icon(Icons.check_circle, color: AppColors.correct),
                    title: Text(tr('hits')),
                    trailing: Text('${result.correct}', style: _numberStyle),
                  ),
                  ListTile(
                    leading: const Icon(Icons.percent),
                    title: Text(tr('accuracy')),
                    trailing: Text('${result.percentage}%', style: _numberStyle),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text(tr('saveTitle'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (_saved)
              Text(tr('saved'), style: const TextStyle(color: AppColors.correct, fontSize: 16))
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      maxLength: 15,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: tr('nameLabel'),
                        border: const OutlineInputBorder(),
                        errorText: _nameError,
                      ),
                      onSubmitted: (_) => _saveScore(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: ElevatedButton(onPressed: _saveScore, child: Text(tr('save'))),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _playAgain,
              icon: const Icon(Icons.replay),
              label: Text(tr('playAgain')),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _backToMenu,
              icon: const Icon(Icons.home),
              label: Text(tr('mainMenu')),
            ),

            if (widget.mistakes.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(tr('mistakesTitle'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              for (final m in widget.mistakes)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: FlagImage(asset: m.correct.flagAsset, width: 48),
                  title: Text(m.correct.nameIn(lang)),
                  subtitle: Text(tr('yourAnswer', {'name': m.chosen.nameIn(lang)})),
                ),
            ],
          ],
        ),
      ),
    );
  }

  static const _numberStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
}
