import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/app_services.dart';
import '../services/nearby_failure.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_composer.dart';
import '../widgets/confirm_local_delete.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.groupId,
    required this.conversationTitle,
    required this.services,
  });
  final String groupId;
  final String conversationTitle;
  final AppServices services;
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Stream<List<ChatMessage>> _messages;
  bool _working = false;
  @override
  void initState() {
    super.initState();
    _messages = widget.services.messages.watchMessages(widget.groupId);
  }

  Future<void> _send(String text) async {
    final profile = await widget.services.profiles.getCurrentProfile();
    if (profile == null) throw StateError('Create a profile first.');
    await widget.services.chatSync.sendMessage(
      groupId: widget.groupId,
      text: text,
      profile: profile,
    );
  }

  Future<void> _action(Future<void> Function() action) async {
    if (_working) return;
    setState(() => _working = true);
    try {
      await action();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(NearbyFailure.from(error).message)),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _deleteChat() async {
    if (!await confirmLocalDelete(context, chat: true) || !mounted) return;
    await _action(() async {
      await widget.services.chatSync.deleteConversation(widget.groupId);
      if (mounted) Navigator.pop(context);
    });
  }

  Future<void> _deleteMessage(ChatMessage message) async {
    if (!await confirmLocalDelete(context, chat: false) || !mounted) return;
    await _action(() => widget.services.messages.deleteMessage(message.id));
  }

  Future<void> _reconnect() => _action(() async {
    final profile = await widget.services.profiles.getCurrentProfile();
    final group = await widget.services.conversations.getConversation(
      widget.groupId,
    );
    if (profile == null || group == null || !mounted) return;
    final sync = widget.services.chatSync;
    if (sync.activeConversation?.id == group.id && !sync.isHosting) {
      await sync.stopNearby();
    }
    if (sync.hasSession && sync.activeConversation?.id != group.id) {
      throw const NearbyFailure('Leave your other nearby connection first.');
    }
    if (group.ownerId == profile.id) {
      await sync.startGroup(group.name, profile);
    } else {
      if (mounted) {
        Navigator.pushNamed(context, '/discover', arguments: profile.username);
      }
    }
  });
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.services.chatSync,
    builder: (context, _) {
      final sync = widget.services.chatSync;
      final count = sync.connectionCount(widget.groupId);
      final active = sync.activeConversation?.id == widget.groupId;
      final hosting = active && sync.isHosting;
      final note = count > 0
          ? 'Connected · $count nearby ${count == 1 ? 'device' : 'devices'}'
          : hosting
          ? 'Hosting · waiting for members'
          : 'Disconnected · new messages will wait for reconnection';
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.conversationTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            PopupMenuButton<String>(
              tooltip: 'Chat options',
              onSelected: (value) {
                if (value == 'delete') _deleteChat();
                if (value == 'leave') _action(sync.stopNearby);
              },
              itemBuilder: (_) => [
                if (active)
                  PopupMenuItem(
                    value: 'leave',
                    enabled: !_working && !sync.isBusy,
                    child: Text(hosting ? 'Stop hosting' : 'Leave connection'),
                  ),
                PopupMenuItem(
                  value: 'delete',
                  enabled: !_working && !sync.isBusy,
                  child: const Text('Delete chat'),
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => Column(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight * 0.35,
                  ),
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text(note, textAlign: TextAlign.center),
                          TextButton(
                            onPressed: () => showDialog<void>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text(
                                  'Delivery and recent history',
                                ),
                                content: const SingleChildScrollView(
                                  child: Text(
                                    'Waiting to send: saved locally; no successful send yet.\n\nSent to a nearby device: the transport accepted a send to at least one connected device.\n\nConfirmed by a nearby device: at least one peer acknowledged it, or returned a copy. This may be only the host, not every member, and does not mean it was read.\n\nJoining a group receives the host’s latest 50 saved messages, plus pending retries. Older history may be missing.\n\nLong press a message for local deletion. Keyboard: focus a message and press Enter.',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            ),
                            child: const Text('Delivery & recent history'),
                          ),
                          if (count == 0 &&
                              !hosting &&
                              widget.services.nearby.isAvailable)
                            TextButton(
                              onPressed: _working || sync.isBusy
                                  ? null
                                  : _reconnect,
                              child: const Text('Reconnect group'),
                            ),
                          if (sync.error != null)
                            Text(
                              sync.error!.message,
                              style: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<ChatMessage>>(
                    stream: _messages,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Could not load messages. Please try again.',
                                  textAlign: TextAlign.center,
                                ),
                                TextButton(
                                  onPressed: () => setState(() {
                                    _messages = widget.services.messages
                                        .watchMessages(widget.groupId);
                                  }),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            semanticsLabel: 'Loading messages',
                          ),
                        );
                      }
                      final messages = snapshot.data ?? [];
                      if (messages.isEmpty) {
                        return const Center(
                          child: Text('No messages yet. Say hello!'),
                        );
                      }
                      return ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[messages.length - index - 1];
                          return ChatBubble(
                            key: ValueKey(message.id),
                            message: message,
                            onDelete: _working
                                ? null
                                : () => _deleteMessage(message),
                          );
                        },
                      );
                    },
                  ),
                ),
                ChatComposer(onSend: _send),
              ],
            ),
          ),
        ),
      );
    },
  );
}
