import 'dart:async';

import 'package:flutter/material.dart';

import '../componentes/bandeira_animada.dart';
import '../componentes/botao_resposta.dart';
import '../componentes/dialogo_confirmacao.dart';
import '../idiomas/textos.dart';
import '../logica/motor_quiz.dart';
import '../modelos/configuracao_jogo.dart';
import '../modelos/erro_resposta.dart';
import '../modelos/pais.dart';
import '../modelos/pergunta.dart';
import '../modelos/resultado_jogo.dart';
import '../servicos/servico_audio.dart';
import '../servicos/servico_preferencias.dart';
import '../tema/tema_app.dart';
import 'tela_resultado.dart';

class GameScreen extends StatefulWidget {
  final GameConfig config;
  const GameScreen({super.key, required this.config});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final QuizEngine _engine;
  late Question _question;

  Timer? _timer;
  late int _remaining;

  int _questionNumber = 1;
  int _answered = 0;
  int _correct = 0;
  final List<Mistake> _mistakes = [];

  Country? _selected;
  bool _finished = false;

  String get _lang => SettingsService.instance.language;

  @override
  void initState() {
    super.initState();
    _engine = QuizEngine(widget.config);
    _question = _engine.nextQuestion();
    _remaining = widget.config.totalSeconds;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining <= 1) {
        setState(() => _remaining = 0);
        _finishGame();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final rest = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$rest';
  }

  void _onAnswer(Country chosen) {
    if (_selected != null || _finished) return;

    final isCorrect = _question.isCorrect(chosen);

    setState(() {
      _selected = chosen;
      _answered++;
      if (isCorrect) {
        _correct++;
      } else {
        _mistakes.add(Mistake(correct: _question.answer, chosen: chosen));
      }
    });

    if (isCorrect) {
      AudioService.instance.playCorrect();
    } else {
      AudioService.instance.playWrong();
    }

    final wait = Duration(milliseconds: isCorrect ? 800 : 1500);
    Future.delayed(wait, () {
      if (!mounted || _finished) return;
      setState(() {
        _question = _engine.nextQuestion();
        _selected = null;
        _questionNumber++;
      });
    });
  }

  AnswerState _stateFor(Country option) {
    if (_selected == null) return AnswerState.idle;
    if (option.code == _question.answer.code) return AnswerState.correct;
    if (option.code == _selected!.code) return AnswerState.wrong;
    return AnswerState.dimmed;
  }

  void _finishGame() {
    if (_finished) return;
    _finished = true;
    _timer?.cancel();
    AudioService.instance.playGameOver();

    final result = GameResult(
      answered: _answered,
      correct: _correct,
      totalSeconds: widget.config.totalSeconds,
      continentKey: widget.config.continent?.jsonKey,
      difficulty: widget.config.difficulty.name,
      date: DateTime.now(),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(result: result, config: widget.config, mistakes: _mistakes),
      ),
    );
  }

  Future<void> _confirmQuit() async {
    _timer?.cancel();
    final leave = await showConfirmDialog(
      context,
      title: tr('quitTitle'),
      message: tr('quitMessage'),
      cancelText: tr('cancel'),
      confirmText: tr('leave'),
    );
    if (!mounted) return;
    if (leave) {
      _finished = true;
      Navigator.pop(context);
    } else {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.config.totalSeconds;

    String feedback = '';
    Color feedbackColor = Colors.black;
    if (_selected != null) {
      if (_question.isCorrect(_selected!)) {
        feedback = tr('correctFeedback');
        feedbackColor = AppColors.correct;
      } else {
        feedback = tr('wrongFeedback', {'name': _question.answer.nameIn(_lang)});
        feedbackColor = AppColors.wrong;
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_finished) _confirmQuit();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr('question', {'n': '$_questionNumber'})),
          leading: IconButton(icon: const Icon(Icons.close), onPressed: _confirmQuit),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr('time', {'t': _formatTime(_remaining)}),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _remaining <= 10 ? AppColors.wrong : Colors.black,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: Tween(begin: 1.6, end: 1.0).animate(
                        CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                      ),
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: Text(
                      tr('points', {'n': '$_correct'}),
                      key: ValueKey(_correct),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _correct > 0 ? AppColors.correct : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: _remaining / total, minHeight: 6),
              const SizedBox(height: 16),

              Expanded(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      final isNew = child.key == ValueKey(_questionNumber);
                      if (!isNew) {
                        return FadeTransition(opacity: animation, child: child);
                      }
                      final slide = Tween(begin: const Offset(1, 0), end: Offset.zero).animate(
                        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                      );
                      return SlideTransition(
                        position: slide,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: AnimatedFlag(
                      key: ValueKey(_questionNumber),
                      asset: _question.answer.flagAsset,
                      correct: _selected == null ? null : _question.isCorrect(_selected!),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(tr('whichCountry'), style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 4),
              SizedBox(
                height: 24,
                child: Text(
                  feedback,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: feedbackColor),
                ),
              ),
              const SizedBox(height: 8),

              for (final option in _question.options)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AnswerButton(
                    text: option.nameIn(_lang),
                    state: _stateFor(option),
                    onTap: () => _onAnswer(option),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
