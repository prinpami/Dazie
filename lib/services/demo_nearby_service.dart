import 'nearby_event.dart';
import 'nearby_service.dart';

class DemoNearbyService implements NearbyService {
  @override
  Stream<NearbyEvent> get events => const Stream.empty();

  @override
  List<String> get connectedEndpointIds => const [];

  @override
  bool get isAvailable => false;

  @override
  Future<void> accept(String endpointId) async {}

  @override
  Future<void> connect(String endpointId, String displayName) async {
    throw UnsupportedError('Nearby chat is available on Android devices.');
  }

  @override
  Future<void> disconnect(String endpointId) async {}

  @override
  Future<void> reject(String endpointId) async {}

  @override
  Future<void> sendPacket(
    String endpointId,
    Map<String, Object?> packet,
  ) async {}

  @override
  Future<void> startFinding(String displayName) async {
    throw UnsupportedError('Nearby chat is available on Android devices.');
  }

  @override
  Future<void> startHosting(String displayName) async {
    throw UnsupportedError('Nearby chat is available on Android devices.');
  }

  @override
  Future<void> stopFinding() async {}

  @override
  Future<void> stop() async {}
}
