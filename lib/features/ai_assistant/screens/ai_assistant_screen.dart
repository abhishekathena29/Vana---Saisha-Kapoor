import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../models/chat_message.dart';
import '../provider/chat_provider.dart';
import '../../../core/theme/app_theme.dart';

const _starterPrompts = [
  'What plants suit a dark, north-facing bedroom?',
  'Suggest a low-VOC palette for a small kitchen',
  'Which flooring survives Mumbai monsoons best?',
];

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _picker = ImagePicker();

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent + 140,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.of(context).maybePop();
    final chat = context.read<ChatProvider>();
    try {
      final file = await _picker.pickImage(source: source, imageQuality: 70, maxWidth: 1280);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      chat.setPendingImage(bytes);
    } catch (_) {
      chat.setError('Could not open camera/gallery. Check app permissions in Settings.');
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.camera, color: AppColors.primary),
              title: Text('Take a photo', style: AppTextStyles.sans(fontSize: 14, fontWeight: FontWeight.w600)),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(LucideIcons.image, color: AppColors.primary),
              title: Text('Choose from gallery', style: AppTextStyles.sans(fontSize: 14, fontWeight: FontWeight.w600)),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send([String? presetText]) async {
    final text = presetText ?? _textCtrl.text;
    _textCtrl.clear();
    _scrollToEnd();
    await context.read<ChatProvider>().send(text);
    _scrollToEnd();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final messages = chat.messages;
    final thinking = chat.thinking;
    final error = chat.error;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(gradient: AppColors.gradientLeaf, borderRadius: BorderRadius.circular(999)),
                child: const Icon(LucideIcons.sparkles, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Design Assistant', style: AppTextStyles.display(fontSize: 19, fontWeight: FontWeight.w600)),
                    Text('Ask anything, or share a photo of your room',
                        style: AppTextStyles.sans(fontSize: 11.5, color: AppColors.mutedForeground)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: messages.isEmpty && !thinking
              ? _EmptyState(onPromptTap: _send)
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  itemCount: messages.length + (thinking ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i == messages.length) return const _ThinkingBubble();
                    return _MessageBubble(message: messages[i]);
                  },
                ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.destructive.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.destructive.withValues(alpha: 0.25)),
              ),
              child: Text(error, style: AppTextStyles.sans(fontSize: 12, color: AppColors.destructive, height: 1.35)),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
          child: _Composer(
            textCtrl: _textCtrl,
            pendingImage: chat.pendingImage,
            onRemoveImage: () => context.read<ChatProvider>().setPendingImage(null),
            onAttach: _showImageSourceSheet,
            onSend: () => _send(),
            sending: thinking,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ValueChanged<String> onPromptTap;
  const _EmptyState({required this.onPromptTap});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        const SizedBox(height: 24),
        Center(
          child: Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), shape: BoxShape.circle),
            child: const Icon(LucideIcons.sparkles, size: 26, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Your sustainable design co-pilot',
          textAlign: TextAlign.center,
          style: AppTextStyles.display(fontSize: 19, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          'Snap a photo of any room and get material, plant and colour suggestions — or just ask a question.',
          textAlign: TextAlign.center,
          style: AppTextStyles.sans(fontSize: 13, color: AppColors.mutedForeground, height: 1.4),
        ),
        const SizedBox(height: 20),
        ..._starterPrompts.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => onPromptTap(p),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(p, style: AppTextStyles.sans(fontSize: 13.5, fontWeight: FontWeight.w500))),
                      const Icon(LucideIcons.arrowUpRight, size: 15, color: AppColors.mutedForeground),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.card,
          border: isUser ? null : Border.all(color: AppColors.border),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.hasImage) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.image, size: 13, color: isUser ? Colors.white.withValues(alpha: 0.85) : AppColors.mutedForeground),
                  const SizedBox(width: 6),
                  Text('Photo attached',
                      style: AppTextStyles.sans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isUser ? Colors.white.withValues(alpha: 0.85) : AppColors.mutedForeground)),
                ],
              ),
              const SizedBox(height: 6),
            ],
            Text(
              message.text,
              style: AppTextStyles.sans(fontSize: 14, height: 1.45, color: isUser ? AppColors.primaryForeground : AppColors.foreground),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 12,
              width: 12,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Text('Thinking…', style: AppTextStyles.sans(fontSize: 13, color: AppColors.mutedForeground)),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController textCtrl;
  final Uint8List? pendingImage;
  final VoidCallback onRemoveImage;
  final VoidCallback onAttach;
  final VoidCallback onSend;
  final bool sending;

  const _Composer({
    required this.textCtrl,
    required this.pendingImage,
    required this.onRemoveImage,
    required this.onAttach,
    required this.onSend,
    required this.sending,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          if (pendingImage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 4, 6, 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(pendingImage!, height: 44, width: 44, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Photo ready to send', style: AppTextStyles.sans(fontSize: 12, color: AppColors.mutedForeground)),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 16, color: AppColors.mutedForeground),
                    onPressed: onRemoveImage,
                  ),
                ],
              ),
            ),
          Row(
            children: [
              IconButton(
                onPressed: sending ? null : onAttach,
                icon: const Icon(LucideIcons.paperclip, size: 20, color: AppColors.primary),
              ),
              Expanded(
                child: TextField(
                  controller: textCtrl,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => sending ? null : onSend(),
                  style: AppTextStyles.sans(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Ask about materials, plants, colours…',
                    hintStyle: AppTextStyles.sans(fontSize: 13.5, color: AppColors.mutedForeground.withValues(alpha: 0.7)),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: sending ? null : onSend,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: sending ? AppColors.border : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.arrowUp, size: 18, color: sending ? AppColors.mutedForeground : AppColors.primaryForeground),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
