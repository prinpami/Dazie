enum NearbyEventType {
  peerFound,
  peerLost,
  connectionRequest,
  connected,
  disconnected,
  connectionFailed,
  packet,
}

class NearbyEvent {
  const NearbyEvent({
    required this.type,
    required this.endpointId,
    this.name = '',
    this.message = '',
    this.authenticationToken = '',
    this.packet,
  });

  final NearbyEventType type;
  final String endpointId;
  final String name;
  final String message;
  final String authenticationToken;
  final Map<String, Object?>? packet;
}
