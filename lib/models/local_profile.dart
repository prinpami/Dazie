class LocalProfile {
  const LocalProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
  });

  final String id;
  final String username;
  final String email;
  final String createdAt;

  Map<String, Object?> toMap() => {
    'id': id,
    'username': username,
    'email': email,
    'createdAt': createdAt,
  };

  factory LocalProfile.fromMap(Map<String, Object?> map) => LocalProfile(
    id: map['id'] as String,
    username: map['username'] as String,
    email: map['email'] as String? ?? '',
    createdAt: map['createdAt'] as String,
  );
}
