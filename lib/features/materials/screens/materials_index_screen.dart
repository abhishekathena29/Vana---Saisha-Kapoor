import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../models/material_item.dart' as catalog;
import '../../plants/models/plant.dart' as catalog;
import '../models/space_guide.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/leaf_score.dart';
import '../../../core/widgets/page_header.dart';

/// Ported from src/routes/materials.index.tsx
class MaterialsIndexScreen extends StatefulWidget {
  const MaterialsIndexScreen({super.key});

  @override
  State<MaterialsIndexScreen> createState() => _MaterialsIndexScreenState();
}

const _categories = ['All', 'Flooring', 'Walls', 'Ceiling', 'Furniture'];
const _sorts = [
  'Recommended',
  'Price: low to high',
  'Price: high to low',
  'Longest lasting',
];

class _MaterialsIndexScreenState extends State<MaterialsIndexScreen> {
  String active = 'All';
  String openSpace = spaces.first.id;
  final _searchCtrl = TextEditingController();
  String query = '';
  String sort = _sorts.first;
  bool zeroVocOnly = false;
  bool lowCarbonOnly = false;

  bool get _hasFilters => sort != _sorts.first || zeroVocOnly || lowCarbonOnly;

  List<catalog.MaterialItem> _applyFilters(List<catalog.MaterialItem> list) {
    final out = list
        .where((m) => !zeroVocOnly || m.voc == 'None')
        .where((m) => !lowCarbonOnly || m.carbon >= 5)
        .toList();
    int life(catalog.MaterialItem m) =>
        int.tryParse(RegExp(r'\d+').firstMatch(m.durability)?.group(0) ?? '') ??
        0;
    switch (sort) {
      case 'Price: low to high':
        out.sort(
          (a, b) =>
              _parsePriceMid(a.priceRange)
                  .compareTo(_parsePriceMid(b.priceRange)),
        );
      case 'Price: high to low':
        out.sort(
          (a, b) =>
              _parsePriceMid(b.priceRange)
                  .compareTo(_parsePriceMid(a.priceRange)),
        );
      case 'Longest lasting':
        out.sort((a, b) => life(b).compareTo(life(a)));
    }
    return out;
  }

  Future<void> _openFilters() async {
    await showModalBottomSheet<void>(
      context: context,
    // Root navigator draws the sheet above the floating bottom nav bar.
    useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheet) {
          void update(VoidCallback fn) {
            setState(fn);
            setSheet(() {});
          }

          return SafeArea(
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(24),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Sort & filter',
                            style: AppTextStyles.display(fontSize: 20),
                          ),
                        ),
                        if (_hasFilters)
                          TextButton(
                            onPressed: () => update(() {
                              sort = _sorts.first;
                              zeroVocOnly = false;
                              lowCarbonOnly = false;
                            }),
                            child: const Text('Reset'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'SORT BY',
                      style: AppTextStyles.sans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mutedForeground,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _sorts
                          .map(
                            (o) => _Pill(
                              label: o,
                              active: sort == o,
                              onTap: () => update(() => sort = o),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeTrackColor: AppColors.primary,
                      value: zeroVocOnly,
                      onChanged: (v) => update(() => zeroVocOnly = v),
                      title: Text(
                        'Zero-VOC only',
                        style: AppTextStyles.sans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Nothing off-gasses into your room',
                        style: AppTextStyles.sans(
                          fontSize: 12,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeTrackColor: AppColors.primary,
                      value: lowCarbonOnly,
                      onChanged: (v) => update(() => lowCarbonOnly = v),
                      title: Text(
                        'Top carbon score only',
                        style: AppTextStyles.sans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '5 of 5 leaves',
                        style: AppTextStyles.sans(
                          fontSize: 12,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.primaryForeground,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: const Text('Show results'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final byCategory = active == 'All'
        ? catalog.materials
        : catalog.materials.where((m) => m.category == active).toList();
    final q = query.trim().toLowerCase();
    final filtered = _applyFilters(
      q.isEmpty
          ? byCategory
          : byCategory
                .where(
                  (m) =>
                      m.name.toLowerCase().contains(q) ||
                      m.category.toLowerCase().contains(q),
                )
                .toList(),
    );
    final space = spaceById(openSpace);

    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        const PageHeader(
          eyebrow: 'Library',
          title: "Materials that don't cost the earth",
          sub: '80+ vetted materials with real project photos, honest pros and cons, and live pricing.',
        ),

        // Search bar
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 20),
        //   child: Container(
        //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        //     decoration: BoxDecoration(
        //       border: Border.all(color: AppColors.border),
        //       color: AppColors.card,
        //       borderRadius: BorderRadius.circular(999),
        //     ),
        //     child: Row(
        //       children: [
        //         const Icon(
        //           LucideIcons.search,
        //           size: 16,
        //           color: AppColors.mutedForeground,
        //         ),
        //         const SizedBox(width: 8),
        //         Expanded(
        //           child: TextField(
        //             controller: _searchCtrl,
        //             onChanged: (v) => setState(() => query = v),
        //             style: AppTextStyles.sans(fontSize: 14),
        //             decoration: InputDecoration(
        //               border: InputBorder.none,
        //               hintText: 'Search bamboo, cork, lime...',
        //               hintStyle: AppTextStyles.sans(
        //                 fontSize: 14,
        //                 color: AppColors.mutedForeground,
        //               ),
        //             ),
        //           ),
        //         ),
        //         if (query.isNotEmpty)
        //           GestureDetector(
        //             onTap: () => setState(() {
        //               _searchCtrl.clear();
        //               query = '';
        //             }),
        //             child: const Icon(
        //               LucideIcons.x,
        //               size: 16,
        //               color: AppColors.mutedForeground,
        //             ),
        //           )
        //         else
        //           GestureDetector(
        //             onTap: _openFilters,
        //             behavior: HitTestBehavior.opaque,
        //             child: Padding(
        //               padding: const EdgeInsets.all(6),
        //               child: Badge(
        //                 isLabelVisible: _hasFilters,
        //                 smallSize: 7,
        //                 backgroundColor: AppColors.primary,
        //                 child: const Icon(
        //                   LucideIcons.slidersHorizontal,
        //                   size: 16,
        //                   color: AppColors.clay,
        //                 ),
        //               ),
        //             ),
        //           ),
        //       ],
        //     ),
        //   ),
        // ),

        // // Redesign your space
        // const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REDESIGN YOUR SPACE',
                      style: AppTextStyles.sans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.clay,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Room-by-room, the sustainable way',
                      style: AppTextStyles.display(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${spaces.length} spaces',
                style: AppTextStyles.sans(
                  fontSize: 11,
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: spaces.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final s = spaces[i];
              final on = openSpace == s.id;
              return _Pill(
                label: s.name,
                active: on,
                activeBg: AppColors.foreground,
                activeFg: AppColors.background,
                onTap: () => setState(() => openSpace = s.id),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: _SpaceCard(space: space),
        ),

        // Category filter
        const SizedBox(height: 28),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final c = _categories[i];
              return _Pill(
                label: c,
                active: active == c,
                onTap: () => setState(() => active = c),
              );
            },
          ),
        ),

        // Materials grid
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
            child: Center(
              child: Text(
                query.isEmpty
                    ? 'No materials match these filters.'
                    : 'No materials match "$query".',
                style: AppTextStyles.sans(
                  fontSize: 13,
                  color: AppColors.mutedForeground,
                ),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 600 ? 3 : 2;
                final tileWidth =
                    (constraints.maxWidth - 12 * (columns - 1)) / columns;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    // Square image + text block that grows with the font size.
                    mainAxisExtent:
                        tileWidth + MediaQuery.textScalerOf(context).scale(96),
                  ),
                  itemBuilder: (context, i) {
                    final m = filtered[i];
                    return GestureDetector(
                      onTap: () => context.go('/materials/${m.id}'),
                      child: CardSoft(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: Image.asset(
                                    m.image,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  left: 8,
                                  top: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.background.withValues(
                                        alpha: 0.85,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      m.category.toUpperCase(),
                                      style: AppTextStyles.sans(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          m.name,
                                          style: AppTextStyles.display(
                                            fontSize: 15,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          m.priceRange,
                                          style: AppTextStyles.sans(
                                            fontSize: 11,
                                            color: AppColors.mutedForeground,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        LeafScore(score: m.carbon, size: 12),
                                        Flexible(
                                          child: Text(
                                            m.durability,
                                            style: AppTextStyles.sans(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.mutedForeground,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
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
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? activeBg : AppColors.card,
          border: active ? null : Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppTextStyles.sans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? activeFg : AppColors.foreground,
          ),
        ),
      ),
    );
  }
}

class _SpaceCard extends StatefulWidget {
  final SpaceGuide space;
  const _SpaceCard({required this.space});

  @override
  State<_SpaceCard> createState() => _SpaceCardState();
}

class _SpaceCardState extends State<_SpaceCard> {
  bool compare = false;

  @override
  void didUpdateWidget(covariant _SpaceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.space.id != widget.space.id) compare = false;
  }

  @override
  Widget build(BuildContext context) {
    final space = widget.space;
    final mats = space.materialIds.map(catalog.materialById).toList();
    final pls = space.plantIds
        .map(catalog.plantById)
        .whereType<catalog.Plant>()
        .toList();

    return CardSoft(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 192,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(space.image, fit: BoxFit.cover),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, const Color(0xBF291A0F)],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.sparkles,
                            size: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'REDESIGN GUIDE',
                            style: AppTextStyles.sans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.8),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        space.name,
                        style: AppTextStyles.display(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        space.tagline,
                        style: AppTextStyles.sans(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: space.palette
                          .map(
                            (c) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              height: 16,
                              width: 16,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white60),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'MOVE BY MOVE',
                        style: AppTextStyles.sans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mutedForeground,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => compare = !compare),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: compare
                              ? AppColors.foreground
                              : AppColors.card,
                          border: compare
                              ? null
                              : Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.gitCompare,
                              size: 12,
                              color: compare
                                  ? AppColors.background
                                  : AppColors.foreground,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              compare ? 'HIDE COMPARE' : 'COMPARE',
                              style: AppTextStyles.sans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: compare
                                    ? AppColors.background
                                    : AppColors.foreground,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...space.moves.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 20,
                          width: 20,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${e.key + 1}',
                              style: AppTextStyles.sans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: AppTextStyles.sans(
                                fontSize: 13,
                                height: 1.3,
                                color: AppColors.foreground,
                              ),
                              children: [
                                TextSpan(
                                  text: '${e.value.title}. ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: e.value.detail,
                                  style: TextStyle(
                                    color: AppColors.foreground.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Materials used
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppColors.border.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MATERIALS USED',
                        style: AppTextStyles.sans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mutedForeground,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: mats.map((m) {
                          return GestureDetector(
                            onTap: () => context.go('/materials/${m.id}'),
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 4,
                                right: 12,
                                top: 4,
                                bottom: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ClipOval(
                                    child: Image.asset(
                                      m.image,
                                      height: 28,
                                      width: 28,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          m.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.sans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          m.priceRange,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.sans(
                                            fontSize: 9,
                                            color: AppColors.mutedForeground,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                if (pls.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'PLANTS THAT BELONG HERE',
                    style: AppTextStyles.sans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mutedForeground,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: pls
                        .map(
                          (p) => Container(
                            padding: const EdgeInsets.only(
                              left: 4,
                              right: 12,
                              top: 4,
                              bottom: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClipOval(
                                  child: Image.asset(
                                    p.image,
                                    height: 28,
                                    width: 28,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.sans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${p.light} · ${p.water}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.sans(
                                          fontSize: 9,
                                          color: AppColors.mutedForeground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],

                _SpaceImpact(space: space, mats: mats, plantsCount: pls.length),
                if (compare)
                  _ComparePanel(
                    space: space,
                    mats: mats,
                    plantsCount: pls.length,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _roomArea = <String, int>{
  'living': 200,
  'bedroom': 140,
  'kitchen': 100,
  'bathroom': 60,
  'study': 100,
  'balcony': 80,
};

const _plantUnitCost = 800;
const _conventionalPerSqft = 320;

final _inr = NumberFormat.decimalPattern('en_IN');

String _fmtRupee(num n) => '₹${_inr.format(n.round())}';

double _parsePriceMid(String range) {
  final nums = RegExp(r'\d+(\.\d+)?')
      .allMatches(range)
      .map((m) => double.parse(m.group(0)!))
      .toList();
  if (nums.isEmpty) return 0;
  if (nums.length == 1) return nums[0];
  return (nums[0] + nums[1]) / 2;
}

class _SpaceImpact extends StatelessWidget {
  final SpaceGuide space;
  final List<catalog.MaterialItem> mats;
  final int plantsCount;
  const _SpaceImpact({
    required this.space,
    required this.mats,
    required this.plantsCount,
  });

  @override
  Widget build(BuildContext context) {
    final area = _roomArea[space.id] ?? 120;
    final perSqft = mats.isNotEmpty
        ? mats
                  .map((m) => _parsePriceMid(m.priceRange))
                  .reduce((a, b) => a + b) /
              mats.length
        : 0.0;
    final materialCost = (perSqft * area).round();
    final plantCost = plantsCount * _plantUnitCost;
    final labor = (materialCost * 0.35).round();
    final total = materialCost + labor + plantCost;
    final conventional = _conventionalPerSqft * area;
    final savings = (conventional - (materialCost + labor)).clamp(
      0,
      double.infinity,
    );

    final avgLeaf = mats.isNotEmpty
        ? mats.map((m) => m.carbon).reduce((a, b) => a + b) / mats.length
        : 0.0;
    final carbonPct =
        ((avgLeaf / 5) * 55 + (plantsCount > 3 ? 3 : plantsCount) * 4).round();
    final kgSaved = (area * 12 * (carbonPct / 100)).round();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'IMPACT FOR THIS REDESIGN',
                  style: AppTextStyles.sans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedForeground,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '~$area sqft · ${space.moves.length} moves',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.sans(
                    fontSize: 10,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.leaf,
                            size: 12,
                            color: AppColors.leaf,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'CARBON SAVED',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.sans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.leaf,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '$carbonPct%',
                          style: AppTextStyles.display(fontSize: 22, height: 1),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '~${_inr.format(kgSaved)} kg CO₂e avoided',
                        style: AppTextStyles.sans(
                          fontSize: 11,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EST. TOTAL COST',
                        style: AppTextStyles.sans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.clay,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _fmtRupee(total),
                          style: AppTextStyles.display(fontSize: 22, height: 1),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'vs ${_fmtRupee(conventional)} conventional',
                        style: AppTextStyles.sans(
                          fontSize: 11,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ImpactRow(
            label: 'Materials (${mats.length})',
            value: _fmtRupee(materialCost),
          ),
          _ImpactRow(label: 'Labour (35%)', value: _fmtRupee(labor)),
          _ImpactRow(
            label: 'Plants ($plantsCount × ${_fmtRupee(_plantUnitCost)})',
            value: _fmtRupee(plantCost),
          ),
          if (savings > 0)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.6),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'You save',
                    style: AppTextStyles.sans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.leaf,
                    ),
                  ),
                  Text(
                    _fmtRupee(savings),
                    style: AppTextStyles.sans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.leaf,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Estimates based on mid-range pricing for ${space.name.toLowerCase()}.',
                  style: AppTextStyles.sans(
                    fontSize: 10,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/calculator'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Refine',
                      style: AppTextStyles.sans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      LucideIcons.arrowRight,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImpactRow extends StatelessWidget {
  final String label;
  final String value;
  const _ImpactRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.sans(
                fontSize: 12,
                color: AppColors.mutedForeground,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: AppTextStyles.sans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

const _conventionalBySpace = <String, ({List<String> moves})>{
  'living': (
    moves: [
      'Vitrified tile flooring — high-fire, imported, cold underfoot.',
      'Two coats of acrylic emulsion — off-gasses VOCs for weeks.',
      'MDF-and-veneer coffee table — 6–8 year lifespan, formaldehyde glue.',
      'No plants — relies on synthetic air freshener.',
    ],
  ),
  'bedroom': (
    moves: [
      'Gypsum board + emulsion — traps humidity, off-gasses near the pillow.',
      'HDF laminate flooring — 8-year life, cannot be refinished.',
      'No bedside plants.',
      'Poly-blend bedding — micro-plastic shedding.',
    ],
  ),
  'kitchen': (
    moves: [
      'Vitrified tile — shows every chip, hard on knees.',
      'Imported granite counter — heavy carbon shipping footprint.',
      'Ceramic-tile backsplash — grout stains within a year.',
      'No trailing greenery.',
    ],
  ),
  'bathroom': (
    moves: [
      'Full ceramic tiling with grout — mould-prone joints to scrub.',
      'Glossy vitrified floor — slippery when wet.',
      'No plants — synthetic air freshener.',
    ],
  ),
  'study': (
    moves: [
      'MDF desk with printed veneer — sags within 5 years.',
      'Vinyl click-lock flooring — hard, echo-heavy.',
      'No plants in eye-line.',
    ],
  ),
  'balcony': (
    moves: [
      'Ceramic outdoor tile on new screed — demo + debris.',
      'Plastic planters bolted to the railing — brittle in 2 monsoons.',
      'Powder-coated steel bench — rusts at the welds.',
    ],
  ),
};

class _CompareRow {
  final String label;
  final String sust;
  final String conv;
  final String better; // 'sust' | 'conv'
  _CompareRow(this.label, this.sust, this.conv, this.better);
}

class _ComparePanel extends StatelessWidget {
  final SpaceGuide space;
  final List<catalog.MaterialItem> mats;
  final int plantsCount;
  const _ComparePanel({
    required this.space,
    required this.mats,
    required this.plantsCount,
  });

  @override
  Widget build(BuildContext context) {
    final area = _roomArea[space.id] ?? 120;
    final perSqft = mats.isNotEmpty
        ? mats
                  .map((m) => _parsePriceMid(m.priceRange))
                  .reduce((a, b) => a + b) /
              mats.length
        : 0.0;
    final sustMaterial = (perSqft * area).round();
    final sustPlants = plantsCount * _plantUnitCost;
    final sustLabor = (sustMaterial * 0.35).round();
    final sustTotal = sustMaterial + sustLabor + sustPlants;

    final convMaterial = _conventionalPerSqft * area;
    final convLabor = (convMaterial * 0.35).round();
    final convTotal = convMaterial + convLabor;

    final avgLeaf = mats.isNotEmpty
        ? mats.map((m) => m.carbon).reduce((a, b) => a + b) / mats.length
        : 0.0;
    final sustKg = (area * 12 * (1 - avgLeaf / 6)).round();
    final convKg = area * 12;

    final worstVoc = mats.any((m) => m.voc == 'Medium')
        ? 'Medium'
        : (mats.any((m) => m.voc == 'Low') ? 'Low' : 'None');

    int parseLife(String d) {
      final m = RegExp(r'\d+').firstMatch(d);
      return m != null ? int.parse(m.group(0)!) : 0;
    }

    final sustLife = mats.isNotEmpty
        ? (mats.map((m) => parseLife(m.durability)).reduce((a, b) => a + b) /
                  mats.length)
              .round()
        : 0;

    final conv = _conventionalBySpace[space.id] ?? (moves: <String>[]);

    final rows = <_CompareRow>[
      _CompareRow(
        'Est. total',
        _fmtRupee(sustTotal),
        _fmtRupee(convTotal),
        sustTotal <= convTotal ? 'sust' : 'conv',
      ),
      _CompareRow(
        'Per sqft',
        _fmtRupee((sustTotal / area).round()),
        _fmtRupee((convTotal / area).round()),
        sustTotal / area <= convTotal / area ? 'sust' : 'conv',
      ),
      _CompareRow(
        'CO₂e (kg)',
        _inr.format(sustKg),
        _inr.format(convKg),
        sustKg <= convKg ? 'sust' : 'conv',
      ),
      _CompareRow('VOC level', worstVoc, 'High', 'sust'),
      _CompareRow(
        'Avg lifespan',
        sustLife > 0 ? '$sustLife+ yrs' : '—',
        '8–12 yrs',
        'sust',
      ),
      _CompareRow('Plants', '$plantsCount', '0', 'sust'),
    ];

    return Container(
      margin: const EdgeInsets.only(top: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      border: Border(
                        right: BorderSide(
                          color: AppColors.border.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.check,
                              size: 12,
                              color: AppColors.leaf,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'YOUR REDESIGN',
                              style: AppTextStyles.sans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.leaf,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Sustainable',
                          style: AppTextStyles.display(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.x,
                              size: 12,
                              color: AppColors.mutedForeground,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'BASELINE',
                              style: AppTextStyles.sans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.mutedForeground,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Conventional',
                          style: AppTextStyles.display(
                            fontSize: 15,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.border.withValues(alpha: 0.7)),
          ...rows.map(
            (r) => Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Text(
                        r.label.toUpperCase(),
                        style: AppTextStyles.sans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mutedForeground,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: AppColors.border.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      child: Text(
                        r.sust,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.sans(
                          fontSize: 13,
                          fontWeight: r.better == 'sust'
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: r.better == 'sust'
                              ? AppColors.leaf
                              : AppColors.foreground,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: AppColors.border.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      child: Text(
                        r.conv,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.sans(
                          fontSize: 13,
                          fontWeight: r.better == 'conv'
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: r.better == 'conv'
                              ? AppColors.clay
                              : AppColors.mutedForeground,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.4),
              border: Border(
                top: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SAME MOVES, TWO WAYS',
                  style: AppTextStyles.sans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedForeground,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                ...space.moves.asMap().entries.map((e) {
                  final i = e.key;
                  final m = e.value;
                  final convDetail = i < conv.moves.length
                      ? conv.moves[i]
                      : 'Standard builder-grade spec.';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${i + 1} · ${m.title}',
                                  style: AppTextStyles.sans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.leaf,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  m.detail,
                                  style: AppTextStyles.sans(
                                    fontSize: 11.5,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${i + 1} · Conventional',
                                  style: AppTextStyles.sans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.mutedForeground,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  convDetail,
                                  style: AppTextStyles.sans(
                                    fontSize: 11.5,
                                    height: 1.3,
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
