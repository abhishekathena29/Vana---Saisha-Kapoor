import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/services/firestore_service.dart';

/// Shared favourite-materials/plants state, used by the materials, plants
/// and profile features. Re-subscribes to Firestore whenever the signed-in
/// user changes (including sign-out, which clears local state).
class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((_) => _resubscribe());
    _resubscribe();
  }

  StreamSubscription<User?>? _authSub;
  StreamSubscription<Set<String>>? _dataSub;

  Set<String> _ids = {};
  Set<String> get ids => _ids;

  bool isFavorite(String id) => _ids.contains(id);

  void _resubscribe() {
    _dataSub?.cancel();
    _ids = {};
    _dataSub = FirestoreService.instance.favoriteIdsStream().listen((ids) {
      _ids = ids;
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> toggle({required String id, required String type, required String name}) {
    return FirestoreService.instance.toggleFavorite(id: id, type: type, name: name);
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _dataSub?.cancel();
    super.dispose();
  }
}
