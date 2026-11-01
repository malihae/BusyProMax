import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/ai_key_store.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_token_sheet.dart';
import '../widgets/common.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _aiReady = false;
  bool _checkingAi = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadAi());
  }

  Future<void> _loadAi() async {
    final token = await AiKeyStore.read();
    if (!mounted) return;
    setState(() {
      _aiReady = token != null && token.isNotEmpty;
      _checkingAi = false;
    });
  }

  Future<void> _openAi() async {
    final changed = await showHuggingFaceTokenSheet(
      context,
      hasToken: _aiReady,
    );
    if (!mounted) return;
    if (!changed) return;
    await _loadAi();
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

  Future<void> _confirmReset(BuildContext context) async {
    final appState = context.read<AppState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset demo data?'),
        content: const Text('Clears favorites and sample chats.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            key: const Key('confirm-reset'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await appState.resetDemoData();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Demo data reset.')));
  }

  void _showCredits(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Media credits'),
        content: const Text(
          'Villa loop: LTX-Video by Lightricks, via Hugging Face.\n'
          'Moodboard photography: Unsplash.\n'
          'Tinos: SIL Open Font License.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    final text = Theme.of(context).textTheme;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        key: const PageStorageKey<String>('settings-scroll'),
        padding: const EdgeInsets.only(bottom: 30),
        child: ContentFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(title: 'Settings', bottom: 22),
              const SectionLabel(label: 'Appearance'),
              const SizedBox(height: 12),
              const _ThemePicker(),
              const SizedBox(height: 28),
              const SectionLabel(label: 'AI replies'),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: mono.surface,
                  border: Border.all(color: mono.line, width: 0.8),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: mono.inverse,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            size: 17,
                            color: mono.onInverse,
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hugging Face',
                                style: text.titleMedium?.copyWith(
                                  fontSize: 13.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _checkingAi
                                    ? 'Checking…'
                                    : _aiReady
                                    ? 'AI replies on'
                                    : 'Local samples',
                                style: text.bodySmall?.copyWith(
                                  fontSize: 10.5,
                                  color: mono.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          key: const Key('ai-connect'),
                          onPressed: _openAi,
                          child: Text(_aiReady ? 'Manage' : 'Connect'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const SectionLabel(label: 'Permissions'),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: mono.line, width: 0.8),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  children: [
                    _PermissionRow(
                      icon: Icons.videocam_outlined,
                      title: 'Camera',
                      status: 'ON DEMAND',
                    ),
                    _InnerDivider(),
                    _PermissionRow(
                      icon: Icons.mic_none_rounded,
                      title: 'Microphone',
                      status: 'NEVER',
                    ),
                    _InnerDivider(),
                    _PermissionRow(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      status: 'NOT USED',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const SectionLabel(label: 'Privacy'),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: mono.surface,
                  border: Border.all(color: mono.line, width: 0.8),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Point(text: 'Favorites and theme stay local.'),
                    _Point(text: 'AI chats go to Hugging Face when on.'),
                    _Point(text: 'No accounts, ads, or analytics.'),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const SectionLabel(label: 'Simulation policy'),
              const SizedBox(height: 4),
              const _PolicyRow(
                icon: Icons.videocam_off_outlined,
                text: 'Calls are simulated.',
              ),
              const _PolicyRow(
                icon: Icons.smart_toy_outlined,
                text: 'Demo chats never send.',
              ),
              const _PolicyRow(
                icon: Icons.photo_camera_outlined,
                text: 'Villa is an AI loop.',
              ),
              const _PolicyRow(
                icon: Icons.language_rounded,
                text: 'Real sites. No orders placed.',
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: mono.line, width: 0.8),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Reset demo data.',
                        style: text.bodySmall?.copyWith(
                          fontSize: 11,
                          color: mono.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      key: const Key('reset-demo-data'),
                      onPressed: () => _confirmReset(context),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: mono.line, width: 0.8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BrandMark(),
                    const SizedBox(height: 10),
                    Text(
                      'Version 1.3.0 (4)',
                      style: text.bodySmall?.copyWith(
                        fontSize: 10.5,
                        color: mono.muted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton(
                          key: const Key('open-licenses'),
                          onPressed: () => showLicensePage(
                            context: context,
                            applicationName: 'BusyProMax',
                            applicationVersion: '1.3.0',
                            applicationLegalese: '© 2026 BusyProMax. Tinos is licensed under the SIL Open Font License.',
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 36),
                          ),
                          child: const Text('Licenses'),
                        ),
                        const SizedBox(width: 16),
                        TextButton(
                          key: const Key('open-credits'),
                          onPressed: () => _showCredits(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 36),
                          ),
                          child: const Text('Media credits'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker();

  @override
  Widget build(BuildContext context) {
    final selected = context.watch<AppState>().themeMode;
    return Row(
      children: [
        for (var index = 0; index < _themeChoices.length; index++) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(
            child: _ThemeChoiceTile(
              choice: _themeChoices[index],
              selected: selected == _themeChoices[index].mode,
            ),
          ),
        ],
      ],
    );
  }
}

class _ThemeChoice {
  const _ThemeChoice({
    required this.mode,
    required this.label,
    required this.icon,
  });

  final ThemeMode mode;
  final String label;
  final IconData icon;
}

const _themeChoices = <_ThemeChoice>[
  _ThemeChoice(
    mode: ThemeMode.system,
    label: 'System',
    icon: Icons.brightness_auto_outlined,
  ),
  _ThemeChoice(
    mode: ThemeMode.light,
    label: 'Light',
    icon: Icons.light_mode_outlined,
  ),
  _ThemeChoice(
    mode: ThemeMode.dark,
    label: 'Dark',
    icon: Icons.dark_mode_outlined,
  ),
];

class _ThemeChoiceTile extends StatelessWidget {
  const _ThemeChoiceTile({required this.choice, required this.selected});

  final _ThemeChoice choice;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    final foreground = selected ? mono.onInverse : mono.ink;

    return Semantics(
      button: true,
      selected: selected,
      label: '${choice.label} theme',
      child: Material(
        color: selected ? mono.inverse : mono.canvas,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('theme-${choice.mode.name}'),
          onTap: () => context.read<AppState>().setThemeMode(choice.mode),
          splashColor: foreground.withValues(alpha: 0.08),
          child: Container(
            height: 66,
            decoration: BoxDecoration(
              border: Border.all(
                color: selected ? Colors.transparent : mono.line,
                width: 0.8,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(choice.icon, size: 18, color: foreground),
                const SizedBox(height: 5),
                Text(
                  choice.label,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 10.5,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.icon,
    required this.title,
    required this.status,
  });

  final IconData icon;
  final String title;
  final String status;

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Row(
        children: [
          Icon(icon, size: 17, color: mono.ink),
          const SizedBox(width: 11),
          Expanded(
            child: Text(title, style: text.titleMedium?.copyWith(fontSize: 13)),
          ),
          Text(
            status,
            style: text.labelMedium?.copyWith(
              fontSize: 7.5,
              color: mono.muted,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _InnerDivider extends StatelessWidget {
  const _InnerDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.8,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      color: context.mono.line,
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_rounded, size: 14, color: mono.ink),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(fontSize: 11, height: 1.4, color: mono.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyRow extends StatelessWidget {
  const _PolicyRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: mono.muted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(fontSize: 11, height: 1.45, color: mono.ink),
            ),
          ),
        ],
      ),
    );
  }
}
