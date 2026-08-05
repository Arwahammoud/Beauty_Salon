class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? time,
    this.isError = false,
  }) : time = time ?? DateTime.now();

  String get formattedTime {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
