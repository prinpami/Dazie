import 'package:flutter/services.dart';

class NearbyFailure implements Exception {
  const NearbyFailure(this.message, {this.openSettings = false});
  final String message;
  final bool openSettings;
  @override
  String toString() => message;

  static NearbyFailure from(Object error) {
    if (error is NearbyFailure) return error;
    if (error is PlatformException) {
      final detail = '${error.code} ${error.message}'.toUpperCase();
      if (detail.contains('ACCESS_WIFI_STATE') ||
          detail.contains('CHANGE_WIFI_STATE') ||
          detail.contains('8032') ||
          detail.contains('8033')) {
        return const NearbyFailure(
          'This installation is missing Wi-Fi permissions. Install the latest Dazie APK on both phones; hot reload cannot update permissions.',
        );
      }
      if (detail.contains('PERMISSION') || detail.contains('8034')) {
        return const NearbyFailure(
          'Allow Nearby devices and any requested Location permission in Dazie app settings, then retry.',
          openSettings: true,
        );
      }
      if (detail.contains('ALREADY')) {
        return const NearbyFailure(
          'A nearby session is already running. Disconnect and try again.',
        );
      }
      return const NearbyFailure(
        'Could not connect. Check Bluetooth and Wi-Fi, keep both apps open, and update Google Play services before retrying.',
      );
    }
    if (error is StateError) return NearbyFailure(error.message.toString());
    return const NearbyFailure(
      'The nearby operation could not finish. Try again.',
    );
  }
}
