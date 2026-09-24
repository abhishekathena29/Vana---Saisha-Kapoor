import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/services/firestore_service.dart';
import '../models/project_item.dart';

/// The signed-in user's project: materials and plants grouped by room.
/// Fed by the material detail screen, the air kit builder and design stories.
class ProjectProvider extends ChangeNotifier {
  ProjectProvider() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((_) => _resubscribe());
    _resubscribe();
  }

  StreamSubscription<User?>? _authSub;
  StreamSubscription<List<Map<String, dynamic>>>? _dataSub;

  List<ProjectItem> _items = const [];
  List<ProjectItem> get items => _items;

  static const laborRate = 0.35;

  int get materialsCost => _items.fold(0, (sum, i) => sum + i.cost);
  int get labourCost => (_items.where((i) => i.isMaterial).fold(0, (sum, i) => sum + i.cost) * laborRate).round();
  int get totalCost => materialsCost + labourCost;

  List<String> get rooms {
    final seen = <String>[];
    for (final i in _items) {
      if (!seen.contains(i.room)) seen.add(i.room);
    }
    return seen;
  }

  List<ProjectItem> itemsFor(String room) => _items.where((i) => i.room == room).toList();

  List<ProjectItem> itemsForRef(String refId) => _items.where((i) => i.refId == refId).toList();

  bool contains(String refId) => _items.any((i) => i.refId == refId);

  void _resubscribe() {
    _dataSub?.cancel();
    _items = const [];
    _dataSub = FirestoreService.instance.projectItemsStream().listen((items) {
      _items = items.map(ProjectItem.fromMap).toList();
      notifyListeners();
    });
    notifyListeners();
  }

  Future<bool> addMaterial({required String id, required String name, required String room, required int sqft}) {
    return addAll([
      ProjectItem(id: ProjectItem.docId('material', id, room), type: 'material', refId: id, name: name, room: room, sqft: sqft),
    ]);
  }

  /// Writes (or overwrites) several items in one batch.
  Future<bool> addAll(List<ProjectItem> items) async {
    try {
      await FirestoreService.instance.setProjectItems({for (final i in items) i.id: i.toMap()});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> update(ProjectItem item, {int? sqft, int? quantity}) async {
    try {
      await FirestoreService.instance.updateProjectItem(item.id, {
        'sqft': ?sqft,
        'quantity': ?quantity,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> remove(Iterable<String> ids) async {
    try {
      await FirestoreService.instance.removeProjectItems(ids);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _dataSub?.cancel();
    super.dispose();
  }
}
