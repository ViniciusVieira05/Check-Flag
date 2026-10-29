import 'dart:math';

import 'package:flutter/material.dart';

import 'imagem_bandeira.dart';

class AnimatedFlag extends StatefulWidget {
  final String asset;
  final bool? correct;

  const AnimatedFlag({super.key, required this.asset, this.correct});

  @override
  State<AnimatedFlag> createState() => _AnimatedFlagState();
}

class _AnimatedFlagState extends State<AnimatedFlag> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  @override
  void didUpdateWidget(covariant AnimatedFlag oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.correct == null && widget.correct != null) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: FlagImage(asset: widget.asset),
      builder: (context, child) {
        final t = _controller.value;

        if (widget.correct == true) {
          final scale = 1 + 0.15 * sin(pi * t);
          return Transform.scale(scale: scale, child: child);
        }

        if (widget.correct == false) {
          final offset = sin(t * pi * 6) * 12 * (1 - t);
          return Transform.translate(offset: Offset(offset, 0), child: child);
        }

        return child!;
      },
    );
  }
}
