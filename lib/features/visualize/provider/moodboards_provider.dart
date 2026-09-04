import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/services/firestore_service.dart';

/// Saved moodboard variations from the Visualize screen.
class MoodboardsProvider extends ChangeNotifier {
  MoodboardsProvider() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((_) => _resubscribe());
    _resubscribe();
  }

  StreamSubscription<User?>? _authSub;
  StreamSubscription<List<Map<String, dynamic>>>? _dataSub;

  List<Map<String, dynamic>> _items = const [];
  List<Map<String, dynamic>> get items => _items;

  Future<bool> saveMoodboard({
    required String style,
    required String space,
    required String note,
    required int variation,
  }) async {
    try {
      await FirestoreService.instance.saveMoodboard(style: style, space: space, note: note, variation: variation);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _resubscribe() {
    _dataSub?.cancel();
    _items = const [];
    _dataSub = FirestoreService.instance.moodboardsStream().listen((items) {
      _items = items;
      notifyListeners();
    });
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _dataSub?.cancel();
    super.dispose();
  }
}
