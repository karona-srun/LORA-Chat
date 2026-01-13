class ChatMessage {
  final String text;
  final String sender;
  final DateTime timestamp;
  final bool isSystem;

  ChatMessage({
    required this.text,
    required this.sender,
    required this.timestamp,
    this.isSystem = false,
  });
}

