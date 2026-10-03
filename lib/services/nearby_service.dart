import 'nearby_event.dart';

abstract class NearbyService {
  Stream<NearbyEvent> get events;
  List<String> get connectedEndpointIds;
  bool get isAvailable;

  Future<void> startHosting(String displayName);
  Future<void> startFinding(String displayName);
  Future<void> stopFinding();
  Future<void> connect(String endpointId, String displayName);
  Future<void> accept(String endpointId);
  Future<void> reject(String endpointId);
  Future<void> disconnect(String endpointId);
  Future<void> sendPacket(String endpointId, Map<String, Object?> packet);
  Future<void> stop();
}
