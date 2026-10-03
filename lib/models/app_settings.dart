/*
 * This are the settings of the app. Right now, it only contains the following:
 *  1. Active Status    =     Online Status of User if they want to show
 *  2. Appearance       =     Selects the theme of the app (Dark, Light, or based on their System)
 */

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
