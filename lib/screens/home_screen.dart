import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
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
  int _selectedTab = 0;

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
      'DiffDiffriend: bluhh wha',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: _selectedTab == 0 ? _buildMessages() : _buildNearby(),
            ),
            NavigationBar(
              selectedIndex: _selectedTab,
              onDestinationSelected: (index) {
                setState(() => _selectedTab = index);
              },
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.chat_bubble_outline_rounded),
                  selectedIcon: Icon(Icons.chat_bubble_rounded),
                  label: 'Chats',
                ),
                NavigationDestination(
                  icon: Image.asset(
                    'assets/images/Discovery.png',
                    width: 22,
                    height: 22,
                    semanticLabel: 'Nearby discovery',
                  ),
                  selectedIcon: Image.asset(
                    'assets/images/RadarButton.png',
                    width: 22,
                    height: 22,
                    semanticLabel: 'Nearby discovery selected',
                  ),
                  label: 'Nearby',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/DAZIE.png',
            width: 78,
            height: 26,
            fit: BoxFit.contain,
            semanticLabel: 'Dazie',
          ),
          const Spacer(),
          PopupMenuButton<String>(
            tooltip: 'Profile options',
            onSelected: (value) {
              if (value == 'signout') {
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'signout', child: Text('Sign out')),
            ],
            child: Row(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 108),
                  child: Text(
                    widget.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Image.asset(
                  'assets/images/Dropdown.png',
                  width: 16,
                  height: 16,
                  semanticLabel: 'Show profile options',
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'More options',
            onSelected: (_) =>
                _showPreviewMessage('More settings will be added later.'),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'settings', child: Text('Settings')),
              PopupMenuItem(value: 'help', child: Text('Help')),
            ],
            icon: Image.asset(
              'assets/images/HamburgerMenu.png',
              width: 22,
              height: 22,
              semanticLabel: 'More options',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    final conversations = _visibleConversations;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Your chats',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              IconButton(
                tooltip: 'Create a chat',
                onPressed: () => _showPreviewMessage(
                  'Creating a chat will be added in a later checkpoint.',
                ),
                icon: Image.asset(
                  'assets/images/Create.png',
                  width: 22,
                  height: 22,
                  semanticLabel: 'Create a chat',
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: SizedBox(
            height: 42,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchText = value),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search friends or group chats',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                filled: true,
                fillColor: DazieColors.searchPurple,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: DazieColors.white),
            ),
          ),
        ),
        Expanded(
          child: conversations.isEmpty
              ? Center(
                  child: Text(
                    'No conversations found',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.sm,
                    right: AppSpacing.sm,
                    bottom: AppSpacing.md,
                  ),
                  itemCount: conversations.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    indent: 68,
                    endIndent: AppSpacing.md,
                    color: DazieColors.line,
                  ),
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

  Widget _buildNearby() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 168,
              height: 168,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: DazieColors.midnightIndigo,
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/RadarButton.png',
                  width: 76,
                  height: 76,
                  semanticLabel: 'Dazie nearby radar',
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Find your friends nearby',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Dazie is being designed to help your group stay together when the internet is unavailable. Nearby discovery is a future checkpoint.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: DazieColors.mutedText, height: 1.5),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: () => _showPreviewMessage(
                'Nearby discovery is a visual preview for now.',
              ),
              icon: Image.asset(
                'assets/images/RadarButton.png',
                width: 18,
                height: 18,
              ),
              label: const Text('PREVIEW RADAR'),
            ),
          ],
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
          padding: const EdgeInsets.only(left: 9, right: 4),
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
