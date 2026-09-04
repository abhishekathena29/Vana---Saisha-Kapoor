import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../auth/provider/auth_provider.dart';
import '../../favorites/provider/favorites_provider.dart';
import '../../calculator/provider/estimates_provider.dart';
import '../../visualize/provider/moodboards_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/page_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final favoritesCount = context.watch<FavoritesProvider>().ids.length;
    final estimates = context.watch<EstimatesProvider>().items;
    final moodboardsCount = context.watch<MoodboardsProvider>().items.length;

    final user = auth.currentUser;
    final name = auth.displayName;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        const PageHeader(eyebrow: 'Account', title: 'Your profile'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: CardSoft(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  height: 56,
                  width: 56,
                  decoration: const BoxDecoration(gradient: AppColors.gradientLeaf, shape: BoxShape.circle),
                  child: Center(
                    child: Text(initial, style: AppTextStyles.display(fontSize: 22, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTextStyles.display(fontSize: 18)),
                      const SizedBox(height: 2),
                      Text(user?.email ?? '', style: AppTextStyles.sans(fontSize: 12.5, color: AppColors.mutedForeground)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(child: _StatCard(icon: LucideIcons.heart, label: 'Favourites', value: '$favoritesCount')),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(icon: LucideIcons.calculator, label: 'Estimates', value: '${estimates.length}')),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(icon: LucideIcons.sparkles, label: 'Moodboards', value: '$moodboardsCount')),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('SAVED ESTIMATES',
              style: AppTextStyles.sans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.clay, letterSpacing: 1.5)),
        ),
        const SizedBox(height: 10),
        if (estimates.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('No saved estimates yet — build one from the Cost calculator.',
                style: AppTextStyles.sans(fontSize: 12.5, color: AppColors.mutedForeground)),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: estimates
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CardSoft(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${e['space']} · ${e['sqft']} sqft', style: AppTextStyles.sans(fontSize: 13.5, fontWeight: FontWeight.w600)),
                                    Text('${e['flooring']} floor · ${e['wall']} walls · ${e['plantsCount']} plants',
                                        style: AppTextStyles.sans(fontSize: 11, color: AppColors.mutedForeground)),
                                  ],
                                ),
                              ),
                              Text('₹${(e['total'] as num).round()}',
                                  style: AppTextStyles.sans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.clay)),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await context.read<AuthProvider>().signOut();
                if (context.mounted) context.go('/welcome');
              },
              icon: const Icon(LucideIcons.logOut, size: 16, color: AppColors.destructive),
              label: Text('Sign out', style: AppTextStyles.sans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.destructive)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.destructive),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return CardSoft(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      child: Column(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.display(fontSize: 18)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.sans(fontSize: 10.5, color: AppColors.mutedForeground), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
