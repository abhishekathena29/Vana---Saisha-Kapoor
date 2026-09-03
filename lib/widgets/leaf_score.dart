import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

/// Ported from LeafScore in src/components/MobileShell.tsx
class LeafScore extends StatelessWidget {
  final int score;
  final double size;

  const LeafScore({super.key, required this.score, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Carbon score $score of 5',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (i) {
          final filled = i < score;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.5),
            child: Icon(
              LucideIcons.leaf,
              size: size,
              color: filled ? AppColors.leaf : AppColors.border,
            ),
          );
        }),
      ),
    );
  }
}
