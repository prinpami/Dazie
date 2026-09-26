import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ChatComposer extends StatefulWidget {
  const ChatComposer({super.key, required this.onSend});

  final ValueChanged<String> onSend;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: 'Message',
                isDense: true,
                filled: true,
                fillColor: DazieColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: DazieColors.white, fontSize: 14),
            ),
          ),
          const SizedBox(width: 9),
          Material(
            color: DazieColors.tangerineOrange,
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: 'Send message on this device',
              onPressed: _send,
              icon: const Icon(Icons.arrow_upward_rounded),
              color: DazieColors.darkIndigo,
            ),
          ),
        ],
      ),
    );
  }
}
