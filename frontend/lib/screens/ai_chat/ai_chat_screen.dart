
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/sensor_model.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/ai_chat/chat_bubble.dart';
import '../../widgets/ai_chat/chat_input_bar.dart';
import '../../widgets/ai_chat/typing_indicator.dart';
import '../../widgets/sensors/ai_advisory_card.dart';

/// AI Advisory Chat screen.
///
/// Layout (top → bottom):
///   1. Header: pink back button (left) + purple AI circle (centre)
///   2. [AiAdvisoryCard] — structured advisory for the sensor
///   3. Chat message list — scrollable, newest at bottom
///   4. [ChatInputBar] — pinned to the bottom
///
/// A fresh [ChatProvider] is created via [ChangeNotifierProvider.value]
/// so it's scoped to this screen and disposed when the user navigates away.
/// The sensor is passed as a route argument from [SensorDetailScreen] or
/// [AiAdvisoryScreen].
class AiChatScreen extends StatelessWidget {
  const AiChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! SensorModel) {
      // Gracefully handle missing/invalid arguments
      return const Scaffold(
        body: Center(child: Text('Invalid sensor data')),
      );
    }
    final sensor = args;

    return ChangeNotifierProvider(
      create: (_) => ChatProvider(sensor: sensor),
      child: _AiChatView(sensor: sensor),
    );
  }}

// ─────────────────────────────────────────────────────────────────────────────
// Main view — reads ChatProvider
// ─────────────────────────────────────────────────────────────────────────────

class _AiChatView extends StatefulWidget {
  final SensorModel sensor;
  const _AiChatView({required this.sensor});

  @override
  State<_AiChatView> createState() => _AiChatViewState();
}

class _AiChatViewState extends State<_AiChatView> {
  /// Keeps the list scrolled to the latest message.
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Scrolls to the very bottom after the current frame renders.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve:    Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            _ChatHeader(),
            const SizedBox(height: 16),

            // ── Scrollable content: advisory card + messages ─────────
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, provider, _) {
                  // Scroll whenever messages or typing state changes
                  _scrollToBottom();

                  return ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // ── Advisory card (always visible at top) ───────
                      AiAdvisoryCard(advisory: widget.sensor.advisory),
                      const SizedBox(height: 20),

                      // ── Chat messages ────────────────────────────────
                      ...provider.messages.map(
                        (m) => ChatBubble(message: m),
                      ),

                      // ── Typing indicator ─────────────────────────────
                      if (provider.isTyping) const TypingIndicator(),

                      // Bottom padding so last message clears the input bar
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
            ),

            // ── Input bar ────────────────────────────────────────────
            ChatInputBar(
              onSend: (text) =>
                  context.read<ChatProvider>().sendMessage(text),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared header widgets (same pattern as AiAdvisoryScreen)
// ─────────────────────────────────────────────────────────────────────────────

/// Top bar: pink back button left, purple AI circle centred.
class _ChatHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _PinkBackButton(onTap: () => Navigator.of(context).pop()),
          ),
          const _AiFabCircle(),
        ],
      ),
    );
  }
}

/// Pink circle with a chevron-left — matches the detail screen style.
class _PinkBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PinkBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: const BoxDecoration(
          color: AppColors.pinkLight,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.chevron_left,
          color: AppColors.teal,
          size:  22,
        ),
      ),
    );
  }
}

/// Purple sparkle circle — matches the [MainShell] FAB colour.
class _AiFabCircle extends StatelessWidget {
  const _AiFabCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56, height: 56,
      decoration: const BoxDecoration(
        color: AppColors.aiFab,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.auto_awesome, color: AppColors.white, size: 26),
    );
  }
}
