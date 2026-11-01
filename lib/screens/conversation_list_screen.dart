import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatters.dart';
import '../models/demo_thread.dart';
import '../routing/mono_page_route.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/mono_app_bar.dart';
import 'chat_screen.dart';

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({
    super.key,
    required this.channel,
    required this.title,
    required this.notice,
    required this.emptyLabel,
  });

  final DemoChannel channel;
  final String title;
  final String notice;
  final String emptyLabel;

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openThread(DemoThread thread) {
    Navigator.of(context).push(
      MonoPageRoute<void>(
        page: ChatScreen(channel: widget.channel, threadId: thread.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final threads = context.watch<AppState>().threadsFor(widget.channel);
    final query = _query.trim().toLowerCase();
    final visible = query.isEmpty
        ? threads
        : threads
              .where(
                (thread) =>
                    thread.name.toLowerCase().contains(query) ||
                    thread.preview.toLowerCase().contains(query),
              )
              .toList(growable: false);
    final mono = context.mono;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: MonoAppBar(
        leading: MonoBarButton(
          icon: Icons.close_rounded,
          tooltip: 'Back to BusyProMax',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: text.titleMedium?.copyWith(fontSize: 14),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 30),
          child: ContentFrame(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DemoNotice(text: widget.notice, compact: true),
                const SizedBox(height: 14),
                _SearchField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  onClear: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                ),
                if (query.isEmpty) ...[
                  const SizedBox(height: 26),
                  SectionLabel(
                    label: widget.channel == DemoChannel.direct
                        ? 'Contacts'
                        : 'Switch',
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 92,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: threads.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final thread = threads[index];
                        return _ContactShortcut(
                          thread: thread,
                          onTap: () => _openThread(thread),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 26),
                SectionLabel(
                  label: 'Threads',
                  trailing: Text('${visible.length}', style: text.labelMedium),
                ),
                const SizedBox(height: 4),
                if (visible.isEmpty)
                  _NoResults(label: widget.emptyLabel)
                else
                  for (var index = 0; index < visible.length; index++) ...[
                    _ConversationRow(
                      thread: visible[index],
                      onTap: () => _openThread(visible[index]),
                    ),
                    if (index != visible.length - 1)
                      Divider(height: 0.8, color: mono.line),
                  ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    final hasText = controller.text.isNotEmpty;

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: mono.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: mono.line, width: 0.8),
      ),
      child: TextField(
        key: const Key('conversation-search'),
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: mono.muted, fontSize: 12.5),
          prefixIcon: Icon(Icons.search_rounded, size: 19, color: mono.muted),
          suffixIcon: hasText
              ? IconButton(
                  onPressed: onClear,
                  tooltip: 'Clear search',
                  icon: Icon(Icons.close_rounded, size: 16, color: mono.muted),
                )
              : null,
        ),
      ),
    );
  }
}

class _ContactShortcut extends StatelessWidget {
  const _ContactShortcut({required this.thread, required this.onTap});

  final DemoThread thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final mono = context.mono;
    return SizedBox(
      width: 64,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('contact-${thread.id}'),
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Column(
            children: [
              MonoAvatar(initials: thread.initials, size: 56),
              const SizedBox(height: 8),
              Text(
                thread.name.split(' ').first,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: text.bodySmall?.copyWith(
                  fontSize: 10.5,
                  color: mono.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversationRow extends StatelessWidget {
  const _ConversationRow({required this.thread, required this.onTap});

  final DemoThread thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    final text = Theme.of(context).textTheme;
    final last = thread.lastMessage;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('thread-${thread.id}'),
        onTap: onTap,
        splashColor: mono.ink.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              MonoAvatar(initials: thread.initials, size: 52),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            thread.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleMedium?.copyWith(
                              fontSize: 14,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          last == null ? '' : formatRelativeTime(last.sentAt),
                          style: text.bodySmall?.copyWith(
                            fontSize: 10.5,
                            color: mono.muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      thread.preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(
                        fontSize: 12,
                        height: 1.4,
                        color: mono.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, size: 19, color: mono.line),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 34),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 28, color: mono.muted),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: mono.muted),
            ),
          ],
        ),
      ),
    );
  }
}
