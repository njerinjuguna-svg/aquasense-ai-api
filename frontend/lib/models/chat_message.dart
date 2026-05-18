
/// Identifies which side of the conversation a message belongs to.
enum ChatRole {
  /// Message sent by the human user (right-aligned, pink bubble).
  user,
  /// Message sent by the AI assistant (left-aligned, mint bubble).
  assistant,
}

/// A single message in the AI advisory chat.
class ChatMessage {
  final String   id;
  final String   text;
  final ChatRole role;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.role,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Whether this message was sent by the user.
  bool get isUser => role == ChatRole.user;
}