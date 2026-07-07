import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  static const String assetPath = 'assets/venuscrm.png';

  final double size;
  final BoxFit fit;
  final EdgeInsetsGeometry? padding;
  final Decoration? decoration;

  const AppLogo({
    super.key,
    this.size = 80,
    this.fit = BoxFit.contain,
    this.padding,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: fit,
    );

    if (decoration == null && padding == null) return image;

    return Container(
      padding: padding,
      decoration: decoration,
      child: image,
    );
  }
}
