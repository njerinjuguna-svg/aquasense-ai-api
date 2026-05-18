
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/sensor_model.dart';

/// Manages the AI advisory chat conversation for a single sensor.
///
/// The conversation is pre-seeded with an opening message from the assistant.
/// [sendMessage] appends the user turn then simulates an AI response.
class ChatProvider extends ChangeNotifier {
  ChatProvider({required SensorModel sensor}) : _sensor = sensor {
    _seedOpeningMessage();
  }

  final SensorModel    _sensor;
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  List<ChatMessage> get messages  => List.unmodifiable(_messages);
  bool              get isTyping  => _isTyping;

  /// Seeds the initial assistant greeting when the chat opens.
  void _seedOpeningMessage(String? userName) {
    final greeting = userName != null ? 'Hey $userName!' : 'Hello!';
    _messages.add(ChatMessage(
      id:   'm0',
      text: '$greeting How may I help you today?',
      role: ChatRole.assistant,
    ));
  }

  /// Appends the user's message then simulates an AI response after a delay.
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Append user message
    _messages.add(ChatMessage(
      id:   'm${_messages.length}',
      text: text.trim(),
      role: ChatRole.user,
    ));
    _isTyping = true;
    notifyListeners();

    // Simulate network/AI latency
    await Future.delayed(const Duration(milliseconds: 1200));

    // Generate a context-aware reply from the sensor's advisory data
    _messages.add(ChatMessage(
      id:   'm${_messages.length}',
      text: _generateReply(text),
      role: ChatRole.assistant,
    ));
    _isTyping = false;
    notifyListeners();
  }

  /// Produces a canned reply based on keyword matching.
  /// Replace with a real API call (e.g. OpenAI / Anthropic) when ready.
  String _generateReply(String userText) {
    final lower = userText.toLowerCase();
    final advisory = _sensor.advisory;

    if (lower.contains('recommend') || lower.contains('confirm') || lower.contains('action')) {
      final actions = advisory.recommendedActions.map((a) => '• $a').join('\n');
      return 'Yes! Here are the recommendations based on the anomaly detected:\n$actions';
    }
    if (lower.contains('impact') || lower.contains('effect')) {
      return advisory.impactExplanation;
    }
    if (lower.contains('note') || lower.contains('regulation') || lower.contains('compliance')) {
      return advisory.impactNotes;
    }
    if (lower.contains('safe') || lower.contains('range')) {
      return 'The safe operating range for this sensor is ${_sensor.safeRange}.';
    }
    // Default fallback
    return 'Based on the current sensor data: ${advisory.headline}. '
        'Would you like me to expand on the recommended actions or impact notes?';
  }
}
