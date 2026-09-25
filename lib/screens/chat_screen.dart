import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_composer.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.conversationTitle,
    required this.displayName,
  });

  final String conversationTitle;
  final String displayName;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messages = <ChatMessage>[
    const ChatMessage(
      sender: 'Jordan',
      text: 'Are we meeting at the trail entrance?',
      time: '7:35 pm',
      isMine: false,
    ),
    const ChatMessage(
      sender: 'You',
      text: 'Yes, I will be there by eight.',
      time: '7:36 pm',
      isMine: true,
    ),
    const ChatMessage(
      sender: 'Mia',
      text: 'I can bring water for everyone.',
      time: '7:37 pm',
      isMine: false,
    ),
  ];

  bool get _isGroup =>
      widget.conversationTitle.toLowerCase().contains('gc') ||
      widget.conversationTitle.toLowerCase().contains('group');

  void _addLocalMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage(
          sender: widget.displayName,
          text: text,
          time: 'Now',
          isMine: true,
        ),
      );
    });
  }

  void _openCompass() {
    Navigator.pushNamed(context, '/compass', arguments: 'Jordan');
  }

  @override
  Widget build(BuildContext context) {
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
                  Text(
                    _isGroup ? '4 members · demo' : 'Conversation preview',
                    style: const TextStyle(
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
            padding: const EdgeInsets.symmetric(vertical: 7),
            color: DazieColors.surface,
            child: const Text(
              'Local demo · messages stay on this device',
              textAlign: TextAlign.center,
              style: TextStyle(color: DazieColors.mutedText, fontSize: 11),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Today',
              style: TextStyle(color: DazieColors.mutedText, fontSize: 11),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) =>
                  ChatBubble(message: _messages[index]),
            ),
          ),
          ChatComposer(onSend: _addLocalMessage),
        ],
      ),
    );
  }
}
