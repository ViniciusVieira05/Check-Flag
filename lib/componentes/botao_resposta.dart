import 'package:flutter/material.dart';

import '../tema/tema_app.dart';

enum AnswerState {
  idle,
  correct,
  wrong,
  dimmed,
}

class AnswerButton extends StatelessWidget {
  final String text;
  final AnswerState state;
  final VoidCallback onTap;

  const AnswerButton({
    super.key,
    required this.text,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color background = Colors.white;
    Color textColor = Colors.black87;

    if (state == AnswerState.correct) {
      background = AppColors.correct;
      textColor = Colors.white;
    } else if (state == AnswerState.wrong) {
      background = AppColors.wrong;
      textColor = Colors.white;
    } else if (state == AnswerState.dimmed) {
      textColor = Colors.black38;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black26),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}
