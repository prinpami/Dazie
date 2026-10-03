import 'package:flutter/material.dart';

import '../models/conversation.dart';
import '../widgets/confirm_local_delete.dart';
import '../services/nearby_failure.dart';
import '../services/app_services.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.displayName,
    required this.services,
  });

  final String displayName;
  final AppServices services;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _searchText = '';
  late final Stream<List<Conversation>> _conversationsStream;

  @override
  void initState() {
    super.initState();
    _conversationsStream = widget.services.conversations.watchConversations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openSettings() {
    Navigator.pushNamed(context, '/settings', arguments: widget.displayName);
  }

  void _openDiscovery() {
    Navigator.pushNamed(context, '/discover', arguments: widget.displayName);
  }

  void _openChat(Conversation conversation) {
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {
        'id': conversation.id,
        'title': conversation.name,
        'displayName': widget.displayName,
      },
    );
  }

  Future<void> _deleteChat(Conversation conversation) async {
    if (!await confirmLocalDelete(context, chat: true) || !mounted) return;
    try {
      await widget.services.chatSync.deleteConversation(conversation.id);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(NearbyFailure.from(error).message)),
        );
      }
    }
  }

  List<Conversation> _filterConversations(List<Conversation> conversations) {
    final query = _searchText.trim().toLowerCase();
    if (query.isEmpty) return conversations;
    return conversations
        .where(
          (conversation) => conversation.name.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DazieColors.darkIndigo,
      body: Stack(
        children: [
          SafeArea(
            top: false,
            bottom: false,
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: StreamBuilder<List<Conversation>>(
                    stream: _conversationsStream,
                    builder: (context, snapshot) => _buildMessages(
                      _filterConversations(snapshot.data ?? []),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 24,
            bottom: 31,
            child: Material(
              color: DazieColors.electricViolet,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _openDiscovery,
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Center(
                    child: Image.asset(
                      'assets/images/RadarButton.png',
                      width: 25,
                      height: 25,
                      semanticLabel: 'Discover nearby friends',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
      child: SizedBox(
        height: 22,
        child: Row(
          children: [
            Image.asset(
              'assets/images/DAZIE.png',
              width: 76,
              height: 20,
              fit: BoxFit.contain,
              semanticLabel: 'Dazie',
            ),
            const Spacer(),
            _ImageButton(
              asset: 'assets/images/Create.png',
              label: 'Create a chat',
              width: 18,
              onPressed: _openDiscovery,
            ),
            const SizedBox(width: 22),
            _ImageButton(
              asset: 'assets/images/HamburgerMenu.png',
              label: 'Open settings',
              width: 22,
              onPressed: _openSettings,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessages(List<Conversation> conversations) {
    return Column(
      children: [
        const SizedBox(height: 23),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: 28,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchText = value),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search Friends or Group Chat',
                hintStyle: const TextStyle(
                  color: Color(0xFFC7C5DD),
                  fontSize: 12,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFFD6D4E6),
                  size: 15,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 28,
                ),
                filled: true,
                fillColor: DazieColors.searchPurple,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: DazieColors.white, fontSize: 12),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: conversations.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _searchText.isEmpty
                              ? 'Your conversations will show up here.'
                              : 'No conversations found',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: DazieColors.mutedText),
                        ),
                        if (_searchText.isEmpty) ...[
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: _openDiscovery,
                            icon: const Icon(Icons.radar_rounded),
                            label: const Text('Host or join a group'),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: conversations.length,
                  itemExtent: 73,
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    return _ConversationTile(
                      conversation: conversation,
                      onTap: () => _openChat(conversation),
                      onDelete: () => _deleteChat(conversation),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ImageButton extends StatelessWidget {
  const _ImageButton({
    required this.asset,
    required this.label,
    required this.width,
    required this.onPressed,
  });

  final String asset;
  final String label;
  final double width;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: width,
          height: 22,
          child: Image.asset(asset, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.onTap,
    required this.onDelete,
  });

  final Conversation conversation;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w700,
    );
    final preview = conversation.lastMessage.isEmpty
        ? '${conversation.memberIds.length} members'
        : conversation.lastMessage;

    return InkWell(
      onLongPress: onDelete,
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 73,
        child: Padding(
          padding: const EdgeInsets.only(left: 25, right: 20),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 29,
                backgroundColor: DazieColors.tangerineOrange,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titleStyle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: DazieColors.mutedText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Chat options',
                onSelected: (_) => onDelete(),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
              SizedBox(
                width: 52,
                child: Text(
                  _timeLabel(conversation.updatedAt),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _timeLabel(String value) {
  final date = DateTime.tryParse(value)?.toLocal();
  if (date == null) return '';
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour < 12 ? 'am' : 'pm';
  return '$hour:$minute $period';
}
