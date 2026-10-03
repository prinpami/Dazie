import 'package:flutter/material.dart';

Future<bool> confirmLocalDelete(
  BuildContext context, {
  required bool chat,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          chat
              ? 'Delete chat on this device?'
              : 'Delete message on this device?',
        ),
        content: Text(
          chat
              ? 'This removes the chat and its messages here and leaves its active connection. Other members keep their copies.'
              : 'Other members keep their copies. This message will stay hidden here after reconnecting.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete for me'),
          ),
        ],
      ),
    ) ??
    false;
