import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatters.dart';
import '../models/demo_thread.dart';
import '../routing/mono_page_route.dart';
import '../services/ai_chat_service.dart';
import '../services/ai_key_store.dart';
import '../services/local_reply_engine.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_token_sheet.dart';
import '../widgets/common.dart';
import '../widgets/mono_app_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.channel, required this.threadId});

  final DemoChannel channel;
  final String threadId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _composer = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  final _aiService = AiChatService();

  String? _token;
  bool _checkingAi = true;
  bool _replying = false;
  String? _replyError;

  bool get _aiReady => _token != null && _token!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocus);
    unawaited(_loadToken());
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    _focusNode.dispose();
    _composer.dispose();
    _scrollController.dispose();
    _aiService.dispose();
    super.dispose();
  }

  Future<void> _loadToken() async {
    final token = await AiKeyStore.read();
    if (!mounted) return;
    setState(() {
      _token = token;
      _checkingAi = false;
    });
  }

  Future<void> _openAiSetup() async {
    final changed = await showHuggingFaceTokenSheet(
      context,
      hasToken: _aiReady,
    );
    if (!mounted) return;
    if (changed) {
      await _loadToken();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              _aiReady ? 'AI replies are ready.' : 'AI replies are off.',
            ),
          ),
        );
    }
  }

  void _handleFocus() {
    if (!_focusNode.hasFocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (!mounted || !_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _send() async {
    if (_replying) return;
    final value = _composer.text.trim();
    if (value.isEmpty) return;

    final appState = context.read<AppState>();
    appState.sendMessage(widget.threadId, value);
    _composer.clear();
    setState(() {
      _replying = true;
      _replyError = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    final thread = appState.threadById(widget.threadId);
    if (thread == null) {
      if (mounted) setState(() => _replying = false);
      return;
    }

    try {
      final token = _token ?? await AiKeyStore.read();
      if (!mounted) return;

      if (token != null && token.isNotEmpty) {
        if (_token != token) {
          setState(() => _token = token);
        }
        final answer = await _aiService.reply(
          token: token,
          thread: thread,
          transcript: List<DemoMessage>.of(thread.messages),
        );
        if (!mounted) return;
        appState.addReply(
          widget.threadId,
          answer,
          source: DemoMessageSource.ai,
        );
      } else {
        if (_token != null) {
          setState(() => _token = null);
        }
        await Future<void>.delayed(const Duration(milliseconds: 650));
        if (!mounted) return;
        appState.addReply(
          widget.threadId,
          LocalReplyEngine.replyFor(thread, value),
          source: DemoMessageSource.local,
        );
      }
    } on AiChatException catch (error) {
      if (mounted) setState(() => _replyError = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _replyError = 'AI reply failed. Try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _replying = false);
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    }
  }

  void _selectThread(DemoThread thread) {
    Navigator.of(context).pop();
    if (thread.id == widget.threadId) return;
    Navigator.of(context).pushReplacement(
      MonoPageRoute<void>(
        page: ChatScreen(channel: widget.channel, threadId: thread.id),
      ),
    );
  }

  Future<void> _openSwitcher() async {
    final threads = context.read<AppState>().threadsFor(widget.channel);
    final mono = context.mono;
    final text = Theme.of(context).textTheme;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.7,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Switch thread',
                    style: text.headlineSmall?.copyWith(fontSize: 26),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: mono.line, width: 0.8),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        for (
                          var index = 0;
                          index < threads.length;
                          index++
                        ) ...[
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              key: Key('switch-${threads[index].id}'),
                              onTap: () => _selectThread(threads[index]),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    MonoAvatar(
                                      initials: threads[index].initials,
                                      size: 38,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            threads[index].name,
                                            style: text.titleMedium?.copyWith(
                                              fontSize: 13.5,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            threads[index].preview,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: text.bodySmall?.copyWith(
                                              fontSize: 10.5,
                                              color: mono.muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (threads[index].id == widget.threadId)
                                      Icon(
                                        Icons.check_rounded,
                                        size: 18,
                                        color: mono.ink,
                                      )
                                    else
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        size: 18,
                                        color: mono.muted,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (index != threads.length - 1)
                            Divider(
                              height: 0.8,
                              indent: 14,
                              endIndent: 14,
                              color: mono.line,
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final thread = context.watch<AppState>().threadById(widget.threadId);
    final mono = context.mono;
    final text = Theme.of(context).textTheme;

    if (thread == null) {
      return Scaffold(
        appBar: MonoAppBar(
          leading: MonoBarButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Demo thread'),
        ),
        body: Center(
          child: Text(
            'This thread is gone.',
            style: text.bodyMedium?.copyWith(color: mono.muted),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: MonoAppBar(
        leading: MonoBarButton(
          icon: Icons.arrow_back_rounded,
          tooltip: 'Back to threads',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: AppTitle(
          title: thread.name,
          subtitle: _aiReady ? 'AI demo' : 'Local demo',
          leading: MonoAvatar(initials: thread.initials, size: 34),
        ),
        actions: [
          MonoBarButton(
            key: const Key('switch-conversation'),
            icon: Icons.swap_horiz_rounded,
            tooltip: 'Switch demo thread',
            onPressed: _openSwitcher,
          ),
          MonoBarButton(
            key: const Key('ai-settings'),
            icon: _aiReady
                ? Icons.auto_awesome_rounded
                : Icons.auto_awesome_outlined,
            tooltip: _aiReady ? 'AI reply settings' : 'Turn on AI replies',
            onPressed: _openAiSetup,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              itemCount: thread.messages.length + (_replying ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= thread.messages.length) {
                  return const _TypingBubble();
                }
                return _DemoBubble(
                  message: thread.messages[index],
                  channel: widget.channel,
                );
              },
            ),
          ),
          if (_replyError != null)
            _ReplyError(
              message: _replyError!,
              onDismiss: () => setState(() => _replyError = null),
            ),
          _Composer(
            controller: _composer,
            focusNode: _focusNode,
            channel: widget.channel,
            onSend: _send,
            replying: _replying,
            checkingAi: _checkingAi,
            aiReady: _aiReady,
            onAiSetup: _openAiSetup,
          ),
        ],
      ),
    );
  }
}

class _DemoBubble extends StatelessWidget {
  const _DemoBubble({required this.message, required this.channel});

  final DemoMessage message;
  final DemoChannel channel;

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    final isMine = message.isMine;
    final radius = channel == DemoChannel.direct ? 20.0 : 15.0;
    final maxWidth = MediaQuery.sizeOf(context).width * 0.76;
    final sourceLabel = switch (message.source) {
      DemoMessageSource.sample => null,
      DemoMessageSource.local => 'LOCAL SAMPLE',
      DemoMessageSource.ai => 'AI REPLY',
    };
    final showSource = !isMine && sourceLabel != null;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth > 520 ? 520 : maxWidth),
        margin: const EdgeInsets.only(bottom: 13),
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: isMine ? mono.inverse : mono.surface,
                border: isMine
                    ? null
                    : Border.all(color: mono.line, width: 0.8),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(radius),
                  topRight: Radius.circular(radius),
                  bottomLeft: Radius.circular(isMine ? radius : 4),
                  bottomRight: Radius.circular(isMine ? 4 : radius),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isMine ? mono.onInverse : mono.ink,
                  fontSize: 13.5,
                  height: 1.42,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              showSource
                  ? '${formatClock(context, message.sentAt)}  ·  $sourceLabel'
                  : formatClock(context, message.sentAt),
              style: TextStyle(
                color: mono.muted,
                fontSize: showSource ? 7.5 : 9,
                letterSpacing: showSource ? 0.8 : 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        key: const Key('ai-typing'),
        margin: const EdgeInsets.only(bottom: 13),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: mono.surface,
          border: Border.all(color: mono.line, width: 0.8),
          borderRadius: BorderRadius.circular(18),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var index = 0; index < 3; index++) ...[
                  if (index > 0) const SizedBox(width: 4),
                  Opacity(
                    opacity:
                        0.25 +
                        0.75 *
                            (0.5 +
                                0.5 *
                                    (1 -
                                        (_controller.value * 3 - index)
                                            .abs()
                                            .clamp(0, 1))),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: mono.ink,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReplyError extends StatelessWidget {
  const _ReplyError({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
      decoration: BoxDecoration(
        color: mono.surface,
        border: Border.all(color: mono.line, width: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, size: 14, color: mono.muted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(fontSize: 10.5, height: 1.4, color: mono.muted),
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            tooltip: 'Dismiss',
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.close_rounded, size: 15, color: mono.muted),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.channel,
    required this.onSend,
    required this.replying,
    required this.checkingAi,
    required this.aiReady,
    required this.onAiSetup,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final DemoChannel channel;
  final Future<void> Function() onSend;
  final bool replying;
  final bool checkingAi;
  final bool aiReady;
  final VoidCallback onAiSetup;

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    final text = Theme.of(context).textTheme;

    final status = checkingAi
        ? 'CHECKING…'
        : aiReady
        ? 'AI DEMO'
        : 'LOCAL SAMPLE';

    return Container(
      decoration: BoxDecoration(
        color: mono.canvas,
        border: Border(top: BorderSide(color: mono.line, width: 0.8)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: 46,
                        maxHeight: 132,
                      ),
                      decoration: BoxDecoration(
                        color: mono.surface,
                        borderRadius: BorderRadius.circular(23),
                        border: Border.all(color: mono.line, width: 0.8),
                      ),
                      alignment: Alignment.center,
                      child: TextField(
                        key: const Key('chat-input'),
                        controller: controller,
                        focusNode: focusNode,
                        minLines: 1,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(fontSize: 13.5, height: 1.4),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: channel == DemoChannel.direct
                              ? 'Message…'
                              : 'Text…',
                          hintStyle: TextStyle(
                            color: mono.muted,
                            fontSize: 12.5,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, value, child) {
                      final enabled = value.text.trim().isNotEmpty && !replying;
                      return Semantics(
                        button: true,
                        enabled: enabled,
                        label: 'Send demo message',
                        child: Material(
                          color: enabled || replying
                              ? mono.inverse
                              : mono.surface,
                          shape: CircleBorder(
                            side: BorderSide(
                              color: enabled || replying
                                  ? Colors.transparent
                                  : mono.line,
                              width: 0.8,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            key: const Key('send-message'),
                            onTap: enabled ? onSend : null,
                            customBorder: const CircleBorder(),
                            child: SizedBox(
                              width: 46,
                              height: 46,
                              child: replying
                                  ? Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.6,
                                        color: mono.onInverse,
                                      ),
                                    )
                                  : Icon(
                                      Icons.arrow_upward_rounded,
                                      size: 19,
                                      color: enabled
                                          ? mono.onInverse
                                          : mono.muted,
                                    ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 5),
              TextButton(
                key: const Key('ai-status'),
                onPressed: onAiSetup,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 26),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.centerLeft,
                ),
                child: Text(
                  status,
                  style: text.labelMedium?.copyWith(
                    fontSize: 7.5,
                    color: mono.muted,
                    letterSpacing: 1.05,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
