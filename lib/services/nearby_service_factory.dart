import 'package:flutter/foundation.dart';

import 'android_nearby_service.dart';
import 'demo_nearby_service.dart';
import 'nearby_service.dart';

NearbyService createNearbyService() {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return AndroidNearbyService();
  }
  return DemoNearbyService();
}
