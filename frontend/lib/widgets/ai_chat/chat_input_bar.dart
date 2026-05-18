
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// The message input bar pinned to the bottom of the AI chat screen.
///
/// Contains: + attach button · text field · mic icon · teal send button.
/// [onSend] is called with the trimmed message text when the user taps send
/// or submits via the keyboard — the bar then clears itself automatically.
class ChatInputBar extends StatefulWidget {
  final ValueChanged<String> onSend;

  const ChatInputBar({super.key, required this.onSend});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16, 10, 16,
        // Respect the home-indicator safe area on modern iPhones
        MediaQuery.of(context).viewInsets.bottom > 0
            ? MediaQuery.of(context).viewInsets.bottom + 12
            : MediaQuery.of(context).viewPadding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.borderColor)),
      ),
      child: Row(
        children: [
          // ── Attach / plus button ────────────────────────────────────
          GestureDetector(
            onTap: () {}, // placeholder — attach file logic goes here
            child: const Icon(Icons.add, color: AppColors.textGrey, size: 24),
          ),
          const SizedBox(width: 8),

          // ── Text field ──────────────────────────────────────────────
          Expanded(
            child: TextField(
              controller:   _controller,
              onSubmitted:  (_) => _send(),
              textInputAction: TextInputAction.send,
              style:        tt.bodyMedium?.copyWith(color: AppColors.textDark),
              decoration: const InputDecoration(
                hintText:       'Send Message',
                // Remove all borders — the bar's top border is the separator
                border:         InputBorder.none,
                enabledBorder:  InputBorder.none,
                focusedBorder:  InputBorder.none,
                contentPadding: EdgeInsets.zero,
                fillColor:      Colors.transparent,
              ),
            ),
          ),

          // ── Mic button ──────────────────────────────────────────────
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {}, // placeholder — voice input goes here
            child: const Icon(Icons.mic_none, color: AppColors.textGrey, size: 24),
          ),
          const SizedBox(width: 8),

          // ── Send button ─────────────────────────────────────────────
          GestureDetector(
            onTap: _send,
            child: Container(
              width:  44,
              height: 44,
              decoration: BoxDecoration(
                color:        AppColors.teal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.send_rounded,
                color: AppColors.white,
                size:  20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
