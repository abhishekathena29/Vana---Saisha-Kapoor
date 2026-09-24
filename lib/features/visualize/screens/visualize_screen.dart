import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../provider/moodboards_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/page_header.dart';

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
  final _noteFocus = FocusNode();
  final _scrollCtrl = ScrollController();
  List<String> previews = List.of(_previewImages);
  bool generating = false;
  bool savingAll = false;

  @override
  void dispose() {
    noteCtrl.dispose();
    _noteFocus.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  /// Prototype "render": reshuffles the preview set after a short delay.
  Future<void> _generate() async {
    if (generating) return;
    setState(() => generating = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      previews = List.of(previews)..shuffle(Random());
      generating = false;
    });
  }

  void _adjust() {
    _scrollCtrl.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    _noteFocus.requestFocus();
  }

  Future<void> _saveAll() async {
    setState(() => savingAll = true);
    final boards = context.read<MoodboardsProvider>();
    var ok = true;
    for (var i = 0; i < previews.length; i++) {
      ok = await boards.saveMoodboard(style: style, space: space, note: noteCtrl.text, variation: i + 1) && ok;
    }
    if (!mounted) return;
    setState(() => savingAll = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'All 4 moodboards saved to your profile' : 'Some moodboards could not be saved.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollCtrl,
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
                  focusNode: _noteFocus,
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
                  GestureDetector(
                    onTap: _generate,
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        color: AppColors.card,
                        shape: BoxShape.circle,
                      ),
                      child: generating
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            )
                          : const Icon(LucideIcons.refreshCw, size: 16, color: AppColors.foreground),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: previews.length,
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
                        AnimatedOpacity(
                          opacity: generating ? 0.35 : 1,
                          duration: const Duration(milliseconds: 250),
                          child: Image.asset(previews[i], fit: BoxFit.cover),
                        ),
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
                              GestureDetector(
                                onTap: () async {
                                  final ok = await context.read<MoodboardsProvider>().saveMoodboard(
                                        style: style,
                                        space: space,
                                        note: noteCtrl.text,
                                        variation: i + 1,
                                      );
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(ok
                                            ? 'Moodboard V${i + 1} saved to your profile'
                                            : 'Could not save moodboard. Please try again.')),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text('Save',
                                      style: AppTextStyles.sans(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                                ),
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
                    onPressed: generating ? null : _generate,
                    icon: const Icon(LucideIcons.sparkles, size: 16, color: Colors.white),
                    label: Text(generating ? 'Generating…' : 'Generate 4 new moodboards',
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
                      onPressed: _adjust,
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
                      onPressed: savingAll ? null : _saveAll,
                      icon: const Icon(LucideIcons.download, size: 16),
                      label: Text(savingAll ? 'Saving…' : 'Save all 4'),
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
