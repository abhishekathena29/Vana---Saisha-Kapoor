import 'package:cloud_firestore/cloud_firestore.dart';

enum ChatRole { user, assistant }

class ChatMessage {
  final String id;
  final ChatRole role;
  final String text;
  final bool hasImage;
  final DateTime? createdAt;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    this.hasImage = false,
    this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'role': role.name,
        'text': text,
        'hasImage': hasImage,
        'createdAt': FieldValue.serverTimestamp(),
      };

  factory ChatMessage.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ChatMessage(
      id: doc.id,
      role: data['role'] == 'assistant' ? ChatRole.assistant : ChatRole.user,
      text: data['text'] as String? ?? '',
      hasImage: data['hasImage'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
