import 'package:flutter/foundation.dart';

import '../../../core/services/firestore_service.dart';

/// Tracks which vendors the signed-in user has already requested a quote
/// from in this session, plus a simple submitting flag for button state.
class VendorsProvider extends ChangeNotifier {
  final Set<String> _requested = {};
  bool submitting = false;

  bool isRequested(String vendorName) => _requested.contains(vendorName);

  Future<void> requestQuote({required String vendorName, required String city}) async {
    submitting = true;
    notifyListeners();
    try {
      await FirestoreService.instance.requestQuote(vendorName: vendorName, city: city);
      _requested.add(vendorName);
    } finally {
      submitting = false;
      notifyListeners();
    }
  }
}
