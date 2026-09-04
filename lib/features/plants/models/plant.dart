/// Ported 1:1 from src/lib/catalog.ts
class Plant {
  final String id;
  final String name;
  final String latin;
  final String image;
  final List<String> filters;
  final String light; // "Low" | "Medium" | "Bright indirect" | "Direct"
  final String water;
  final bool petSafe;
  final List<String> rooms;
  final String size; // "Small" | "Medium" | "Large"
  final int care; // 1-5

  const Plant({
    required this.id,
    required this.name,
    required this.latin,
    required this.image,
    required this.filters,
    required this.light,
    required this.water,
    required this.petSafe,
    required this.rooms,
    required this.size,
    required this.care,
  });
}

const plants = <Plant>[
  Plant(
    id: 'areca-palm',
    name: 'Areca Palm',
    latin: 'Dypsis lutescens',
    image: 'assets/images/plant-areca.jpg',
    filters: ['Formaldehyde', 'Xylene', 'Toluene'],
    light: 'Bright indirect',
    water: 'Twice a week',
    petSafe: true,
    rooms: ['Living room', 'Study'],
    size: 'Large',
    care: 2,
  ),
  Plant(
    id: 'snake-plant',
    name: 'Snake Plant',
    latin: 'Dracaena trifasciata',
    image: 'assets/images/plant-snake.jpg',
    filters: ['Benzene', 'Formaldehyde', 'CO₂ at night'],
    light: 'Low',
    water: 'Every 2 weeks',
    petSafe: false,
    rooms: ['Bedroom', 'Bathroom'],
    size: 'Small',
    care: 1,
  ),
  Plant(
    id: 'monstera',
    name: 'Monstera',
    latin: 'Monstera deliciosa',
    image: 'assets/images/plant-monstera.jpg',
    filters: ['Formaldehyde', 'Ammonia'],
    light: 'Bright indirect',
    water: 'Weekly',
    petSafe: false,
    rooms: ['Living room', 'Study'],
    size: 'Medium',
    care: 2,
  ),
];

Plant? plantById(String id) {
  for (final p in plants) {
    if (p.id == id) return p;
  }
  return null;
}
