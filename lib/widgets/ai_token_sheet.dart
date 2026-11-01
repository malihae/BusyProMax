import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/ai_chat_service.dart';
import '../services/ai_key_store.dart';
import '../theme/app_theme.dart';

/// Opens the token setup used by both Settings and the chat screen.
///
/// Returns true when a token was saved or removed. The caller can then refresh
/// its AI status.
Future<bool> showHuggingFaceTokenSheet(
  BuildContext context, {
  required bool hasToken,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => _AiTokenSheet(hasToken: hasToken),
  );
  return result ?? false;
}

class _AiTokenSheet extends StatefulWidget {
  const _AiTokenSheet({required this.hasToken});

  final bool hasToken;

  @override
  State<_AiTokenSheet> createState() => _AiTokenSheetState();
}

class _AiTokenSheetState extends State<_AiTokenSheet> {
  final _controller = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openTokenPage() async {
    try {
      await launchUrl(
        Uri.parse(AiChatService.tokenUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not open the token page.');
    }
  }

  Future<void> _save() async {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      setState(() => _error = 'Paste a token first.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await AiKeyStore.write(value);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'The token could not be saved on this device.';
      });
    }
  }

  Future<void> _remove() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await AiKeyStore.clear();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'The token could not be removed.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    final text = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.hasToken ? 'AI replies' : 'Turn on AI replies',
                style: text.headlineSmall?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(
                'Add a Hugging Face token. Demo chats go to Hugging Face while '
                'it is on.',
                style: text.bodySmall?.copyWith(
                  color: mono.muted,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  color: mono.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: mono.line, width: 0.8),
                ),
                child: TextField(
                  key: const Key('hf-token-input'),
                  controller: _controller,
                  autofocus: true,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _saving ? null : _save(),
                  style: const TextStyle(fontSize: 13.5),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'hf_…',
                    hintStyle: TextStyle(color: mono.muted, fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15,
                    ),
                    prefixIcon: Icon(
                      Icons.key_rounded,
                      size: 17,
                      color: mono.muted,
                    ),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: text.bodySmall?.copyWith(
                    color: mono.ink,
                    fontSize: 11.5,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  TextButton(
                    key: const Key('get-hf-token'),
                    onPressed: _saving ? null : _openTokenPage,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 38),
                    ),
                    child: const Text('Create a token'),
                  ),
                  const Spacer(),
                  if (widget.hasToken) ...[
                    TextButton(
                      key: const Key('remove-hf-token'),
                      onPressed: _saving ? null : _remove,
                      child: const Text('Remove'),
                    ),
                    const SizedBox(width: 4),
                  ],
                  FilledButton(
                    key: const Key('save-hf-token'),
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 1.6),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Inference Providers token. Stored in secure storage.',
                style: text.bodySmall?.copyWith(
                  color: mono.muted,
                  fontSize: 10,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
