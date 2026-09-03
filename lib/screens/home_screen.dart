import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../models/catalog.dart';
import '../theme/app_theme.dart';
import '../widgets/leaf_score.dart';
import '../widgets/page_header.dart';

/// Ported from src/routes/index.tsx
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VANA',
                    style: AppTextStyles.sans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.clay,
                      letterSpacing: 2.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('Namaste, Aarav',
                      style: AppTextStyles.sans(fontSize: 14, color: AppColors.mutedForeground)),
                ],
              ),
              const Spacer(),
              _RoundIconButton(icon: LucideIcons.search, onTap: () {}),
              const SizedBox(width: 8),
              _RoundIconButton(icon: LucideIcons.bell, onTap: () {}, showDot: true),
            ],
          ),
        ),

        // Hero
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(boxShadow: AppShadows.lift),
                  child: Image.asset(
                    'assets/images/hero-living.jpg',
                    height: 440,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(decoration: const BoxDecoration(gradient: AppColors.gradientHero)),
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.sparkles, size: 12, color: Colors.white),
                              const SizedBox(width: 6),
                              Text('DESIGN STORY',
                                  style: AppTextStyles.sans(
                                      fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.2)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'A Delhi flat that breathes with the seasons',
                          style: AppTextStyles.display(
                              fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white, height: 1.05),
                        ),
                        const SizedBox(height: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 260),
                          child: Text(
                            'Bamboo floors, lime walls and 14 air-purifying plants for 620 sqft.',
                            style: AppTextStyles.sans(fontSize: 13, color: Colors.white.withValues(alpha: 0.85), height: 1.4),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _GlassPill(label: '₹4.2L estimated'),
                            const SizedBox(width: 8),
                            _GlassPill(label: '−38% CO₂'),
                            const Spacer(),
                            Container(
                              height: 40,
                              width: 40,
                              decoration: const BoxDecoration(color: AppColors.clay, shape: BoxShape.circle),
                              child: const Icon(LucideIcons.arrowUpRight, size: 18, color: AppColors.clayForeground),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Quick actions
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: _QuickAction(
                  gradient: AppColors.gradientLeaf,
                  icon: LucideIcons.sparkles,
                  title: 'Visualize\nmy space',
                  subtitle: 'AI moodboards',
                  onTap: () => context.go('/visualize'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  gradient: AppColors.gradientClay,
                  icon: LucideIcons.wind,
                  title: 'Cost\ncalculator',
                  subtitle: 'Room-by-room',
                  onTap: () => context.go('/calculator'),
                  foreground: AppColors.clayForeground,
                ),
              ),
            ],
          ),
        ),

        // Featured materials
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('THIS WEEK',
                        style: AppTextStyles.sans(
                            fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.clay, letterSpacing: 1.8)),
                    const SizedBox(height: 4),
                    Text('Featured materials', style: AppTextStyles.display(fontSize: 22, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/materials'),
                child: Text('See all',
                    style: AppTextStyles.sans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: materials.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final m = materials[i];
              return GestureDetector(
                onTap: () => context.go('/materials/${m.id}'),
                child: SizedBox(
                  width: 220,
                  child: CardSoft(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(m.image, height: 128, width: double.infinity, fit: BoxFit.cover),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.category.toUpperCase(),
                                  style: AppTextStyles.sans(
                                      fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.mutedForeground, letterSpacing: 1.2)),
                              const SizedBox(height: 3),
                              Text(m.name, style: AppTextStyles.display(fontSize: 17), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  LeafScore(score: m.carbon),
                                  Text(m.priceRange.split(' ').first,
                                      style: AppTextStyles.sans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.clay)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Plants strip
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AIR KIT',
                            style: AppTextStyles.sans(
                                fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.clay, letterSpacing: 1.8)),
                        const SizedBox(height: 4),
                        Text('Plants for your bedroom', style: AppTextStyles.display(fontSize: 22, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const AppChip(label: 'Filters 4 toxins'),
                ],
              ),
              const SizedBox(height: 12),
              CardSoft(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: plants
                          .map((p) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: AspectRatio(
                                          aspectRatio: 4 / 5,
                                          child: Image.asset(p.image, fit: BoxFit.cover),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(p.name,
                                          textAlign: TextAlign.center,
                                          style: AppTextStyles.display(fontSize: 13),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      Text(p.light,
                                          style: AppTextStyles.sans(fontSize: 10, color: AppColors.mutedForeground)),
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.primaryForeground,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        ),
                        child: Text('Build my air kit →',
                            style: AppTextStyles.sans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryForeground)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Design stories
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(child: Text('Design stories', style: AppTextStyles.display(fontSize: 22, fontWeight: FontWeight.w600))),
              Text('2 new', style: AppTextStyles.sans(fontSize: 12, color: AppColors.mutedForeground)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _StoryCard(
                image: 'assets/images/story-bedroom.jpg',
                tag: 'Bedroom · Pune',
                title: 'The 100-year-old teak bed that anchors a modern room',
                meta: '6 min read',
              ),
              const SizedBox(height: 12),
              _StoryCard(
                image: 'assets/images/story-kitchen.jpg',
                tag: 'Kitchen · Bengaluru',
                title: 'A bamboo kitchen that grows its own herbs',
                meta: 'Before & After',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool showDot;
  const _RoundIconButton({required this.icon, required this.onTap, this.showDot = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: AppColors.card,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.foreground),
            if (showDot)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  height: 6,
                  width: 6,
                  decoration: const BoxDecoration(color: AppColors.clay, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  final String label;
  const _GlassPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: AppTextStyles.sans(fontSize: 12, color: Colors.white)),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final Gradient gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color foreground;

  const _QuickAction({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.foreground = AppColors.primaryForeground,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 148,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: gradient),
        child: Stack(
          children: [
            Icon(icon, size: 20, color: foreground),
            Positioned(
              right: 0,
              top: 0,
              child: Icon(LucideIcons.arrowUpRight, size: 16, color: foreground.withValues(alpha: 0.6)),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.display(fontSize: 20, fontWeight: FontWeight.w600, color: foreground, height: 1.1)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.sans(fontSize: 11, color: foreground.withValues(alpha: 0.8))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final String image;
  final String tag;
  final String title;
  final String meta;

  const _StoryCard({required this.image, required this.tag, required this.title, required this.meta});

  @override
  Widget build(BuildContext context) {
    return CardSoft(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.asset(image, height: 192, width: double.infinity, fit: BoxFit.cover),
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(tag.toUpperCase(),
                      style: AppTextStyles.sans(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.1)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.display(fontSize: 18, height: 1.25)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(meta, style: AppTextStyles.sans(fontSize: 11, color: AppColors.mutedForeground)),
                    const Icon(LucideIcons.arrowUpRight, size: 16, color: AppColors.clay),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
