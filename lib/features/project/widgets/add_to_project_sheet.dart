import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../materials/models/material_item.dart';
import '../models/project_item.dart';
import '../provider/project_provider.dart';
import '../../../core/theme/app_theme.dart';

/// Snackbar confirming a project change, with a shortcut to the project.
void showProjectSnack(BuildContext context, bool ok, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(ok ? message : 'Could not update your project. Please try again.'),
      action: ok ? SnackBarAction(label: 'View', onPressed: () => context.push('/project')) : null,
    ),
  );
}

/// Bottom sheet that asks which room a material goes in and how much area it
/// covers, then adds it to the user's project.
Future<void> showAddMaterialSheet(BuildContext context, MaterialItem material) async {
  final result = await showModalBottomSheet<({String room, int sqft})>(
    context: context,
    // Root navigator draws the sheet above the floating bottom nav bar.
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddMaterialSheet(material: material),
  );
  if (result == null || !context.mounted) return;
  final ok = await context.read<ProjectProvider>().addMaterial(
        id: material.id,
        name: material.name,
        room: result.room,
        sqft: result.sqft,
      );
  if (!context.mounted) return;
  showProjectSnack(context, ok, '${material.name} added to ${result.room}');
}

class _AddMaterialSheet extends StatefulWidget {
  final MaterialItem material;
  const _AddMaterialSheet({required this.material});

  @override
  State<_AddMaterialSheet> createState() => _AddMaterialSheetState();
}

class _AddMaterialSheetState extends State<_AddMaterialSheet> {
  late String room = _initialRoom();
  late int sqft = defaultSqftFor(room);

  String _initialRoom() {
    for (final r in projectRooms) {
      if (widget.material.bestIn.contains(r.name)) return r.name;
    }
    return projectRooms.first.name;
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.material;
    final cost = (priceMid(m.priceRange) * sqft).round();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 520),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(24)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(m.image, height: 44, width: 44, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Add to my project', style: AppTextStyles.display(fontSize: 18)),
                          Text(m.name, style: AppTextStyles.sans(fontSize: 12, color: AppColors.mutedForeground)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SheetLabel('Which room?'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: projectRooms.map((r) {
                    final active = r.name == room;
                    return GestureDetector(
                      onTap: () => setState(() {
                        room = r.name;
                        sqft = r.defaultSqft;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? AppColors.primary : AppColors.card,
                          border: active ? null : Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(r.name,
                            style: AppTextStyles.sans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: active ? AppColors.primaryForeground : AppColors.foreground)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _SheetLabel('Area to cover')),
                    Text('$sqft sqft', style: AppTextStyles.display(fontSize: 18)),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    thumbColor: AppColors.primary,
                    inactiveTrackColor: AppColors.border,
                    overlayColor: AppColors.primary.withValues(alpha: 0.15),
                  ),
                  child: Slider(
                    value: sqft.toDouble(),
                    min: 20,
                    max: 600,
                    divisions: 58,
                    onChanged: (v) => setState(() => sqft = v.round()),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('Material estimate · ${m.priceRange}',
                            style: AppTextStyles.sans(fontSize: 12, color: AppColors.mutedForeground)),
                      ),
                      Text('₹${formatInr(cost)}',
                          style: AppTextStyles.sans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.clay)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop((room: room, sqft: sqft)),
                    icon: const Icon(LucideIcons.plus, size: 16),
                    label: Text('Add to $room'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.primaryForeground,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      textStyle: AppTextStyles.sans(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  final String text;
  const _SheetLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(),
        style: AppTextStyles.sans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.clay, letterSpacing: 1.6));
  }
}
