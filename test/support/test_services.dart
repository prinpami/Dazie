import 'dart:async';
import 'package:dazie/services/app_services.dart';
import 'package:dazie/services/nearby_event.dart';
import 'package:dazie/services/nearby_service.dart';
import 'package:sembast/sembast_memory.dart';

class FakeNearby implements NearbyService {
  final controller = StreamController<NearbyEvent>.broadcast();
  final connected = <String>[];
  final sent = <({String endpoint, Map<String, Object?> packet})>[];
  final accepted = <String>[];
  final rejected = <String>[];
  Object? hostingError;
  Completer<void>? hostingGate;
  int hostingCalls = 0;
  int findingCalls = 0;
  bool available = true;
  void Function(String, Map<String, Object?>)? deliver;
  @override
  bool get isAvailable => available;
  @override
  Stream<NearbyEvent> get events => controller.stream;
  @override
  List<String> get connectedEndpointIds => connected.toList();
  void emit(NearbyEvent event) {
    if (event.type == NearbyEventType.connected &&
        !connected.contains(event.endpointId)) {
      connected.add(event.endpointId);
    }
    if (event.type == NearbyEventType.disconnected ||
        event.type == NearbyEventType.connectionFailed) {
      connected.remove(event.endpointId);
    }
    controller.add(event);
  }

  @override
  Future<void> startHosting(String displayName) async {
    hostingCalls++;
    if (hostingGate != null) await hostingGate!.future;
    if (hostingError != null) throw hostingError!;
  }

  @override
  Future<void> startFinding(String displayName) async {
    findingCalls++;
  }

  @override
  Future<void> stopFinding() async {}
  @override
  Future<void> connect(String endpointId, String displayName) async {}
  @override
  Future<void> accept(String endpointId) async {
    accepted.add(endpointId);
  }

  @override
  Future<void> reject(String endpointId) async {
    rejected.add(endpointId);
  }

  @override
  Future<void> disconnect(String endpointId) async {
    emit(
      NearbyEvent(type: NearbyEventType.disconnected, endpointId: endpointId),
    );
  }

  @override
  Future<void> sendPacket(
    String endpointId,
    Map<String, Object?> packet,
  ) async {
    sent.add((endpoint: endpointId, packet: packet));
    deliver?.call(endpointId, packet);
  }

  @override
  Future<void> stop() async {
    connected.clear();
  }
}

int _databaseId = 0;
Future<AppServices> testServices({FakeNearby? nearby}) async {
  disableSembastCooperator();
  final services = await AppServices.open(
    testDatabasePath: 'test-${_databaseId++}',
    testDatabaseFactory: newDatabaseFactoryMemory(),
    nearbyService: nearby ?? FakeNearby(),
  );
  return services;
}

Future<void> settleEvents() async {
  for (var i = 0; i < 30; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}
