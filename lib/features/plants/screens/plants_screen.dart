import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../models/plant.dart';
import '../../favorites/provider/favorites_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/page_header.dart';

/// Ported from src/routes/plants.tsx
class PlantsScreen extends StatefulWidget {
  const PlantsScreen({super.key});

  @override
  State<PlantsScreen> createState() => _PlantsScreenState();
}

const _rooms = ['All', 'Bedroom', 'Living room', 'Study', 'Bathroom'];

class _PlantsScreenState extends State<PlantsScreen> {
  String room = 'All';

  @override
  Widget build(BuildContext context) {
    final filtered = room == 'All' ? plants : plants.where((p) => p.rooms.contains(room)).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Align(alignment: Alignment.centerLeft, child: AppBackButton()),
        ),
        const PageHeader(
          eyebrow: 'Air kit',
          title: 'Plants that clean your air',
          sub: 'Curated for Indian climates. Filter by room to see what thrives where.',
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _rooms.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final r = _rooms[i];
              final active = room == r;
              return GestureDetector(
                onTap: () => setState(() => room = r),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.card,
                    border: active ? null : Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(r,
                      style: AppTextStyles.sans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: active ? AppColors.primaryForeground : AppColors.foreground)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onTap: () => context.push('/air-kit'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(gradient: AppColors.gradientLeaf, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  const Icon(LucideIcons.sprout, size: 20, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Build my air kit', style: AppTextStyles.display(fontSize: 17, color: Colors.white)),
                        Text('Get a plant mix sized for your room',
                            style: AppTextStyles.sans(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                      ],
                    ),
                  ),
                  const Icon(LucideIcons.arrowUpRight, size: 18, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: filtered
                .map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CardSoft(
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Image.asset(p.image, height: 128, width: 112, fit: BoxFit.cover),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(p.name, style: AppTextStyles.display(fontSize: 18, height: 1.1)),
                                                Text(p.latin,
                                                    style: AppTextStyles.sans(
                                                        fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.mutedForeground)),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Consumer<FavoritesProvider>(
                                            builder: (context, favorites, _) {
                                              final isFav = favorites.isFavorite(p.id);
                                              return GestureDetector(
                                                onTap: () => favorites.toggle(
                                                  id: p.id,
                                                  type: 'plant',
                                                  name: p.name,
                                                ),
                                                child: Icon(
                                                  LucideIcons.heart,
                                                  size: 18,
                                                  color: isFav ? AppColors.clay : AppColors.mutedForeground,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: [
                                          if (p.petSafe) const AppChip(label: 'Pet safe', icon: LucideIcons.footprints),
                                          ...p.filters.take(2).map((f) => _FilterTag(label: f)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 4,
                                        children: [
                                          _Meta(icon: LucideIcons.sun, label: p.light),
                                          _Meta(icon: LucideIcons.droplet, label: p.water),
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
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Meta({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.mutedForeground),
        const SizedBox(width: 4),
        Flexible(child: Text(label, style: AppTextStyles.sans(fontSize: 11, color: AppColors.mutedForeground))),
      ],
    );
  }
}

class _FilterTag extends StatelessWidget {
  final String label;
  const _FilterTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(999)),
      child: Text(label,
          style: AppTextStyles.sans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.secondaryForeground)),
    );
  }
}
