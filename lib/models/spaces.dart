import 'package:flutter/material.dart';

/// Ported 1:1 from src/lib/spaces.ts
class SpaceMove {
  final String title;
  final String detail;
  const SpaceMove({required this.title, required this.detail});
}

class SpaceGuide {
  final String id;
  final String name;
  final String tagline;
  final String image;
  final List<Color> palette;
  final List<String> materialIds;
  final List<String> plantIds;
  final List<SpaceMove> moves;

  const SpaceGuide({
    required this.id,
    required this.name,
    required this.tagline,
    required this.image,
    required this.palette,
    required this.materialIds,
    required this.plantIds,
    required this.moves,
  });
}

const spaces = <SpaceGuide>[
  SpaceGuide(
    id: 'living',
    name: 'Living Room',
    tagline: 'Grounded, breathable, made for slow evenings',
    image: 'assets/images/hero-living.jpg',
    palette: [Color(0xFFE7DCC7), Color(0xFF8A5A34), Color(0xFF5F7A55)],
    materialIds: ['strand-bamboo', 'lime-plaster', 'reclaimed-teak'],
    plantIds: ['areca-palm', 'monstera'],
    moves: [
      SpaceMove(title: 'Floor', detail: 'Strand-woven bamboo planks laid in a long-grain to widen the room.'),
      SpaceMove(title: 'Walls', detail: 'Two coats of lime plaster in bone-white to bounce daylight and absorb CO₂.'),
      SpaceMove(title: 'Anchor piece', detail: 'Reclaimed teak coffee table, oiled — no new logging, deep patina.'),
      SpaceMove(title: 'Green layer', detail: 'One Areca palm in the brightest corner, a Monstera by the sofa.'),
    ],
  ),
  SpaceGuide(
    id: 'bedroom',
    name: 'Bedroom',
    tagline: 'Low-VOC, quiet, air-cleansing while you sleep',
    image: 'assets/images/story-bedroom.jpg',
    palette: [Color(0xFFF4EDE0), Color(0xFFC9995F), Color(0xFF3D5A3D)],
    materialIds: ['lime-plaster', 'strand-bamboo'],
    plantIds: ['snake-plant'],
    moves: [
      SpaceMove(title: 'Walls', detail: 'Lime plaster in warm oat — regulates humidity, zero off-gassing near the pillow.'),
      SpaceMove(title: 'Floor', detail: 'Bamboo with a hardwax-oil finish, warmer underfoot than tile.'),
      SpaceMove(title: 'Bedside', detail: 'A Snake Plant on each nightstand — releases oxygen at night, near-zero care.'),
      SpaceMove(title: 'Textiles', detail: 'Undyed cotton or linen bedding to keep the low-VOC promise honest.'),
    ],
  ),
  SpaceGuide(
    id: 'kitchen',
    name: 'Kitchen',
    tagline: 'Hard-wearing, heat-tolerant, easy to clean',
    image: 'assets/images/story-kitchen.jpg',
    palette: [Color(0xFFF2B088), Color(0xFFC8552B), Color(0xFF5D3A20)],
    materialIds: ['terracotta-tile', 'reclaimed-teak'],
    plantIds: ['monstera'],
    moves: [
      SpaceMove(title: 'Floor', detail: 'Handmade terracotta, sealed — cool underfoot, ages beautifully with spills.'),
      SpaceMove(title: 'Counters', detail: 'Reclaimed teak butcher block on the island for warmth against stone.'),
      SpaceMove(title: 'Backsplash', detail: 'Lime-washed brick or leftover terracotta offcuts for zero-waste texture.'),
      SpaceMove(title: 'Green layer', detail: 'A trailing Monstera above the fridge softens the hardest room in the house.'),
    ],
  ),
  SpaceGuide(
    id: 'bathroom',
    name: 'Bathroom',
    tagline: 'Humidity-loving finishes, spa-like calm',
    image: 'assets/images/story-bedroom.jpg',
    palette: [Color(0xFFE7DCC7), Color(0xFFA97240), Color(0xFF4A6A55)],
    materialIds: ['lime-plaster', 'terracotta-tile'],
    plantIds: ['snake-plant'],
    moves: [
      SpaceMove(title: 'Walls', detail: 'Tadelakt-style lime plaster — waterproof, mould-resistant, no tile grout to scrub.'),
      SpaceMove(title: 'Floor', detail: 'Small-format terracotta with a matte sealer for grip when wet.'),
      SpaceMove(title: 'Shelf plant', detail: 'Snake Plant thrives on shower steam and low light.'),
    ],
  ),
  SpaceGuide(
    id: 'study',
    name: 'Study',
    tagline: 'Focus-friendly, biophilic, honest materials',
    image: 'assets/images/hero-living.jpg',
    palette: [Color(0xFFC9BEAA), Color(0xFF8A5A34), Color(0xFF3D5A3D)],
    materialIds: ['reclaimed-teak', 'strand-bamboo'],
    plantIds: ['areca-palm', 'monstera'],
    moves: [
      SpaceMove(title: 'Desk', detail: 'Single-slab reclaimed teak on hairpin legs — one piece, decades of life.'),
      SpaceMove(title: 'Floor', detail: 'Bamboo underlay to soften the acoustics of a hard-working room.'),
      SpaceMove(title: 'Air', detail: 'An Areca palm within eye-line for a proven focus lift.'),
    ],
  ),
  SpaceGuide(
    id: 'balcony',
    name: 'Balcony',
    tagline: 'Outdoor-tough, rain-friendly, alive',
    image: 'assets/images/story-kitchen.jpg',
    palette: [Color(0xFFC8552B), Color(0xFF5F7A55), Color(0xFFF2B088)],
    materialIds: ['terracotta-tile'],
    plantIds: ['areca-palm', 'snake-plant'],
    moves: [
      SpaceMove(title: 'Floor', detail: 'Handmade terracotta laid over the existing screed — no demo needed.'),
      SpaceMove(title: 'Planter wall', detail: 'Vertical stack of terracotta pots: Areca for shade, Snake Plant for sun.'),
      SpaceMove(title: 'Seating', detail: 'A reclaimed teak bench — the one wood that laughs at monsoon.'),
    ],
  ),
];

SpaceGuide spaceById(String id) =>
    spaces.firstWhere((s) => s.id == id, orElse: () => spaces.first);
