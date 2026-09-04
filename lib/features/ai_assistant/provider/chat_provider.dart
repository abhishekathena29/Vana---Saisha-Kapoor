import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/services/firestore_service.dart';
import '../../../core/services/groq_service.dart';
import '../models/chat_message.dart';

/// Chat history + send/analyze flow for the AI Assistant screen.
class ChatProvider extends ChangeNotifier {
  ChatProvider() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((_) => _resubscribe());
    _resubscribe();
  }

  StreamSubscription<User?>? _authSub;
  StreamSubscription<List<ChatMessage>>? _dataSub;

  List<ChatMessage> _messages = const [];
  List<ChatMessage> get messages => _messages;

  Uint8List? pendingImage;
  bool thinking = false;
  String? error;

  void _resubscribe() {
    _dataSub?.cancel();
    _messages = const [];
    _dataSub = FirestoreService.instance.chatMessagesStream().listen((msgs) {
      _messages = msgs;
      notifyListeners();
    });
    notifyListeners();
  }

  void setPendingImage(Uint8List? bytes) {
    pendingImage = bytes;
    notifyListeners();
  }

  void setError(String message) {
    error = message;
    notifyListeners();
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    final image = pendingImage;
    if (trimmed.isEmpty && image == null) return;

    final userMessage = ChatMessage(
      id: '',
      role: ChatRole.user,
      text: trimmed.isEmpty ? '📷 Shared a room photo' : trimmed,
      hasImage: image != null,
    );

    error = null;
    thinking = true;
    pendingImage = null;
    notifyListeners();

    try {
      await FirestoreService.instance.addChatMessage(userMessage);
      final reply = await GroqService.instance.chat(history: _messages, prompt: trimmed, imageBytes: image);
      await FirestoreService.instance.addChatMessage(ChatMessage(id: '', role: ChatRole.assistant, text: reply));
    } catch (e) {
      error = e is GroqException ? e.message : 'Something went wrong. Please try again.';
    } finally {
      thinking = false;
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
