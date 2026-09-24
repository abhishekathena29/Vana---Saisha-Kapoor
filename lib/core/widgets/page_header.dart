import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_theme.dart';

/// Round back button for pushed screens; falls back to [fallback] when there
/// is nothing to pop (e.g. the screen was opened with `context.go`).
class AppBackButton extends StatelessWidget {
  final String fallback;
  final bool glass;
  const AppBackButton({super.key, this.fallback = '/', this.glass = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.canPop() ? context.pop() : context.go(fallback),
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: glass ? AppColors.background.withValues(alpha: 0.85) : AppColors.card,
          shape: BoxShape.circle,
          border: glass ? null : Border.all(color: AppColors.border),
        ),
        child: const Icon(LucideIcons.arrowLeft, size: 16, color: AppColors.foreground),
      ),
    );
  }
}

/// Ported from PageHeader in src/components/MobileShell.tsx
class PageHeader extends StatelessWidget {
  final String? eyebrow;
  final String title;
  final String? sub;
  final Widget? child;

  const PageHeader({
    super.key,
    this.eyebrow,
    required this.title,
    this.sub,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eyebrow != null) ...[
            Text(
              eyebrow!.toUpperCase(),
              style: AppTextStyles.sans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.clay,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            title,
            style: AppTextStyles.display(
              fontSize: 34,
              fontWeight: FontWeight.w600,
              height: 1.05,
              letterSpacing: -0.6,
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                sub!,
                style: AppTextStyles.sans(
                  fontSize: 14,
                  color: AppColors.mutedForeground,
                  height: 1.4,
                ),
              ),
            ),
          ],
          if (child != null) child!,
        ],
      ),
    );
  }
}

/// Ported from the `.chip` utility class in src/styles.css
/// (named AppChip to avoid clashing with Flutter's built-in Chip widget)
class AppChip extends StatelessWidget {
  final String label;
  final IconData? icon;

  const AppChip({super.key, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.leaf.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.leaf.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: AppColors.primary),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.sans(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ported from the `.card-soft` utility class in src/styles.css
class CardSoft extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Clip clipBehavior;

  const CardSoft({
    super.key,
    required this.child,
    this.padding,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final content = padding != null ? Padding(padding: padding!, child: child) : child;
    return Container(
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: content,
    );
  }
}
