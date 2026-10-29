import 'package:check_flag/dados/repositorio_paises.dart';
import 'package:check_flag/logica/motor_quiz.dart';
import 'package:check_flag/modelos/continente.dart';
import 'package:check_flag/modelos/configuracao_jogo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await CountryRepository.instance.load();
  });

  test('o banco tem os 5 continentes e 194 países', () {
    final repo = CountryRepository.instance;
    for (final c in Continent.values) {
      expect(repo.byContinent(c), isNotEmpty);
    }
    expect(repo.all.length, 194);
  });

  test('cada pergunta tem 4 opções diferentes e inclui a resposta certa', () {
    final engine = QuizEngine(const GameConfig(
      continent: null,
      totalSeconds: 60,
      difficulty: Difficulty.hard,
    ));

    for (int i = 0; i < 100; i++) {
      final q = engine.nextQuestion();
      final codes = q.options.map((c) => c.code).toSet();
      expect(q.options.length, 4);
      expect(codes.length, 4);
      expect(codes.contains(q.answer.code), isTrue);
    }
  });

  test('modo continente só sorteia países daquele continente', () {
    final engine = QuizEngine(const GameConfig(
      continent: Continent.oceania,
      totalSeconds: 30,
      difficulty: Difficulty.easy,
    ));

    for (int i = 0; i < 30; i++) {
      final q = engine.nextQuestion();
      for (final option in q.options) {
        expect(option.continent, Continent.oceania);
        expect(option.isEasy, isTrue);
      }
    }
  });
}
