import 'package:flutter/material.dart';

/// The Vana leaf mark (assets/icon/icon.png), clipped into a rounded chip so
/// it reads as an app icon wherever it's dropped — including on dark or
/// photo backgrounds where the mark's own cream backdrop would otherwise
/// show as a stray square.
class AppIconBadge extends StatelessWidget {
  final double size;
  final double radius;

  const AppIconBadge({super.key, this.size = 40, double? radius}) : radius = radius ?? size * 0.26;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        'assets/icon/icon.png',
        height: size,
        width: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
