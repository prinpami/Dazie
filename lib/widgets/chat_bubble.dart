import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../theme/app_theme.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final color = message.isMine
        ? DazieColors.tangerineOrange
        : DazieColors.surface;
    final textColor = message.isMine ? DazieColors.darkIndigo : DazieColors.white;

    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.76,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.fromLTRB(14, 9, 12, 7),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(message.isMine ? 16 : 4),
              bottomRight: Radius.circular(message.isMine ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!message.isMine)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    message.sender,
                    style: TextStyle(
                      color: DazieColors.tangerineOrange,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  message.text,
                  style: TextStyle(color: textColor, fontSize: 15),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                message.time,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.65),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
