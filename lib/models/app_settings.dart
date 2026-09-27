class AppSettings {
  const AppSettings({required this.activeStatus, required this.appearance});

  final bool activeStatus;
  final String appearance;

  static const defaults = AppSettings(activeStatus: true, appearance: 'System');

  Map<String, Object?> toMap() => {
    'activeStatus': activeStatus,
    'appearance': appearance,
  };

  factory AppSettings.fromMap(Map<String, Object?> map) => AppSettings(
    activeStatus: map['activeStatus'] as bool? ?? true,
    appearance: map['appearance'] as String? ?? 'System',
  );
}
