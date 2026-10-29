import 'package:flutter/material.dart';

class FlagImage extends StatelessWidget {
  final String asset;
  final double? width;
  final double? height;

  const FlagImage({super.key, required this.asset, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
      child: Image.asset(
        asset,
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) => SizedBox(
          width: width,
          height: height,
          child: const Icon(Icons.flag),
        ),
      ),
    );
  }
}
