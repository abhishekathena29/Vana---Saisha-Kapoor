import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../models/material_item.dart';
import '../../favorites/provider/favorites_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/leaf_score.dart';
import '../../../core/widgets/page_header.dart';

/// Ported from src/routes/materials.$id.tsx
class MaterialDetailScreen extends StatefulWidget {
  final String id;
  const MaterialDetailScreen({super.key, required this.id});

  @override
  State<MaterialDetailScreen> createState() => _MaterialDetailScreenState();
}

class _MaterialDetailScreenState extends State<MaterialDetailScreen> {
  String get id => widget.id;

  @override
  Widget build(BuildContext context) {
    MaterialItem? m;
    for (final mat in materials) {
      if (mat.id == id) m = mat;
    }
    if (m == null) {
      return ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
            child: Column(
              children: [
                Text('Material not found', style: AppTextStyles.display(fontSize: 22)),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => context.go('/materials'),
                  child: Text('Back to library',
                      style: AppTextStyles.sans(fontSize: 14, color: AppColors.primary)),
                ),
              ],
            ),
          ),
        ],
      );
    }
    final material = m;

    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        // Header image
        SizedBox(
          height: 380,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(m.image, fit: BoxFit.cover),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0x80291A0F),
                      Colors.transparent,
                      Colors.transparent,
                      const Color(0xBF291A0F),
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                top: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _RoundGlassButton(icon: LucideIcons.arrowLeft, onTap: () => context.go('/materials')),
                    Row(
                      children: [
                        Consumer<FavoritesProvider>(
                          builder: (context, favorites, _) {
                            final isFav = favorites.isFavorite(material.id);
                            return _RoundGlassButton(
                              icon: LucideIcons.heart,
                              iconColor: isFav ? AppColors.clay : AppColors.foreground,
                              onTap: () => favorites.toggle(
                                id: material.id,
                                type: 'material',
                                name: material.name,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        _RoundGlassButton(icon: LucideIcons.share2, onTap: () {}),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.category.toUpperCase(),
                          style: AppTextStyles.sans(
                              fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.8), letterSpacing: 1.4)),
                      const SizedBox(height: 4),
                      Text(m.name,
                          style: AppTextStyles.display(fontSize: 30, fontWeight: FontWeight.w600, color: Colors.white, height: 1.05)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Palette swatches
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              ...m.palette.map((c) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      height: 24,
                      width: 24,
                      decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: AppColors.border)),
                    ),
                  )),
              Text('Palette', style: AppTextStyles.sans(fontSize: 11, color: AppColors.mutedForeground)),
              const Spacer(),
              Text(m.priceRange, style: AppTextStyles.sans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.clay)),
            ],
          ),
        ),

        // Description
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Text(m.description,
              style: AppTextStyles.sans(fontSize: 15, height: 1.5, color: AppColors.foreground.withValues(alpha: 0.85))),
        ),

        // Spec cards
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              Expanded(child: _SpecCard(icon: LucideIcons.wind, label: 'Carbon', child: LeafScore(score: m.carbon, size: 12))),
              const SizedBox(width: 8),
              Expanded(
                  child: _SpecCard(
                      icon: LucideIcons.shieldCheck,
                      label: 'Lifespan',
                      child: Text(m.durability, style: AppTextStyles.sans(fontSize: 13, fontWeight: FontWeight.w600)))),
              const SizedBox(width: 8),
              Expanded(
                  child: _SpecCard(
                      icon: LucideIcons.droplet,
                      label: 'VOC',
                      child: Text(m.voc, style: AppTextStyles.sans(fontSize: 13, fontWeight: FontWeight.w600)))),
            ],
          ),
        ),

        // Pros / Cons
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CardSoft(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('LOVES',
                          style: AppTextStyles.sans(
                              fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.leaf, letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      ...m.pros.map((p) => _Bullet(text: p, color: AppColors.leaf)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CardSoft(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('WATCH OUT',
                          style: AppTextStyles.sans(
                              fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.clay, letterSpacing: 1.2)),
                      const SizedBox(height: 8),
                      ...m.cons.map((c) => _Bullet(text: c, color: AppColors.clay)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Best used in
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('BEST USED IN',
                  style: AppTextStyles.sans(
                      fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.mutedForeground, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: m.bestIn.map((r) => AppChip(label: r)).toList()),
            ],
          ),
        ),

        // Climate
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SUITED TO',
                  style: AppTextStyles.sans(
                      fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.mutedForeground, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: m.climate
                    .map((c) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text('$c climate', style: AppTextStyles.sans(fontSize: 12)),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),

        // CTA
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Add to my project'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryForeground,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    textStyle: AppTextStyles.sans(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.foreground,
                    side: const BorderSide(color: AppColors.border),
                    backgroundColor: AppColors.card,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: Text('Find vendors near me',
                      style: AppTextStyles.sans(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoundGlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  const _RoundGlassButton({
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(color: AppColors.background.withValues(alpha: 0.85), shape: BoxShape.circle),
        child: Icon(icon, size: 16, color: iconColor),
      ),
    );
  }
}

class _SpecCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;
  const _SpecCard({required this.icon, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return CardSoft(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.clay),
              const SizedBox(width: 6),
              Expanded(
                child: Text(label.toUpperCase(),
                    style: AppTextStyles.sans(
                        fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.mutedForeground, letterSpacing: 1),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  final Color color;
  const _Bullet({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(height: 4, width: 4, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTextStyles.sans(fontSize: 13))),
        ],
      ),
    );
  }
}
