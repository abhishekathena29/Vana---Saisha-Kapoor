import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../models/design_story.dart';
import '../../materials/models/material_item.dart';
import '../../plants/models/plant.dart';
import '../../project/models/project_item.dart';
import '../../project/provider/project_provider.dart';
import '../../project/widgets/add_to_project_sheet.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/page_header.dart';

/// Full-page reader for a [DesignStory].
class StoryScreen extends StatelessWidget {
  final String id;
  const StoryScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final story = storyById(id);
    if (story == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Story not found', style: AppTextStyles.display(fontSize: 22)),
            const SizedBox(height: 12),
            TextButton(onPressed: () => context.go('/'), child: const Text('Back home')),
          ],
        ),
      );
    }
    final mats = story.materialIds.map(materialById).toList();
    final pls = story.plantIds.map(plantById).whereType<Plant>().toList();
    final more = designStories.where((s) => s.id != story.id).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        // Cover
        AspectRatio(
          aspectRatio: 4 / 5,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(story.image, fit: BoxFit.cover),
              const DecoratedBox(decoration: BoxDecoration(gradient: AppColors.gradientHero)),
              Positioned(
                left: 16,
                right: 16,
                top: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppBackButton(glass: true),
                    GestureDetector(
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: '${story.title} — ${story.subtitle}\nRead it on Vana.'));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Story link copied to clipboard')));
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration:
                            BoxDecoration(color: AppColors.background.withValues(alpha: 0.85), shape: BoxShape.circle),
                        child: const Icon(LucideIcons.share2, size: 16, color: AppColors.foreground),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(story.tag.toUpperCase(),
                        style: AppTextStyles.sans(
                            fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.85), letterSpacing: 1.4)),
                    const SizedBox(height: 8),
                    Text(story.title,
                        style: AppTextStyles.display(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white, height: 1.08)),
                    const SizedBox(height: 8),
                    Text(story.subtitle,
                        style: AppTextStyles.sans(fontSize: 13, color: Colors.white.withValues(alpha: 0.85), height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Stats
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              Expanded(child: _Stat(label: 'Budget', value: story.budget)),
              const SizedBox(width: 8),
              Expanded(child: _Stat(label: 'Area', value: story.area)),
              const SizedBox(width: 8),
              Expanded(child: _Stat(label: 'CO₂', value: story.carbonCut, color: AppColors.leaf)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              const Icon(LucideIcons.bookOpen, size: 14, color: AppColors.mutedForeground),
              const SizedBox(width: 6),
              Expanded(
                child: Text('${story.author} · ${story.meta}',
                    style: AppTextStyles.sans(fontSize: 12, color: AppColors.mutedForeground)),
              ),
            ],
          ),
        ),

        // Body
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Text(story.intro,
              style: AppTextStyles.sans(fontSize: 16, height: 1.55, fontWeight: FontWeight.w500)),
        ),
        for (final s in story.sections)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.heading, style: AppTextStyles.display(fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(s.body,
                    style: AppTextStyles.sans(fontSize: 14.5, height: 1.55, color: AppColors.foreground.withValues(alpha: 0.85))),
              ],
            ),
          ),

        // Quote
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(LucideIcons.quote, size: 18, color: AppColors.clay),
                const SizedBox(height: 8),
                Text(story.quote, style: AppTextStyles.display(fontSize: 19, height: 1.3)),
                const SizedBox(height: 8),
                Text('— ${story.quoteBy}', style: AppTextStyles.sans(fontSize: 12, color: AppColors.mutedForeground)),
              ],
            ),
          ),
        ),

        // Before / after
        const SizedBox(height: 28),
        const _SectionTitle(eyebrow: 'The swap', title: 'Before & after'),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: CardSoft(
            child: Column(
              children: [
                for (var i = 0; i < story.changes.length; i++)
                  Container(
                    decoration: BoxDecoration(
                      border: i == 0 ? null : Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.6))),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(story.changes[i].$1,
                              style: AppTextStyles.sans(
                                  fontSize: 12.5,
                                  color: AppColors.mutedForeground,
                                  height: 1.35,
                                  fontStyle: FontStyle.italic)),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(LucideIcons.arrowRight, size: 14, color: AppColors.clay),
                        ),
                        Expanded(
                          child: Text(story.changes[i].$2,
                              style: AppTextStyles.sans(fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.35)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Materials
        const SizedBox(height: 28),
        const _SectionTitle(eyebrow: 'Shop the look', title: 'Materials in this home'),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              for (final m in mats)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => context.push('/materials/${m.id}'),
                    child: CardSoft(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(m.image, height: 56, width: 56, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.name, style: AppTextStyles.display(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text('${m.category} · ${m.priceRange}',
                                    style: AppTextStyles.sans(fontSize: 11, color: AppColors.mutedForeground)),
                              ],
                            ),
                          ),
                          const Icon(LucideIcons.arrowUpRight, size: 16, color: AppColors.clay),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (pls.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: pls
                  .map((p) => GestureDetector(
                        onTap: () => context.push('/plants'),
                        child: AppChip(label: p.name, icon: LucideIcons.sprout),
                      ))
                  .toList(),
            ),
          ),

        // CTA
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _addLook(context, story, mats),
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: Text('Add this look to my ${story.room.toLowerCase()}'),
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
                  onPressed: () => context.go('/calculator'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.foreground,
                    side: const BorderSide(color: AppColors.border),
                    backgroundColor: AppColors.card,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: Text('Estimate a room like this',
                      style: AppTextStyles.sans(fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),

        // More stories
        const SizedBox(height: 32),
        const _SectionTitle(eyebrow: 'Keep reading', title: 'More stories'),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              for (final s in more)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => context.pushReplacement('/stories/${s.id}'),
                    child: CardSoft(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.asset(s.image, height: 64, width: 64, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.tag.toUpperCase(),
                                    style: AppTextStyles.sans(
                                        fontSize: 9.5, fontWeight: FontWeight.w600, color: AppColors.mutedForeground, letterSpacing: 1)),
                                const SizedBox(height: 2),
                                Text(s.title,
                                    style: AppTextStyles.display(fontSize: 15, height: 1.2),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _addLook(BuildContext context, DesignStory story, List<MaterialItem> mats) async {
    final sqft = defaultSqftFor(story.room);
    final ok = await context.read<ProjectProvider>().addAll([
      for (final m in mats)
        ProjectItem(
          id: ProjectItem.docId('material', m.id, story.room),
          type: 'material',
          refId: m.id,
          name: m.name,
          room: story.room,
          sqft: sqft,
        ),
    ]);
    if (!context.mounted) return;
    showProjectSnack(context, ok, '${mats.length} materials added to your ${story.room.toLowerCase()}');
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Stat({required this.label, required this.value, this.color = AppColors.foreground});

  @override
  Widget build(BuildContext context) {
    return CardSoft(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: AppTextStyles.display(fontSize: 18, color: color)),
          ),
          const SizedBox(height: 2),
          Text(label.toUpperCase(),
              style: AppTextStyles.sans(fontSize: 9.5, fontWeight: FontWeight.w600, color: AppColors.mutedForeground, letterSpacing: 1)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String eyebrow;
  final String title;
  const _SectionTitle({required this.eyebrow, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow.toUpperCase(),
              style: AppTextStyles.sans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.clay, letterSpacing: 1.8)),
          const SizedBox(height: 4),
          Text(title, style: AppTextStyles.display(fontSize: 22, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
