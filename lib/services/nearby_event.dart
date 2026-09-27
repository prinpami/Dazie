enum NearbyEventType {
  peerFound,
  peerLost,
  connectionRequest,
  connected,
  disconnected,
  packet,
}

class NearbyEvent {
  const NearbyEvent({
    required this.type,
    required this.endpointId,
    this.name = '',
    this.authenticationToken = '',
    this.packet,
  });

  final NearbyEventType type;
  final String endpointId;
  final String name;
  final String authenticationToken;
  final Map<String, Object?>? packet;
}
