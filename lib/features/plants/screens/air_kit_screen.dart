import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../models/plant.dart';
import '../../project/models/project_item.dart';
import '../../project/provider/project_provider.dart';
import '../../project/widgets/add_to_project_sheet.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/page_header.dart';

const _kitRooms = ['Bedroom', 'Living room', 'Study', 'Bathroom'];
const _lightLevels = ['Low', 'Medium', 'Bright'];

/// Roughly one air-purifying plant per 60 sqft of floor.
const _sqftPerPlant = 60;

/// Builds a plant kit for a room from its size, light and whether there are
/// pets, then lets the user tweak quantities and add it to their project.
class AirKitScreen extends StatefulWidget {
  const AirKitScreen({super.key});

  @override
  State<AirKitScreen> createState() => _AirKitScreenState();
}

class _AirKitScreenState extends State<AirKitScreen> {
  String room = 'Bedroom';
  String light = 'Medium';
  int sqft = 140;
  bool pets = false;

  /// Manual quantity overrides, keyed by plant id. Cleared when inputs change.
  final Map<String, int> _overrides = {};
  bool _adding = false;

  void _update(VoidCallback fn) => setState(() {
        fn();
        _overrides.clear();
      });

  int _score(Plant p) {
    var score = p.rooms.contains(room) ? 3 : 0;
    score += switch ((p.light, light)) {
      ('Low', _) => 2, // tolerates anything
      ('Bright indirect', 'Bright') => 2,
      ('Bright indirect', 'Medium') => 1,
      ('Bright indirect', 'Low') => -3,
      _ => 0,
    };
    score += 3 - p.care; // easier care ranks higher
    return score;
  }

  List<Plant> get _excludedForPets => pets ? plants.where((p) => !p.petSafe).toList() : const [];

  /// Suitable plants ranked best-first, each with a recommended quantity.
  List<({Plant plant, int qty})> get _kit {
    final eligible = plants.where((p) => !(pets && !p.petSafe) && _score(p) > 0).toList()
      ..sort((a, b) => _score(b).compareTo(_score(a)));
    if (eligible.isEmpty) return const [];

    final target = (sqft / _sqftPerPlant).ceil().clamp(1, 12);
    final weights = [for (var i = 0; i < eligible.length; i++) eligible.length - i];
    final weightSum = weights.fold(0, (a, b) => a + b);
    final qtys = [for (final w in weights) (target * w / weightSum).floor()];
    // Hand the rounding remainder to the best-ranked plants.
    for (var i = 0, left = target - qtys.fold(0, (a, b) => a + b); left > 0; i = (i + 1) % qtys.length, left--) {
      qtys[i]++;
    }
    return [
      for (var i = 0; i < eligible.length; i++) (plant: eligible[i], qty: _overrides[eligible[i].id] ?? qtys[i]),
    ];
  }

  Future<void> _addToProject(List<({Plant plant, int qty})> kit) async {
    setState(() => _adding = true);
    final project = context.read<ProjectProvider>();
    final ok = await project.addAll([
      for (final k in kit.where((k) => k.qty > 0))
        ProjectItem(
          id: ProjectItem.docId('plant', k.plant.id, room),
          type: 'plant',
          refId: k.plant.id,
          name: k.plant.name,
          room: room,
          quantity: k.qty,
        ),
    ]);
    if (!mounted) return;
    setState(() => _adding = false);
    showProjectSnack(context, ok, 'Air kit added to your $room');
  }

  @override
  Widget build(BuildContext context) {
    final kit = _kit;
    final totalPlants = kit.fold(0, (s, k) => s + k.qty);
    final totalCost = kit.fold(0, (s, k) => s + k.qty * k.plant.price);
    final toxins = {for (final k in kit.where((k) => k.qty > 0)) ...k.plant.filters}.toList();
    final excluded = _excludedForPets;

    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Align(alignment: Alignment.centerLeft, child: AppBackButton()),
        ),
        const PageHeader(
          eyebrow: 'Air kit',
          title: 'Build my air kit',
          sub: 'Tell us about the room. We pick plants that thrive there and clean its air.',
        ),

        // Inputs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: CardSoft(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Label('Room'),
                const SizedBox(height: 8),
                _PillWrap(options: _kitRooms, value: room, onChanged: (v) => _update(() => room = v)),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(child: _Label('Room size')),
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
                    min: 40,
                    max: 400,
                    divisions: 36,
                    onChanged: (v) => _update(() => sqft = v.round()),
                  ),
                ),
                const _Label('Natural light'),
                const SizedBox(height: 8),
                _PillWrap(options: _lightLevels, value: light, onChanged: (v) => _update(() => light = v)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(LucideIcons.pawPrint, size: 16, color: AppColors.clay),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Pets at home', style: AppTextStyles.sans(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                    Switch(
                      value: pets,
                      activeTrackColor: AppColors.primary,
                      onChanged: (v) => _update(() => pets = v),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Result
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text('Your $room kit', style: AppTextStyles.display(fontSize: 22, fontWeight: FontWeight.w600)),
              ),
              Text('$totalPlants plants',
                  style: AppTextStyles.sans(fontSize: 12, color: AppColors.mutedForeground, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (kit.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CardSoft(
              padding: const EdgeInsets.all(20),
              child: Text(
                'None of our plants suit this combination yet. Try more light, or turn off "Pets at home" '
                'if the plant can sit out of reach.',
                style: AppTextStyles.sans(fontSize: 13, color: AppColors.mutedForeground, height: 1.4),
              ),
            ),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                for (final k in kit)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _KitRow(
                      plant: k.plant,
                      qty: k.qty,
                      onChanged: (q) => setState(() => _overrides[k.plant.id] = q),
                    ),
                  ),
              ],
            ),
          ),
          if (excluded.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 10),
              child: Text(
                'Left out because they are toxic to pets: ${excluded.map((p) => p.name).join(', ')}.',
                style: AppTextStyles.sans(fontSize: 11.5, color: AppColors.mutedForeground, height: 1.4),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.gradientLeaf,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppShadows.lift,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('KIT TOTAL',
                      style: AppTextStyles.sans(
                          fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.7), letterSpacing: 2)),
                  const SizedBox(height: 6),
                  Text('₹${formatInr(totalCost)}',
                      style: AppTextStyles.display(fontSize: 34, color: Colors.white, height: 1)),
                  const SizedBox(height: 4),
                  Text('≈ 1 plant per $_sqftPerPlant sqft for noticeably fresher air',
                      style: AppTextStyles.sans(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                  if (toxins.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text('FILTERS',
                        style: AppTextStyles.sans(
                            fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.7), letterSpacing: 1.5)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: toxins
                          .map((t) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(999)),
                                child: Text(t, style: AppTextStyles.sans(fontSize: 11, color: Colors.white)),
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _adding || totalPlants == 0 ? null : () => _addToProject(kit),
                      icon: _adding
                          ? const SizedBox(
                              height: 14,
                              width: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.clayForeground),
                            )
                          : const Icon(LucideIcons.plus, size: 16),
                      label: Text(_adding ? 'Adding…' : 'Add kit to my project'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.clay,
                        foregroundColor: AppColors.clayForeground,
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
        ],
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () => context.push('/plants'),
            child: Text('Browse all plants',
                style: AppTextStyles.sans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ),
        ),
      ],
    );
  }
}

class _KitRow extends StatelessWidget {
  final Plant plant;
  final int qty;
  final ValueChanged<int> onChanged;
  const _KitRow({required this.plant, required this.qty, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CardSoft(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(plant.image, height: 64, width: 56, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plant.name, style: AppTextStyles.display(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('${plant.light} light · ${plant.water}',
                    style: AppTextStyles.sans(fontSize: 11, color: AppColors.mutedForeground), maxLines: 2),
                const SizedBox(height: 4),
                Text('₹${formatInr(plant.price)} each',
                    style: AppTextStyles.sans(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.clay)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(999)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: qty > 0 ? () => onChanged(qty - 1) : null,
                  icon: const Icon(LucideIcons.minus, size: 14),
                ),
                Text('$qty', style: AppTextStyles.sans(fontSize: 14, fontWeight: FontWeight.w700)),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: qty < 20 ? () => onChanged(qty + 1) : null,
                  icon: const Icon(LucideIcons.plus, size: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PillWrap extends StatelessWidget {
  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;
  const _PillWrap({required this.options, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((o) {
        final active = o == value;
        return GestureDetector(
          onTap: () => onChanged(o),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.card,
              border: active ? null : Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(o,
                style: AppTextStyles.sans(
                    fontSize: 12, fontWeight: FontWeight.w600, color: active ? AppColors.primaryForeground : AppColors.foreground)),
          ),
        );
      }).toList(),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(),
        style: AppTextStyles.sans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.clay, letterSpacing: 1.6));
  }
}
