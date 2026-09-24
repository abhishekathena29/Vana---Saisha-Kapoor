import 'package:intl/intl.dart' show NumberFormat;

import '../../materials/models/material_item.dart';
import '../../plants/models/plant.dart';

/// Rooms a project item can be assigned to, with a typical area used as the
/// default when a material is added.
class ProjectRoom {
  final String name;
  final int defaultSqft;
  const ProjectRoom(this.name, this.defaultSqft);
}

const projectRooms = <ProjectRoom>[
  ProjectRoom('Living room', 200),
  ProjectRoom('Bedroom', 140),
  ProjectRoom('Kitchen', 100),
  ProjectRoom('Bathroom', 60),
  ProjectRoom('Study', 100),
  ProjectRoom('Balcony', 80),
];

int defaultSqftFor(String room) {
  for (final r in projectRooms) {
    if (r.name == room) return r.defaultSqft;
  }
  return 120;
}

final _inr = NumberFormat.decimalPattern('en_IN');

/// Indian digit grouping, e.g. 1,24,000.
String formatInr(num n) => _inr.format(n.round());

/// Mid-point of a price range like "₹80–120 / sqft".
double priceMid(String range) {
  final nums = RegExp(r'\d+(\.\d+)?').allMatches(range).map((m) => double.parse(m.group(0)!)).toList();
  if (nums.isEmpty) return 0;
  if (nums.length == 1) return nums[0];
  return (nums[0] + nums[1]) / 2;
}

/// One line in the user's project: a material covering some sqft of a room,
/// or a number of plants placed in a room.
class ProjectItem {
  final String id;
  final String type; // 'material' | 'plant'
  final String refId;
  final String name;
  final String room;
  final int sqft;
  final int quantity;

  const ProjectItem({
    required this.id,
    required this.type,
    required this.refId,
    required this.name,
    required this.room,
    this.sqft = 0,
    this.quantity = 0,
  });

  bool get isMaterial => type == 'material';

  static String docId(String type, String refId, String room) =>
      '${type}_${refId}_${room.toLowerCase().replaceAll(' ', '-')}';

  factory ProjectItem.fromMap(Map<String, dynamic> m) => ProjectItem(
        id: m['id'] as String,
        type: m['type'] as String? ?? 'material',
        refId: m['refId'] as String? ?? '',
        name: m['name'] as String? ?? '',
        room: m['room'] as String? ?? 'Living room',
        sqft: (m['sqft'] as num?)?.toInt() ?? 0,
        quantity: (m['quantity'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'type': type,
        'refId': refId,
        'name': name,
        'room': room,
        'sqft': sqft,
        'quantity': quantity,
      };

  MaterialItem? get material {
    if (!isMaterial) return null;
    for (final m in materials) {
      if (m.id == refId) return m;
    }
    return null;
  }

  Plant? get plant => isMaterial ? null : plantById(refId);

  String get image => material?.image ?? plant?.image ?? '';

  /// Material cost only; labour is added at the project level.
  int get cost {
    final m = material;
    if (m != null) return (priceMid(m.priceRange) * sqft).round();
    final p = plant;
    if (p != null) return p.price * quantity;
    return 0;
  }
}
