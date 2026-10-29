import 'dart:math';

import '../dados/repositorio_paises.dart';
import '../modelos/pais.dart';
import '../modelos/configuracao_jogo.dart';
import '../modelos/pergunta.dart';

class QuizEngine {
  final GameConfig config;
  final Random _random = Random();

  late final List<Country> _pool;
  final List<Country> _queue = [];
  Country? _lastAnswer;

  QuizEngine(this.config) {
    _pool = _buildPool();
  }

  int get poolSize => _pool.length;

  List<Country> _buildPool() {
    final repo = CountryRepository.instance;

    List<Country> countries = config.continent == null
        ? repo.all
        : repo.byContinent(config.continent!);

    if (config.difficulty == Difficulty.easy) {
      countries = countries.where((c) => c.isEasy).toList();
    }

    return countries;
  }

  Question nextQuestion() {
    if (_queue.isEmpty) {
      _queue.addAll(_pool);
      _queue.shuffle(_random);

      if (_queue.length > 1 && _queue.last.code == _lastAnswer?.code) {
        _queue.insert(0, _queue.removeLast());
      }
    }

    final answer = _queue.removeLast();
    _lastAnswer = answer;

    final wrongOptions = List<Country>.from(_pool)
      ..removeWhere((c) => c.code == answer.code)
      ..shuffle(_random);

    final options = [answer, ...wrongOptions.take(3)]..shuffle(_random);

    return Question(answer: answer, options: options);
  }
}
