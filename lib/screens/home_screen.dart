import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../widgets/dazie_logo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.displayName});

  final String displayName;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _searchText = '';

  // These sample rows make the home screen easy to show before local storage exists.
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

  @override
  Widget build(BuildContext context) {
    final conversations = _visibleConversations;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: SizedBox(
                height: 48,
                child: Row(
                  children: [
                    const DazieLogo(size: 22),
                    const Spacer(),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 135),
                      child: Text(
                        widget.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: DazieColors.tangerineOrange,
                      child: Text(
                        widget.displayName.trim().isEmpty
                            ? '?'
                            : widget.displayName.trim()[0].toUpperCase(),
                        style: const TextStyle(
                          color: DazieColors.darkIndigo,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                14,
                AppSpacing.xs,
                14,
                AppSpacing.sm,
              ),
              child: SizedBox(
                height: 36,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchText = value),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Search Friends or Group Chat',
                    hintStyle: const TextStyle(
                      color: DazieColors.white,
                      fontSize: 12,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: DazieColors.white,
                      size: 17,
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 35,
                      minHeight: 34,
                    ),
                    filled: true,
                    fillColor: DazieColors.searchPurple,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(
                    color: DazieColors.white,
                    fontSize: 12,
                  ),
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
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                      itemCount: conversations.length,
                      itemBuilder: (context, index) =>
                          _ConversationTile(conversation: conversations[index]),
                    ),
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
  const _ConversationTile({required this.conversation});

  final _ConversationPreview conversation;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontSize: 14,
      fontWeight: conversation.isUnread ? FontWeight.w800 : FontWeight.w600,
    );

    return SizedBox(
      height: 68,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: DazieColors.tangerineOrange,
            ),
            const SizedBox(width: AppSpacing.sm),
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
                  const SizedBox(height: 1),
                  Text(
                    conversation.preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: DazieColors.mutedText,
                      fontSize: 12,
                      fontWeight: conversation.isUnread
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 46,
              child: Text(
                conversation.time,
                textAlign: TextAlign.end,
                maxLines: 1,
                style: Theme.of(context).textTheme.labelSmall
                    ?.copyWith(fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
