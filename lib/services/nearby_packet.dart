import 'dart:convert';

/// Version 1 adds an envelope field without changing legacy packet payloads.
/// Unversioned (legacy) packets pass the same validation before any writes.
abstract final class NearbyPacket {
  static const version = 1;
  static const maxBytes = 30000;

  static Map<String, Object?>? decode(List<int> bytes) {
    if (bytes.length > maxBytes) return null;
    try {
      return validate(jsonDecode(utf8.decode(bytes)));
    } catch (_) {
      return null;
    }
  }

  static bool _text(Object? value, {int max = 2000}) =>
      value is String && value.trim().isNotEmpty && value.length <= max;

  static bool _timestamp(String value) {
    final parts = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(?:\.\d{1,6})?(?:Z|[+-](\d{2}):?(\d{2}))$',
    ).firstMatch(value);
    if (parts == null || DateTime.tryParse(value) == null) return false;
    final year = int.parse(parts[1]!);
    final month = int.parse(parts[2]!);
    final day = int.parse(parts[3]!);
    return month >= 1 &&
        month <= 12 &&
        day >= 1 &&
        day <= DateTime.utc(year, month + 1, 0).day &&
        int.parse(parts[4]!) < 24 &&
        int.parse(parts[5]!) < 60 &&
        int.parse(parts[6]!) < 60 &&
        (parts[7] == null ||
            (int.parse(parts[7]!) < 24 && int.parse(parts[8]!) < 60));
  }

  static Map<String, Object?>? validate(Object? raw) {
    if (raw is! Map || raw.keys.any((key) => key is! String)) return null;
    final packet = Map<String, Object?>.from(raw);
    if (packet.containsKey('version') &&
        (packet['version'] is! int || packet['version'] != version)) {
      return null;
    }
    switch (packet['type']) {
      case 'hello':
        if (!_text(packet['peerId']) || !_text(packet['displayName'])) {
          return null;
        }
      case 'group':
        final members = packet['memberIds'];
        if (!_text(packet['groupId']) ||
            !_text(packet['name']) ||
            members is! List ||
            members.isEmpty ||
            members.length > 1000 ||
            members.any((id) => !_text(id)) ||
            members.toSet().length != members.length) {
          return null;
        }
        // Older builds allowed the first member to identify the owner.
        if (packet['ownerId'] == null && !packet.containsKey('version')) {
          packet['ownerId'] = members.first;
        }
        if (!_text(packet['ownerId']) || !members.contains(packet['ownerId'])) {
          return null;
        }
      case 'message':
        final message = packet['message'];
        if (message is! Map || message.keys.any((key) => key is! String)) {
          return null;
        }
        for (final key in [
          'id',
          'groupId',
          'senderId',
          'sender',
          'text',
          'createdAt',
        ]) {
          if (!_text(message[key])) return null;
        }
        final date = message['createdAt'] as String;
        if (!_timestamp(date)) return null;
        if (message.containsKey('isMine') && message['isMine'] is! bool) {
          return null;
        }
        if (message.containsKey('deliveryStatus') &&
            ![
              'queued',
              'sent',
              'delivered',
              'received',
            ].contains(message['deliveryStatus'])) {
          return null;
        }
      case 'ack':
        if (!_text(packet['messageId'])) return null;
      default:
        return null;
    }
    return packet;
  }
}
