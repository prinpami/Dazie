import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';

import '../models/chat_message.dart';
import '../theme/app_theme.dart';

class ChatBubble extends StatefulWidget {
  const ChatBubble({super.key, required this.message, this.onDelete});

  final ChatMessage message;
  final VoidCallback? onDelete;

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool _focusVisible = false;
  ChatMessage get message => widget.message;
  VoidCallback? get onDelete => widget.onDelete;

  @override
  Widget build(BuildContext context) {
    final color = message.isMine
        ? DazieColors.tangerineOrange
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    final textColor = message.isMine
        ? DazieColors.darkIndigo
        : Theme.of(context).colorScheme.onSurface;

    void options() {
      showModalBottomSheet<void>(
        context: context,
        builder: (sheetContext) => SafeArea(
          child: ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Delete message on this device'),
            onTap: () {
              Navigator.pop(sheetContext);
              onDelete?.call();
            },
          ),
        ),
      );
    }

    return Semantics(
      customSemanticsActions: onDelete == null
          ? null
          : {const CustomSemanticsAction(label: 'Message options'): options},
      child: FocusableActionDetector(
        onShowFocusHighlight: (visible) =>
            setState(() => _focusVisible = visible),
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              if (onDelete != null) options();
              return null;
            },
          ),
        },
        child: GestureDetector(
          onLongPress: onDelete == null ? null : options,
          onSecondaryTap: onDelete == null ? null : options,
          child: Align(
            alignment: message.isMine
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.76,
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.fromLTRB(14, 9, 12, 7),
                decoration: BoxDecoration(
                  color: color,
                  border: _focusVisible
                      ? Border.all(
                          color: Theme.of(context).colorScheme.onSurface,
                          width: 2,
                        )
                      : null,
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
                            color: textColor,
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
                      message.isMine
                          ? '${message.time} · ${message.deliveryLabel}'
                          : message.time,
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.85),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
