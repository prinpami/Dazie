import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

import 'nearby_event.dart';
import 'nearby_service.dart';

class AndroidNearbyService implements NearbyService {
  final Nearby _nearby = Nearby();
  final StreamController<NearbyEvent> _events =
      StreamController<NearbyEvent>.broadcast();
  final Set<String> _connectedEndpoints = {};

  static const _serviceId = 'com.example.dazie';

  @override
  Stream<NearbyEvent> get events => _events.stream;

  @override
  List<String> get connectedEndpointIds => _connectedEndpoints.toList();

  @override
  bool get isAvailable => true;

  Future<void> _askForPermissions() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkVersion = androidInfo.version.sdkInt;
    final List<Permission> permissions;

    if (sdkVersion >= 33) {
      permissions = [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.nearbyWifiDevices,
      ];
    } else if (sdkVersion >= 31) {
      permissions = [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.locationWhenInUse,
      ];
    } else {
      permissions = [Permission.bluetooth, Permission.locationWhenInUse];
    }

    final results = await permissions.request();
    if (results.values.any((result) => !result.isGranted)) {
      throw StateError('Nearby permissions were not granted.');
    }
  }

  void _onConnectionInitiated(String endpointId, ConnectionInfo info) {
    _events.add(
      NearbyEvent(
        type: NearbyEventType.connectionRequest,
        endpointId: endpointId,
        name: info.endpointName,
        authenticationToken: info.authenticationToken,
      ),
    );
  }

  void _onConnectionResult(String endpointId, Status status) {
    if (status == Status.CONNECTED) {
      _connectedEndpoints.add(endpointId);
      _events.add(
        NearbyEvent(type: NearbyEventType.connected, endpointId: endpointId),
      );
    }
  }

  void _onDisconnected(String endpointId) {
    _connectedEndpoints.remove(endpointId);
    _events.add(
      NearbyEvent(type: NearbyEventType.disconnected, endpointId: endpointId),
    );
  }

  Future<void> _acceptConnection(String endpointId) async {
    final accepted = await _nearby.acceptConnection(
      endpointId,
      onPayLoadRecieved: (receivedEndpointId, payload) {
        if (payload.type != PayloadType.BYTES || payload.bytes == null) return;
        try {
          final decoded = jsonDecode(utf8.decode(payload.bytes!));
          if (decoded is Map) {
            _events.add(
              NearbyEvent(
                type: NearbyEventType.packet,
                endpointId: receivedEndpointId,
                packet: Map<String, Object?>.from(decoded),
              ),
            );
          }
        } catch (_) {
          // Ignore a damaged or unsupported message packet.
        }
      },
    );
    if (!accepted) throw StateError('The nearby connection was not accepted.');
  }

  @override
  Future<void> startHosting(String displayName) async {
    await _askForPermissions();
    final started = await _nearby.startAdvertising(
      displayName,
      Strategy.P2P_CLUSTER,
      onConnectionInitiated: _onConnectionInitiated,
      onConnectionResult: _onConnectionResult,
      onDisconnected: _onDisconnected,
      serviceId: _serviceId,
    );
    if (!started) throw StateError('Could not start nearby advertising.');
  }

  @override
  Future<void> startFinding(String displayName) async {
    await _askForPermissions();
    final started = await _nearby.startDiscovery(
      displayName,
      Strategy.P2P_CLUSTER,
      onEndpointFound: (endpointId, endpointName, serviceId) {
        if (serviceId != _serviceId) return;
        _events.add(
          NearbyEvent(
            type: NearbyEventType.peerFound,
            endpointId: endpointId,
            name: endpointName,
          ),
        );
      },
      onEndpointLost: (endpointId) {
        if (endpointId == null) return;
        _events.add(
          NearbyEvent(type: NearbyEventType.peerLost, endpointId: endpointId),
        );
      },
      serviceId: _serviceId,
    );
    if (!started) throw StateError('Could not start nearby discovery.');
  }

  @override
  Future<void> stopFinding() => _nearby.stopDiscovery();

  @override
  Future<void> connect(String endpointId, String displayName) async {
    await _nearby.stopDiscovery();
    final started = await _nearby.requestConnection(
      displayName,
      endpointId,
      onConnectionInitiated: _onConnectionInitiated,
      onConnectionResult: _onConnectionResult,
      onDisconnected: _onDisconnected,
    );
    if (!started) throw StateError('Could not request the nearby connection.');
  }

  @override
  Future<void> accept(String endpointId) => _acceptConnection(endpointId);

  @override
  Future<void> reject(String endpointId) async {
    await _nearby.rejectConnection(endpointId);
  }

  @override
  Future<void> sendPacket(
    String endpointId,
    Map<String, Object?> packet,
  ) async {
    final bytes = Uint8List.fromList(utf8.encode(jsonEncode(packet)));
    if (bytes.length > 30000) {
      throw ArgumentError('This message is too large to send nearby.');
    }
    await _nearby.sendBytesPayload(endpointId, bytes);
  }

  @override
  Future<void> stop() async {
    await _nearby.stopAdvertising();
    await _nearby.stopDiscovery();
    await _nearby.stopAllEndpoints();
    _connectedEndpoints.clear();
  }
}
