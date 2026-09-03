import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../theme/app_theme.dart';
import '../widgets/page_header.dart';

/// Ported from src/routes/visualize.tsx
class VisualizeScreen extends StatefulWidget {
  const VisualizeScreen({super.key});

  @override
  State<VisualizeScreen> createState() => _VisualizeScreenState();
}

const _styles = ['Minimal', 'Warm-trad', 'Japandi', 'Biophilic', 'Maximalist'];
const _spaces = ['Living', 'Bedroom', 'Kitchen', 'Study'];
const _previewImages = [
  'assets/images/hero-living.jpg',
  'assets/images/story-bedroom.jpg',
  'assets/images/story-kitchen.jpg',
  'assets/images/hero-living.jpg',
];

class _VisualizeScreenState extends State<VisualizeScreen> {
  String style = 'Biophilic';
  String space = 'Living';
  final noteCtrl = TextEditingController(text: 'I want it to feel calm and earthy.');

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        const PageHeader(
          eyebrow: 'AI Studio',
          title: 'Visualize your dream room',
          sub: 'Pick a room, a style, and materials. We render four moodboards in seconds.',
        ),

        // Room
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Label('Room'),
              const SizedBox(height: 8),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _spaces.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final s = _spaces[i];
                    final active = space == s;
                    return _Pill(label: s, active: active, onTap: () => setState(() => space = s));
                  },
                ),
              ),
            ],
          ),
        ),

        // Style
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Label('Style'),
              const SizedBox(height: 8),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _styles.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final s = _styles[i];
                    final active = style == s;
                    return _Pill(
                      label: s,
                      active: active,
                      activeBg: AppColors.clay,
                      activeFg: AppColors.clayForeground,
                      onTap: () => setState(() => style = s),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Note
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Label('One line about the feel'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: noteCtrl,
                  maxLines: 2,
                  style: AppTextStyles.sans(fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Preview grid
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PREVIEW · 4 VARIATIONS',
                            style: AppTextStyles.sans(
                                fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.mutedForeground, letterSpacing: 1.2)),
                        const SizedBox(height: 2),
                        Text('$style ${space.toLowerCase()}', style: AppTextStyles.display(fontSize: 20)),
                      ],
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      color: AppColors.card,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.refreshCw, size: 16, color: AppColors.foreground),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _previewImages.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 4 / 5,
                ),
                itemBuilder: (context, i) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(_previewImages[i], fit: BoxFit.cover),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 10,
                          right: 10,
                          bottom: 10,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('V${i + 1}',
                                  style: AppTextStyles.sans(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text('Save',
                                    style: AppTextStyles.sans(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // CTA
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: AppColors.gradientLeaf, borderRadius: BorderRadius.circular(999), boxShadow: AppShadows.lift),
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.sparkles, size: 16, color: Colors.white),
                    label: Text('Generate 4 new moodboards',
                        style: AppTextStyles.sans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(LucideIcons.wand2, size: 16),
                      label: const Text('Adjust'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.foreground,
                        side: const BorderSide(color: AppColors.border),
                        backgroundColor: AppColors.card,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        textStyle: AppTextStyles.sans(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(LucideIcons.download, size: 16),
                      label: const Text('Download PDF'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.foreground,
                        side: const BorderSide(color: AppColors.border),
                        backgroundColor: AppColors.card,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        textStyle: AppTextStyles.sans(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'AI-generated inspirations, not architectural renders. Actual results depend on implementation.',
                textAlign: TextAlign.center,
                style: AppTextStyles.sans(fontSize: 11, color: AppColors.mutedForeground, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(),
        style: AppTextStyles.sans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.clay, letterSpacing: 1.8));
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color activeBg;
  final Color activeFg;

  const _Pill({
    required this.label,
    required this.active,
    required this.onTap,
    this.activeBg = AppColors.primary,
    this.activeFg = AppColors.primaryForeground,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? activeBg : AppColors.card,
          border: active ? null : Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label,
            style: AppTextStyles.sans(
                fontSize: 12, fontWeight: FontWeight.w600, color: active ? activeFg : AppColors.foreground)),
      ),
    );
  }
}
