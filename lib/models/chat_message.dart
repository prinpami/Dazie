// This creates the schema of the messages
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.sender,
    required this.text,
    required this.createdAt,
    required this.isMine,
    this.deliveryStatus = 'sent',
  });

  final String id;
  final String groupId;
  final String senderId;
  final String sender;
  final String text;
  final String createdAt;
  final bool isMine;
  final String deliveryStatus;

  // Stored status strings stay compatible with earlier prototype builds.
  // Receipts describe at least one immediate peer, never the entire group.
  String get deliveryLabel => switch (deliveryStatus) {
    'queued' => 'Waiting to send',
    'sent' => 'Sent to a nearby device',
    'delivered' => 'Confirmed by a nearby device',
    'received' => 'Received',
    _ => 'Status unavailable',
  };

  String get time {
    final date = DateTime.tryParse(createdAt)?.toLocal();
    if (date == null) return '';
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'am' : 'pm';
    return '$hour:$minute $period';
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'groupId': groupId,
    'senderId': senderId,
    'sender': sender,
    'text': text,
    'createdAt': createdAt,
    'isMine': isMine,
    'deliveryStatus': deliveryStatus,
  };

  factory ChatMessage.fromMap(Map<String, Object?> map) => ChatMessage(
    id: map['id'] as String,
    groupId: map['groupId'] as String,
    senderId: map['senderId'] as String,
    sender: map['sender'] as String,
    text: map['text'] as String,
    createdAt: map['createdAt'] as String,
    isMine: map['isMine'] as bool? ?? false,
    deliveryStatus: map['deliveryStatus'] as String? ?? 'sent',
  );
}
