import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/app_theme.dart';

class _Tab {
  final String path;
  final String label;
  final IconData icon;
  const _Tab(this.path, this.label, this.icon);
}

const _tabs = <_Tab>[
  _Tab('/', 'Home', LucideIcons.home),
  _Tab('/materials', 'Materials', LucideIcons.leaf),
  _Tab('/ai', 'AI', LucideIcons.bot),
  _Tab('/calculator', 'Cost', LucideIcons.calculator),
  _Tab('/vendors', 'Vendors', LucideIcons.store),
];

/// Ported from src/components/MobileShell.tsx.
/// Wraps every screen with a max-width mobile frame + floating bottom nav.
class MobileShell extends StatelessWidget {
  final Widget child;
  final String location;
  final ValueChanged<String> onNavigate;

  const MobileShell({
    super.key,
    required this.child,
    required this.location,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Stack(
            children: [
              // Keep content clear of the status bar / notch on every screen.
              Positioned.fill(
                child: SafeArea(bottom: false, child: child),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  minimum: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: _BottomNav(
                      location: location,
                      onNavigate: onNavigate,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final String location;
  final ValueChanged<String> onNavigate;

  const _BottomNav({required this.location, required this.onNavigate});

  bool _isActive(String path) {
    if (path == '/') return location == '/';
    return location.startsWith(path);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x593D2A17),
            blurRadius: 50,
            offset: Offset(0, 20),
            spreadRadius: -20,
          ),
        ],
      ),
      child: Row(
        children: _tabs.map((t) {
          final active = _isActive(t.path);
          return Expanded(
            child: GestureDetector(
              onTap: () => onNavigate(t.path),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      t.icon,
                      size: 18,
                      color: active
                          ? AppColors.primaryForeground
                          : AppColors.mutedForeground,
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        t.label,
                        maxLines: 1,
                        style: AppTextStyles.sans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: active
                              ? AppColors.primaryForeground
                              : AppColors.mutedForeground,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
