import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'nearby_failure.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

import 'nearby_event.dart';
import 'nearby_packet.dart';
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
    final permissions = requiredNearbyPermissions(sdkVersion);

    final results = await permissions.request();
    if (permissions.any(
      (permission) => results[permission]?.isGranted != true,
    )) {
      throw const NearbyFailure(
        'Allow Nearby devices and, on Android 12 or earlier, precise Location in Dazie app settings.',
        openSettings: true,
      );
    }
  }

  Future<void> _prepare() async {
    await _askForPermissions();
    final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
    final state = await const MethodChannel(
      'dazie/device_readiness',
    ).invokeMapMethod<String, dynamic>('check');
    if (state == null) {
      throw const NearbyFailure(
        'Could not check this phone. Restart Dazie and try again.',
      );
    }
    if (state['playServices'] != true) {
      throw const NearbyFailure(
        'Nearby chat requires Google Play services. Enable or update Google Play services on this phone.',
      );
    }
    if (state['bluetoothSupported'] != true) {
      throw const NearbyFailure(
        'This device does not support Bluetooth nearby connections.',
      );
    }
    if (state['bluetooth'] != true || state['wifi'] != true) {
      throw const NearbyFailure(
        'Turn on Bluetooth and Wi-Fi, then try again. No internet connection is needed.',
      );
    }
    if (sdk <= 32 && state['preciseLocation'] != true) {
      throw const NearbyFailure(
        'Allow precise Location in Dazie app settings to find nearby phones on this Android version.',
        openSettings: true,
      );
    }
    if (sdk <= 32 && state['location'] != true) {
      throw const NearbyFailure(
        'Turn on Location in your phone settings, then try again. Android requires it for nearby discovery.',
      );
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
    } else {
      _connectedEndpoints.remove(endpointId);
      _events.add(
        NearbyEvent(
          type: NearbyEventType.connectionFailed,
          endpointId: endpointId,
          message:
              'Connection was declined or failed. Keep both phones nearby and try again.',
        ),
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
          final decoded = NearbyPacket.decode(payload.bytes!);
          if (decoded != null) {
            _events.add(
              NearbyEvent(
                type: NearbyEventType.packet,
                endpointId: receivedEndpointId,
                packet: decoded,
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
    await _prepare();
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
    await _prepare();
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
    await _prepare();
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
  Future<void> disconnect(String endpointId) async {
    await _nearby.disconnectFromEndpoint(endpointId);
    _connectedEndpoints.remove(endpointId);
  }

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
    if (bytes.length > NearbyPacket.maxBytes) {
      throw ArgumentError('This message is too large to send nearby.');
    }
    await _nearby.sendBytesPayload(endpointId, bytes);
  }

  @override
  Future<void> stop() async {
    Object? failure;
    // Try every cleanup even if one radio operation fails.
    for (final stop in [
      _nearby.stopAdvertising,
      _nearby.stopDiscovery,
      _nearby.stopAllEndpoints,
    ]) {
      try {
        await stop();
      } catch (error) {
        failure ??= error;
      }
    }
    if (failure != null) throw failure;
    _connectedEndpoints.clear();
  }
}

/// Android 13 moved Wi-Fi discovery to Nearby devices; Android 12L still needs Location.
List<Permission> requiredNearbyPermissions(int sdk) => [
  if (sdk >= 31) ...[
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.bluetoothAdvertise,
  ],
  if (sdk >= 33) Permission.nearbyWifiDevices else Permission.locationWhenInUse,
];
