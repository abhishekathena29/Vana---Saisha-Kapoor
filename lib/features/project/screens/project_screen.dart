import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../models/project_item.dart';
import '../provider/project_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/page_header.dart';

/// Everything the user has added to their project, grouped by room, with a
/// running cost estimate.
class ProjectScreen extends StatelessWidget {
  const ProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final project = context.watch<ProjectProvider>();
    final items = project.items;

    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Align(alignment: Alignment.centerLeft, child: AppBackButton(fallback: '/profile')),
        ),
        const PageHeader(
          eyebrow: 'My project',
          title: 'Your sustainable plan',
          sub: 'Materials and plants you have picked, room by room, with a live estimate.',
        ),
        if (items.isEmpty)
          const _EmptyProject()
        else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _SummaryCard(project: project),
          ),
          for (final room in project.rooms) ...[
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(room, style: AppTextStyles.display(fontSize: 20, fontWeight: FontWeight.w600)),
                  ),
                  Text(
                    '₹${formatInr(project.itemsFor(room).fold(0, (s, i) => s + i.cost))}',
                    style: AppTextStyles.sans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.mutedForeground),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: project
                    .itemsFor(room)
                    .map((i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ItemRow(item: i),
                        ))
                    .toList(),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _GhostButton(icon: LucideIcons.plus, label: 'Add materials', onTap: () => context.go('/materials')),
                _GhostButton(icon: LucideIcons.sprout, label: 'Build an air kit', onTap: () => context.push('/air-kit')),
                _GhostButton(icon: LucideIcons.trash2, label: 'Clear project', onTap: () => _confirmClear(context, project)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _confirmClear(BuildContext context, ProjectProvider project) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Clear your project?', style: AppTextStyles.display(fontSize: 20)),
        content: Text('This removes all ${project.items.length} items. It cannot be undone.',
            style: AppTextStyles.sans(fontSize: 13, color: AppColors.mutedForeground)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Clear', style: AppTextStyles.sans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.destructive)),
          ),
        ],
      ),
    );
    if (yes == true) await project.remove(project.items.map((i) => i.id).toList());
  }
}

class _SummaryCard extends StatelessWidget {
  final ProjectProvider project;
  const _SummaryCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final materialsCount = project.items.where((i) => i.isMaterial).length;
    final plantsCount = project.items.where((i) => !i.isMaterial).fold(0, (s, i) => s + i.quantity);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.gradientLeaf,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.lift,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ESTIMATED TOTAL',
              style: AppTextStyles.sans(
                  fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.7), letterSpacing: 2)),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text('₹${formatInr(project.totalCost)}',
                style: AppTextStyles.display(fontSize: 38, fontWeight: FontWeight.w600, color: Colors.white, height: 1)),
          ),
          const SizedBox(height: 6),
          Text(
            '${project.rooms.length} ${project.rooms.length == 1 ? 'room' : 'rooms'} · '
            '$materialsCount ${materialsCount == 1 ? 'material' : 'materials'} · $plantsCount plants',
            style: AppTextStyles.sans(fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 16),
          _WhiteRow('Materials & plants', project.materialsCost),
          _WhiteRow('Labour (35% of materials)', project.labourCost),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => context.go('/calculator'),
              icon: const Icon(LucideIcons.calculator, size: 16),
              label: const Text('Refine in cost calculator'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.clay,
                foregroundColor: AppColors.clayForeground,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                textStyle: AppTextStyles.sans(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhiteRow extends StatelessWidget {
  final String label;
  final int value;
  const _WhiteRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.sans(fontSize: 13, color: Colors.white.withValues(alpha: 0.8)))),
          Text('₹${formatInr(value)}', style: AppTextStyles.sans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final ProjectItem item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final project = context.read<ProjectProvider>();
    final detail = item.isMaterial
        ? '${item.sqft} sqft · ${item.material?.priceRange ?? ''}'
        : '₹${formatInr(item.plant?.price ?? 0)} each';

    return CardSoft(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => item.isMaterial ? context.push('/materials/${item.refId}') : context.push('/plants'),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: item.image.isEmpty
                  ? Container(height: 56, width: 56, color: AppColors.secondary)
                  : Image.asset(item.image, height: 56, width: 56, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: AppTextStyles.sans(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(detail,
                    style: AppTextStyles.sans(fontSize: 11, color: AppColors.mutedForeground), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text('₹${formatInr(item.cost)}',
                    style: AppTextStyles.sans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.clay)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (item.isMaterial)
            _Stepper(
              value: '${item.sqft}',
              onMinus: item.sqft > 10 ? () => project.update(item, sqft: item.sqft - 10) : null,
              onPlus: () => project.update(item, sqft: item.sqft + 10),
            )
          else
            _Stepper(
              value: '×${item.quantity}',
              onMinus: item.quantity > 1 ? () => project.update(item, quantity: item.quantity - 1) : null,
              onPlus: () => project.update(item, quantity: item.quantity + 1),
            ),
          IconButton(
            tooltip: 'Remove',
            visualDensity: VisualDensity.compact,
            onPressed: () => project.remove([item.id]),
            icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.mutedForeground),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final String value;
  final VoidCallback? onMinus;
  final VoidCallback onPlus;
  const _Stepper({required this.value, required this.onMinus, required this.onPlus});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(icon: LucideIcons.minus, onTap: onMinus),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 28),
            child: Text(value, textAlign: TextAlign.center, style: AppTextStyles.sans(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          _StepButton(icon: LucideIcons.plus, onTap: onPlus),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 12, color: onTap == null ? AppColors.border : AppColors.foreground),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _GhostButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.foreground,
        side: const BorderSide(color: AppColors.border),
        backgroundColor: AppColors.card,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: AppTextStyles.sans(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EmptyProject extends StatelessWidget {
  const _EmptyProject();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: CardSoft(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), shape: BoxShape.circle),
              child: const Icon(LucideIcons.clipboardList, size: 22, color: AppColors.primary),
            ),
            const SizedBox(height: 14),
            Text('Nothing here yet', style: AppTextStyles.display(fontSize: 19)),
            const SizedBox(height: 6),
            Text(
              'Tap "Add to my project" on any material, or build an air kit, to start planning.',
              textAlign: TextAlign.center,
              style: AppTextStyles.sans(fontSize: 13, color: AppColors.mutedForeground, height: 1.4),
            ),
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                _GhostButton(icon: LucideIcons.leaf, label: 'Browse materials', onTap: () => context.go('/materials')),
                _GhostButton(icon: LucideIcons.sprout, label: 'Build an air kit', onTap: () => context.push('/air-kit')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
