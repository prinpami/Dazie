import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.displayName});

  final String displayName;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _searchText = '';

  // These sample conversations let us present the layout before chat storage exists.
  static const _conversations = <_ConversationPreview>[
    _ConversationPreview('Taylor Morgan', 'You sent a photo.', '7:38 pm'),
    _ConversationPreview(
      'Group Chat Placeholder',
      '25 new messages',
      '6:38 pm',
      isUnread: true,
    ),
    _ConversationPreview('Friend', 'Friend: Come here.', '7:38 pm'),
    _ConversationPreview('Different Friend', 'You sent a photo.', '7:38 pm'),
    _ConversationPreview(
      'Different Different Friend',
      'DiffDiffriend: bruhh wha',
      '7:38 pm',
    ),
    _ConversationPreview(
      'Somebody I Used To Know',
      'You: I miss you, balik kana',
      '7:38 pm',
    ),
    _ConversationPreview(
      'Family GC',
      '2 new messages',
      '7:38 pm',
      isUnread: true,
    ),
    _ConversationPreview(
      'Placeholder Friend',
      'Placeholder Friend: hehe',
      '7:38 pm',
    ),
    _ConversationPreview(
      'Study Group',
      'Jordan: see you at 8',
      '7:38 pm',
    ),
    _ConversationPreview('Hiking Trip', 'Taylor: ggs ang ng trip', '7:38 pm'),
  ];

  List<_ConversationPreview> get _visibleConversations {
    final query = _searchText.trim().toLowerCase();
    if (query.isEmpty) return _conversations;
    return _conversations
        .where(
          (conversation) => conversation.name.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showPreviewMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openSettings() {
    Navigator.pushNamed(context, '/settings', arguments: widget.displayName);
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
                Expanded(child: _buildMessages()),
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
                onTap: () => _showPreviewMessage(
                  'Nearby discovery will be added in a later checkpoint.',
                ),
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
              onPressed: () => _showPreviewMessage(
                'Creating a chat will be added in a later checkpoint.',
              ),
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

  Widget _buildMessages() {
    final conversations = _visibleConversations;

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
              ? const Center(
                  child: Text(
                    'No conversations found',
                    style: TextStyle(color: DazieColors.mutedText),
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
                      onTap: () => _showPreviewMessage(
                        'The chat screen is planned for a later checkpoint.',
                      ),
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

class _ConversationPreview {
  const _ConversationPreview(
    this.name,
    this.preview,
    this.time, {
    this.isUnread = false,
  });

  final String name;
  final String preview;
  final String time;
  final bool isUnread;
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation, required this.onTap});

  final _ConversationPreview conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontSize: 15,
      fontWeight: conversation.isUnread ? FontWeight.w800 : FontWeight.w600,
    );

    return InkWell(
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
                      conversation.preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: DazieColors.mutedText,
                        fontSize: 14,
                        fontWeight: conversation.isUnread
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 44,
                child: Text(
                  conversation.time,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
