import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/services/firestore_service.dart';

/// Saved cost-calculator estimates for the signed-in user.
class EstimatesProvider extends ChangeNotifier {
  EstimatesProvider() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((_) => _resubscribe());
    _resubscribe();
  }

  StreamSubscription<User?>? _authSub;
  StreamSubscription<List<Map<String, dynamic>>>? _dataSub;

  List<Map<String, dynamic>> _items = const [];
  List<Map<String, dynamic>> get items => _items;

  bool saving = false;

  void _resubscribe() {
    _dataSub?.cancel();
    _items = const [];
    _dataSub = FirestoreService.instance.estimatesStream().listen((items) {
      _items = items;
      notifyListeners();
    });
    notifyListeners();
  }

  Future<bool> saveEstimate({
    required String space,
    required int sqft,
    required String flooring,
    required String wall,
    required int plantsCount,
    required num total,
  }) async {
    saving = true;
    notifyListeners();
    try {
      await FirestoreService.instance.saveEstimate(
        space: space,
        sqft: sqft,
        flooring: flooring,
        wall: wall,
        plantsCount: plantsCount,
        total: total,
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _dataSub?.cancel();
    super.dispose();
  }
}
