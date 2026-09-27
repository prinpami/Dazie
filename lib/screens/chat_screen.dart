import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_composer.dart';

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
  late final Stream<List<ChatMessage>> _messagesStream;

  @override
  void initState() {
    super.initState();
    _messagesStream = widget.services.messages.watchMessages(widget.groupId);
  }

  Future<void> _addMessage(String text) async {
    final profile = await widget.services.profiles.getCurrentProfile();
    if (!mounted) return;
    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Create a local profile before messaging.'),
        ),
      );
      return;
    }
    await widget.services.chatSync.sendMessage(
      groupId: widget.groupId,
      text: text,
      profile: profile,
    );
  }

  void _openCompass() {
    Navigator.pushNamed(
      context,
      '/compass',
      arguments: widget.conversationTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final connectionNote = widget.services.nearby.isAvailable
        ? 'Saved here · queued until group members connect'
        : 'Saved on this device · Android nearby chat is not available here';

    return Scaffold(
      backgroundColor: DazieColors.darkIndigo,
      appBar: AppBar(
        backgroundColor: DazieColors.darkIndigo,
        leadingWidth: 52,
        leading: IconButton(
          tooltip: 'Back to conversations',
          onPressed: () => Navigator.maybePop(context),
          icon: Image.asset(
            'assets/images/BackButton.png',
            width: 18,
            height: 18,
          ),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 19,
              backgroundColor: DazieColors.tangerineOrange,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.conversationTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: DazieColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'Offline group chat',
                    style: TextStyle(
                      color: DazieColors.mutedText,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Open friend direction preview',
            onPressed: _openCompass,
            icon: const Icon(Icons.explore_outlined),
            color: DazieColors.tangerineOrange,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
            color: DazieColors.surface,
            child: Text(
              connectionNote,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: DazieColors.mutedText,
                fontSize: 11,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Messages are stored on this device',
              style: TextStyle(color: DazieColors.mutedText, fontSize: 11),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                final messages = snapshot.data ?? const <ChatMessage>[];
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet. Say hello!',
                      style: TextStyle(color: DazieColors.mutedText),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) =>
                      ChatBubble(message: messages[index]),
                );
              },
            ),
          ),
          ChatComposer(onSend: _addMessage),
        ],
      ),
    );
  }
}
