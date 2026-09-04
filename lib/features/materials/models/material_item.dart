import 'package:flutter/material.dart';

/// Ported 1:1 from src/lib/catalog.ts
class MaterialItem {
  final String id;
  final String name;
  final String category;
  final String image;
  final int carbon; // 1 low - 5 high
  final String priceRange;
  final String durability;
  final List<String> climate;
  final String voc; // "None" | "Low" | "Medium"
  final String description;
  final List<String> pros;
  final List<String> cons;
  final List<String> bestIn;
  final List<Color> palette;

  const MaterialItem({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.carbon,
    required this.priceRange,
    required this.durability,
    required this.climate,
    required this.voc,
    required this.description,
    required this.pros,
    required this.cons,
    required this.bestIn,
    required this.palette,
  });
}

const materials = <MaterialItem>[
  MaterialItem(
    id: 'strand-bamboo',
    name: 'Strand-Woven Bamboo',
    category: 'Flooring',
    image: 'assets/images/mat-bamboo.jpg',
    carbon: 5,
    priceRange: '₹80–120 / sqft',
    durability: '25 years',
    climate: ['Hot-dry', 'Composite'],
    voc: 'Low',
    description:
        'Fast-growing grass compressed into planks harder than oak. Warm tones, honest grain, and a tiny carbon footprint.',
    pros: ['Harder than oak', 'Rapidly renewable', 'Low VOC finish'],
    cons: ['Sensitive to standing water', 'Limited stain range'],
    bestIn: ['Living room', 'Bedroom', 'Study'],
    palette: [Color(0xFFC9995F), Color(0xFFA97240), Color(0xFFF0E2C8)],
  ),
  MaterialItem(
    id: 'lime-plaster',
    name: 'Lime Plaster',
    category: 'Walls',
    image: 'assets/images/mat-lime.jpg',
    carbon: 5,
    priceRange: '₹45–90 / sqft',
    durability: '40+ years',
    climate: ['Hot-humid', 'Composite', 'Coastal'],
    voc: 'None',
    description:
        'Breathable mineral finish that absorbs CO₂ as it cures. Soft cloud-like texture that ages gracefully.',
    pros: ['Zero VOC', 'Regulates humidity', 'Fireproof'],
    cons: ['Skilled labour needed', 'Longer cure time'],
    bestIn: ['Living room', 'Bedroom', 'Foyer'],
    palette: [Color(0xFFF4EDE0), Color(0xFFE7DCC7), Color(0xFFC9BEAA)],
  ),
  MaterialItem(
    id: 'reclaimed-teak',
    name: 'Reclaimed Teak',
    category: 'Furniture',
    image: 'assets/images/mat-wood.jpg',
    carbon: 5,
    priceRange: '₹350–700 / sqft',
    durability: '50+ years',
    climate: ['All zones'],
    voc: 'None',
    description:
        'Salvaged from old havelis and ships. Character-rich, dense, and already carbon-locked for another lifetime.',
    pros: ['Zero new logging', 'Deep patina', 'Termite-resistant'],
    cons: ['Premium price', 'Limited plank widths'],
    bestIn: ['Dining', 'Study', 'Bedroom'],
    palette: [Color(0xFF5D3A20), Color(0xFF8A5A34), Color(0xFFC99464)],
  ),
  MaterialItem(
    id: 'terracotta-tile',
    name: 'Handmade Terracotta',
    category: 'Flooring',
    image: 'assets/images/mat-terracotta.jpg',
    carbon: 4,
    priceRange: '₹60–140 / sqft',
    durability: '60+ years',
    climate: ['Hot-dry', 'Composite'],
    voc: 'None',
    description:
        'Hand-pressed clay tiles fired in traditional kilns. Cool underfoot in summer, warm in tone all year.',
    pros: ['Locally made', 'Natural cooling', 'Recyclable'],
    cons: ['Needs sealing', 'Slight tone variance'],
    bestIn: ['Kitchen', 'Balcony', 'Courtyard'],
    palette: [Color(0xFFC8552B), Color(0xFFE07A3F), Color(0xFFF2B088)],
  ),
];

MaterialItem materialById(String id) =>
    materials.firstWhere((m) => m.id == id, orElse: () => materials.first);
