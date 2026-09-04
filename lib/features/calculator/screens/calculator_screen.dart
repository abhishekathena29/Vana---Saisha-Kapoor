import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../provider/estimates_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/page_header.dart';

/// Ported from src/routes/calculator.tsx
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

const _spaces = ['Kitchen', 'Living', 'Bedroom', 'Bathroom', 'Full home'];

class _Option {
  final String id;
  final String name;
  final int price;
  const _Option(this.id, this.name, this.price);
}

const _flooringOptions = <_Option>[
  _Option('bamboo', 'Bamboo', 100),
  _Option('reclaimed', 'Reclaimed wood', 480),
  _Option('terracotta', 'Terracotta', 95),
  _Option('cork', 'Cork', 140),
];

const _wallOptions = <_Option>[
  _Option('lime', 'Lime plaster', 65),
  _Option('clay', 'Clay paint', 40),
  _Option('brick', 'Reclaimed brick', 220),
];

final _inr = NumberFormat.decimalPattern('en_IN');
String _fmt(num n) => _inr.format(n.round());

class _CalculatorScreenState extends State<CalculatorScreen> {
  String space = 'Living';
  int length = 14;
  int width = 16;
  _Option flooring = _flooringOptions[0];
  _Option wall = _wallOptions[0];
  int plantsCount = 4;

  late final lengthCtrl = TextEditingController(text: '$length');
  late final widthCtrl = TextEditingController(text: '$width');

  int get sqft => length * width;

  Future<void> _saveEstimate(num total) async {
    final estimates = context.read<EstimatesProvider>();
    final ok = await estimates.saveEstimate(
      space: space,
      sqft: sqft,
      flooring: flooring.name,
      wall: wall.name,
      plantsCount: plantsCount,
      total: total,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Estimate saved to your profile' : 'Could not save estimate. Please try again.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final floor = flooring.price * sqft;
    final walls = wall.price * (sqft * 0.6);
    final plantsCost = plantsCount * 950;
    final materialTotal = floor + walls + plantsCost;
    final labour = materialTotal * 0.35;
    final total = materialTotal + labour;
    final conventional = total * 1.22;

    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        const PageHeader(
          eyebrow: 'Estimator',
          title: 'What will your dream cost?',
          sub: 'Live, room-by-room pricing with labour built in.',
        ),

        // Space
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Label('1 · Space'),
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
                    return GestureDetector(
                      onTap: () => setState(() => space = s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? AppColors.primary : AppColors.card,
                          border: active ? null : Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(s,
                            style: AppTextStyles.sans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: active ? AppColors.primaryForeground : AppColors.foreground)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Dimensions
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Label('2 · Dimensions'),
              const SizedBox(height: 8),
              CardSoft(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _NumberField(
                            label: 'Length (ft)',
                            controller: lengthCtrl,
                            onChanged: (v) => setState(() => length = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _NumberField(
                            label: 'Width (ft)',
                            controller: widthCtrl,
                            onChanged: (v) => setState(() => width = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Area',
                              style: AppTextStyles.sans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.mutedForeground)),
                          Text('$sqft sqft', style: AppTextStyles.display(fontSize: 20)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Materials
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Label('3 · Materials'),
              const SizedBox(height: 8),
              CardSoft(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SubLabel('Flooring'),
                    const SizedBox(height: 8),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 2.6,
                      children: _flooringOptions
                          .map((o) => _PillPick(
                                active: flooring.id == o.id,
                                title: o.name,
                                sub: '₹${o.price}/sqft',
                                onTap: () => setState(() => flooring = o),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    _SubLabel('Walls'),
                    const SizedBox(height: 8),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.5,
                      children: _wallOptions
                          .map((o) => _PillPick(
                                active: wall.id == o.id,
                                title: o.name,
                                sub: '₹${o.price}',
                                onTap: () => setState(() => wall = o),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    _SubLabel('Plants'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.primary,
                              thumbColor: AppColors.primary,
                              inactiveTrackColor: AppColors.border,
                              overlayColor: AppColors.primary.withValues(alpha: 0.15),
                            ),
                            child: Slider(
                              value: plantsCount.toDouble(),
                              min: 0,
                              max: 12,
                              divisions: 12,
                              onChanged: (v) => setState(() => plantsCount = v.round()),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text('$plantsCount',
                              textAlign: TextAlign.right, style: AppTextStyles.display(fontSize: 18)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Result
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
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
                Text('$space · ESTIMATE',
                    style: AppTextStyles.sans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 2)),
                const SizedBox(height: 8),
                Text('₹${_fmt(total)}',
                    style: AppTextStyles.display(fontSize: 40, fontWeight: FontWeight.w600, color: Colors.white, height: 1)),
                const SizedBox(height: 4),
                Text('≈ ₹${_fmt(total / sqft)} per sqft · incl. labour',
                    style: AppTextStyles.sans(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
                const SizedBox(height: 20),
                _ResultRow('Flooring', floor),
                _ResultRow('Walls', walls),
                _ResultRow('Plants', plantsCost.toDouble()),
                _ResultRow('Labour (35%)', labour),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.trendingDown, size: 16, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: AppTextStyles.sans(fontSize: 12, color: Colors.white),
                            children: [
                              const TextSpan(text: 'Saves '),
                              TextSpan(
                                  text: '₹${_fmt(conventional - total)}',
                                  style: const TextStyle(fontWeight: FontWeight.w700)),
                              const TextSpan(text: ' vs conventional over 10 years'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Consumer<EstimatesProvider>(
                    builder: (context, estimates, _) {
                      final saving = estimates.saving;
                      return FilledButton.icon(
                        onPressed: saving ? null : () => _saveEstimate(total),
                        icon: saving
                            ? const SizedBox(
                                height: 14,
                                width: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.clayForeground),
                              )
                            : const Icon(LucideIcons.check, size: 16),
                        label: Text(saving ? 'Saving…' : 'Save estimate'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.clay,
                          foregroundColor: AppColors.clayForeground,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          textStyle: AppTextStyles.sans(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
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

class _SubLabel extends StatelessWidget {
  final String text;
  const _SubLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(),
        style: AppTextStyles.sans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.mutedForeground, letterSpacing: 1.2));
  }
}

class _NumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<int> onChanged;

  const _NumberField({required this.label, required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: AppTextStyles.sans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.mutedForeground, letterSpacing: 1)),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: AppTextStyles.display(fontSize: 22),
            decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.only(top: 4)),
            onChanged: (v) => onChanged(int.tryParse(v) ?? 0),
          ),
        ],
      ),
    );
  }
}

class _PillPick extends StatelessWidget {
  final bool active;
  final String title;
  final String sub;
  final VoidCallback onTap;

  const _PillPick({required this.active, required this.title, required this.sub, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withValues(alpha: 0.08) : AppColors.card,
          border: Border.all(color: active ? AppColors.primary : AppColors.border, width: active ? 1.5 : 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: AppTextStyles.sans(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(sub, style: AppTextStyles.sans(fontSize: 10, color: AppColors.mutedForeground)),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final num value;
  const _ResultRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.sans(fontSize: 14, color: Colors.white.withValues(alpha: 0.8))),
          Text('₹${_fmt(value)}',
              style: AppTextStyles.sans(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    );
  }
}
