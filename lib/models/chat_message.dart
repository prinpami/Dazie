// A message used by the chat screen's local preview.
class ChatMessage {
  const ChatMessage({
    required this.sender,
    required this.text,
    required this.time,
    required this.isMine,
  });

  final String sender;
  final String text;
  final String time;
  final bool isMine;
}
