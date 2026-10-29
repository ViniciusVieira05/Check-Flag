import 'pais.dart';

class Question {
  final Country answer;
  final List<Country> options;

  const Question({required this.answer, required this.options});

  bool isCorrect(Country chosen) => chosen.code == answer.code;
}
