//

class PeerProfile {
  const PeerProfile({
    required this.id,
    required this.displayName,
    required this.lastSeenAt,
  });

  final String id;
  final String displayName;
  final String lastSeenAt;

  Map<String, Object?> toMap() => {
    'id': id,
    'displayName': displayName,
    'lastSeenAt': lastSeenAt,
  };

  factory PeerProfile.fromMap(Map<String, Object?> map) => PeerProfile(
    id: map['id'] as String,
    displayName: map['displayName'] as String,
    lastSeenAt: map['lastSeenAt'] as String,
  );
}
