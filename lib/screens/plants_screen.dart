import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../models/catalog.dart';
import '../theme/app_theme.dart';
import '../widgets/page_header.dart';

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
        const SizedBox(height: 20),
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
                                          if (p.petSafe) const AppChip(label: 'Pet safe', icon: LucideIcons.footprints),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: p.filters.take(2).map((f) => _FilterTag(label: f)).toList(),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(LucideIcons.sun, size: 12, color: AppColors.mutedForeground),
                                          const SizedBox(width: 4),
                                          Text(p.light,
                                              style: AppTextStyles.sans(fontSize: 11, color: AppColors.mutedForeground)),
                                          const SizedBox(width: 12),
                                          const Icon(LucideIcons.droplet, size: 12, color: AppColors.mutedForeground),
                                          const SizedBox(width: 4),
                                          Text(p.water,
                                              style: AppTextStyles.sans(fontSize: 11, color: AppColors.mutedForeground)),
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
