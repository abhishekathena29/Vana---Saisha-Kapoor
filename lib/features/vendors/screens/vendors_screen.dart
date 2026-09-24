import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/page_header.dart';

/// Ported from src/routes/vendors.tsx
class VendorsScreen extends StatefulWidget {
  const VendorsScreen({super.key});

  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

const _cities = ['Delhi', 'Mumbai', 'Bengaluru', 'Pune', 'Chennai'];

class _Vendor {
  final int id;
  final String name;
  final String type;
  final String city;
  final String tier;
  final bool verified;
  final double rating;
  final int reviews;
  final List<String> tags;
  const _Vendor({
    required this.id,
    required this.name,
    required this.type,
    required this.city,
    required this.tier,
    required this.verified,
    required this.rating,
    required this.reviews,
    required this.tags,
  });
}

const _vendors = <_Vendor>[
  _Vendor(
    id: 1,
    name: 'Earthen Studio',
    type: 'Lime & clay finishes',
    city: 'Bengaluru',
    tier: 'Premium',
    verified: true,
    rating: 4.9,
    reviews: 42,
    tags: ['Lime plaster', 'Clay paint', 'Tadelakt'],
  ),
  _Vendor(
    id: 2,
    name: 'Bamboo India Co.',
    type: 'Manufacturer',
    city: 'Pune',
    tier: 'Mid',
    verified: true,
    rating: 4.7,
    reviews: 128,
    tags: ['Bamboo flooring', 'Panels', 'Furniture'],
  ),
  _Vendor(
    id: 3,
    name: 'Salvage & Sons',
    type: 'Reclaimed wood',
    city: 'Delhi',
    tier: 'Premium',
    verified: true,
    rating: 4.8,
    reviews: 67,
    tags: ['Teak', 'Sheesham', 'Doors'],
  ),
  _Vendor(
    id: 4,
    name: 'Green Roots Nursery',
    type: 'Plant nursery',
    city: 'Mumbai',
    tier: 'Budget',
    verified: false,
    rating: 4.5,
    reviews: 214,
    tags: ['Indoor plants', 'Air purifiers', 'Terracotta'],
  ),
];

class _VendorsScreenState extends State<VendorsScreen> {
  String city = 'Bengaluru';

  @override
  Widget build(BuildContext context) {
    final inCity = _vendors.where((v) => v.city == city).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        const PageHeader(
          eyebrow: 'Directory',
          title: 'Vetted vendors, not vibes',
          sub: 'Every listing verified with GSTIN, called by our team, rated by real projects.',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Icon(LucideIcons.mapPin, size: 16, color: AppColors.clay),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _cities.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final c = _cities[i];
                      final active = city == c;
                      return GestureDetector(
                        onTap: () => setState(() => city = c),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: active ? AppColors.primary : AppColors.card,
                            border: active ? null : Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(c,
                              style: AppTextStyles.sans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: active ? AppColors.primaryForeground : AppColors.foreground)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (inCity.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CardSoft(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(LucideIcons.mapPin, size: 18, color: AppColors.mutedForeground),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('We are still vetting vendors in $city. Check back soon.',
                        style: AppTextStyles.sans(fontSize: 13, color: AppColors.mutedForeground, height: 1.4)),
                  ),
                ],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: inCity
                .map((v) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CardSoft(
                        padding: const EdgeInsets.all(16),
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
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(v.name,
                                                style: AppTextStyles.display(fontSize: 18),
                                                overflow: TextOverflow.ellipsis),
                                          ),
                                          if (v.verified) ...[
                                            const SizedBox(width: 6),
                                            const Icon(LucideIcons.badgeCheck, size: 16, color: AppColors.leaf),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text('${v.type} · ${v.city}',
                                          style: AppTextStyles.sans(fontSize: 12, color: AppColors.mutedForeground)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(LucideIcons.star, size: 14, color: AppColors.clay),
                                        const SizedBox(width: 4),
                                        Text('${v.rating}',
                                            style: AppTextStyles.sans(fontSize: 14, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                    Text('${v.reviews} reviews',
                                        style: AppTextStyles.sans(fontSize: 10, color: AppColors.mutedForeground)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: v.tags
                                  .map((t) => Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                        decoration:
                                            BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(999)),
                                        child: Text(t,
                                            style: AppTextStyles.sans(
                                                fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.secondaryForeground)),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    const Icon(LucideIcons.shieldCheck, size: 12, color: AppColors.leaf),
                                    const SizedBox(width: 4),
                                    Text('${v.tier.toUpperCase()} TIER',
                                        style: AppTextStyles.sans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.mutedForeground,
                                            letterSpacing: 0.8)),
                                  ],
                                ),
                              ],
                            ),
                          ],
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
