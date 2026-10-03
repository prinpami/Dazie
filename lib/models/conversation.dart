class Conversation {
  const Conversation({
    required this.id,
    required this.name,
    required this.memberIds,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage = '',
    this.ownerId = '',
    this.isGroup = true,
  });

  final String id;
  final String name;
  final List<String> memberIds;
  final String createdAt;
  final String updatedAt;
  final String lastMessage;
  final String ownerId;
  final bool isGroup;

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'ownerId': ownerId,
    'memberIds': memberIds,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'lastMessage': lastMessage,
    'isGroup': isGroup,
  };

  factory Conversation.fromMap(Map<String, Object?> map) => Conversation(
    id: map['id'] as String,
    name: map['name'] as String,
    ownerId:
        map['ownerId'] as String? ??
        ((map['memberIds'] as List?)?.firstOrNull as String? ?? ''),
    memberIds: (map['memberIds'] as List<Object?>? ?? const [])
        .whereType<String>()
        .toList(),
    createdAt: map['createdAt'] as String,
    updatedAt: map['updatedAt'] as String,
    lastMessage: map['lastMessage'] as String? ?? '',
    isGroup: map['isGroup'] as bool? ?? true,
  );
}
