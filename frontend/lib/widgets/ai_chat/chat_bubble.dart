
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/chat_message.dart';

/// A single chat message bubble.
///
/// Layout rules:
///   - User messages: right-aligned, pink background [AppColors.pinkLight]
///   - Assistant messages: left-aligned, mint background [AppColors.mintLight]
///
/// Multi-line text is handled naturally by the [Text] widget inside
/// a flexible container.
class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final tt      = Theme.of(context).textTheme;
    final isUser  = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        // User bubbles hug the right edge; assistant bubbles the left
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── Bubble container ───────────────────────────────────────
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                // Bubble occupies at most 75 % of the row width
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.pinkLight : AppColors.mintLight,
                borderRadius: BorderRadius.only(
                  topLeft:     const Radius.circular(16),
                  topRight:    const Radius.circular(16),
                  bottomLeft:  Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4  : 16),
                ),
              ),
              child: Text(
                message.text,
                style: tt.bodyMedium?.copyWith(color: AppColors.textDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
