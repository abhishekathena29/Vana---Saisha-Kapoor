import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/ai_assistant/models/chat_message.dart';

/// Every read/write in the app for the signed-in user's data lives here.
/// Data is scoped under users/{uid}/... so firestore.rules can lock it down
/// to "only the owner can touch their own subtree".
class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> get _userDoc {
    final uid = _uid;
    if (uid == null) throw StateError('No signed-in user.');
    return _db.collection('users').doc(uid);
  }

  // ---------------------------------------------------------------------
  // Favorites (materials + plants)
  // ---------------------------------------------------------------------

  CollectionReference<Map<String, dynamic>> get _favorites => _userDoc.collection('favorites');

  Stream<Set<String>> favoriteIdsStream() {
    if (_uid == null) return Stream.value(<String>{});
    return _favorites.snapshots().map((s) => s.docs.map((d) => d.id).toSet());
  }

  Future<bool> toggleFavorite({
    required String id,
    required String type, // 'material' | 'plant'
    required String name,
  }) async {
    final ref = _favorites.doc(id);
    final existing = await ref.get();
    if (existing.exists) {
      await ref.delete();
      return false;
    }
    await ref.set({
      'type': type,
      'name': name,
      'addedAt': FieldValue.serverTimestamp(),
    });
    return true;
  }

  // ---------------------------------------------------------------------
  // Cost calculator estimates
  // ---------------------------------------------------------------------

  CollectionReference<Map<String, dynamic>> get _estimates => _userDoc.collection('estimates');

  Future<void> saveEstimate({
    required String space,
    required int sqft,
    required String flooring,
    required String wall,
    required int plantsCount,
    required num total,
  }) {
    return _estimates.add({
      'space': space,
      'sqft': sqft,
      'flooring': flooring,
      'wall': wall,
      'plantsCount': plantsCount,
      'total': total,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> estimatesStream() {
    if (_uid == null) return Stream.value(const []);
    return _estimates.orderBy('createdAt', descending: true).limit(20).snapshots().map(
          (s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        );
  }

  // ---------------------------------------------------------------------
  // Visualize moodboards
  // ---------------------------------------------------------------------

  CollectionReference<Map<String, dynamic>> get _moodboards => _userDoc.collection('moodboards');

  Future<void> saveMoodboard({
    required String style,
    required String space,
    required String note,
    required int variation,
  }) {
    return _moodboards.add({
      'style': style,
      'space': space,
      'note': note,
      'variation': variation,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> moodboardsStream() {
    if (_uid == null) return Stream.value(const []);
    return _moodboards.orderBy('createdAt', descending: true).limit(20).snapshots().map(
          (s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        );
  }

  // ---------------------------------------------------------------------
  // Vendor quote requests
  // ---------------------------------------------------------------------

  CollectionReference<Map<String, dynamic>> get _quoteRequests => _userDoc.collection('quoteRequests');

  Future<void> requestQuote({required String vendorName, required String city}) {
    return _quoteRequests.add({
      'vendorName': vendorName,
      'city': city,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ---------------------------------------------------------------------
  // AI assistant chat history
  // ---------------------------------------------------------------------

  CollectionReference<Map<String, dynamic>> get _chatMessages => _userDoc.collection('chatMessages');

  Future<void> addChatMessage(ChatMessage message) {
    return _chatMessages.add(message.toMap());
  }

  Stream<List<ChatMessage>> chatMessagesStream() {
    if (_uid == null) return Stream.value(const []);
    return _chatMessages.orderBy('createdAt').snapshots().map(
          (s) => s.docs.map(ChatMessage.fromDoc).toList(),
        );
  }
}
