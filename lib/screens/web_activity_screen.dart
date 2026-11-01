import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/activity.dart';
import '../theme/app_theme.dart';
import '../widgets/mono_app_bar.dart';

class WebActivityScreen extends StatefulWidget {
  const WebActivityScreen({super.key, required this.activity});

  final ActivityDefinition activity;

  @override
  State<WebActivityScreen> createState() => _WebActivityScreenState();
}

class _WebActivityScreenState extends State<WebActivityScreen> {
  WebViewController? _controller;
  bool _initialized = false;
  bool _loading = true;
  bool _failed = false;
  bool _unsupported = false;
  bool _canGoBack = false;
  bool _sslFailure = false;
  double _progress = 0;
  String _failureMessage = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    unawaited(_createBrowser());
  }

  Future<void> _createBrowser() async {
    final uri = widget.activity.websiteUri;
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      if (!mounted) return;
      setState(() {
        _unsupported = true;
        _loading = false;
      });
      return;
    }

    try {
      final background = context.mono.canvas;
      final controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setBackgroundColor(background);
      await controller.setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) return;
            setState(() => _progress = progress / 100);
          },
          onPageStarted: (url) {
            if (!mounted) return;
            setState(() {
              _loading = true;
              _failed = false;
              _progress = 0;
            });
          },
          onPageFinished: (url) {
            if (!mounted) return;
            setState(() {
              _loading = false;
              _failed = false;
              _progress = 1;
            });
            unawaited(_refreshCanGoBack());
          },
          onNavigationRequest: _handleNavigation,
          onWebResourceError: (error) {
            if (!mounted) return;
            if (error.isForMainFrame == false) return;
            setState(() {
              _loading = false;
              _failed = true;
              _sslFailure =
                  error.errorType == WebResourceErrorType.failedSslHandshake;
              _failureMessage = error.description;
            });
          },
        ),
      );
      if (!mounted) return;
      setState(() {
        _controller = controller;
        _loading = true;
        _failed = false;
        _unsupported = false;
      });
      await controller.loadRequest(uri);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _unsupported = true;
        _loading = false;
      });
    }
  }

  NavigationDecision _handleNavigation(NavigationRequest request) {
    final uri = Uri.tryParse(request.url);
    if (uri != null && uri.scheme == 'https' && uri.host.isNotEmpty) {
      return NavigationDecision.navigate;
    }

    if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'That link was not a secure web link, so it was blocked. '
              'You can open this site in your browser instead.',
            ),
          ),
        );
    }
    return NavigationDecision.prevent;
  }

  Future<void> _refreshCanGoBack() async {
    final controller = _controller;
    if (controller == null) return;
    final value = await controller.canGoBack();
    if (!mounted) return;
    setState(() => _canGoBack = value);
  }

  Future<void> _goBackInPage() async {
    final controller = _controller;
    if (controller == null) return;
    await controller.goBack();
    await _refreshCanGoBack();
  }

  void _reload() {
    final controller = _controller;
    if (controller == null) {
      setState(() {
        _unsupported = false;
        _loading = true;
      });
      unawaited(_createBrowser());
      return;
    }
    setState(() {
      _failed = false;
      _loading = true;
      _progress = 0;
    });
    unawaited(controller.reload());
  }

  Future<void> _openExternally() async {
    final uri = widget.activity.websiteUri;
    if (uri == null) return;
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) {
        _showOpenFailure();
      }
    } catch (_) {
      _showOpenFailure();
    }
  }

  void _showOpenFailure() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No browser could be opened for this website.'),
      ),
    );
  }

  String get _disclosure => switch (widget.activity.kind) {
    ActivityKind.foodOrdering =>
      'Real FoodNeverComes site. No order is placed here.',
    ActivityKind.shopping => 'Real Amazon site. No purchase is made here.',
    ActivityKind.villaSecurity =>
      'Public site. Not a live camera or private feed.',
    _ => 'The real website for this activity.',
  };

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;

    return PopScope(
      canPop: !_canGoBack,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        unawaited(_goBackInPage());
      },
      child: Scaffold(
        appBar: MonoAppBar(
          leading: MonoBarButton(
            key: const Key('web-close'),
            icon: Icons.close_rounded,
            tooltip: 'Back to BusyProMax',
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: AppTitle(
            title: widget.activity.title,
            subtitle: widget.activity.domain,
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: mono.surface,
                shape: BoxShape.circle,
                border: Border.all(color: mono.line, width: 0.8),
              ),
              alignment: Alignment.center,
              child: Icon(widget.activity.icon, size: 16),
            ),
          ),
          actions: [
            MonoBarButton(
              key: const Key('open-in-browser'),
              icon: Icons.open_in_new_rounded,
              tooltip: 'Open in system browser',
              onPressed: _openExternally,
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 11, 16, 11),
              decoration: BoxDecoration(
                color: mono.surface,
                border: Border(
                  bottom: BorderSide(color: mono.line, width: 0.8),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined, size: 15, color: mono.ink),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      _disclosure,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10.5,
                        height: 1.45,
                        color: mono.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_controller != null && !_unsupported)
              _BrowserToolbar(
                canGoBack: _canGoBack,
                onBack: _goBackInPage,
                onReload: _reload,
                domain: widget.activity.domain,
              ),
            Expanded(child: _buildBrowserBody(mono)),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowserBody(MonoColors mono) {
    if (_unsupported) {
      return _BrowserMessage(
        icon: Icons.open_in_browser_outlined,
        title: 'Open this site in your browser',
        body: 'In-app browsing is not available here.',
        technical: null,
        actions: [
          FilledButton.icon(
            key: const Key('fallback-open-browser'),
            onPressed: _openExternally,
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: const Text('Open in browser'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back to BusyProMax'),
          ),
        ],
      );
    }

    if (_failed) {
      return _BrowserMessage(
        icon: _sslFailure ? Icons.gpp_bad_outlined : Icons.cloud_off_outlined,
        title: _sslFailure ? 'Certificate not valid' : 'Page didn’t load',
        body: _sslFailure
            ? 'This site’s HTTPS certificate is expired or untrusted. Try '
                  'again later, or open it in your browser.'
            : 'Check your connection, or open the site in your browser.',
        technical: _failureMessage.isEmpty ? null : _failureMessage,
        actions: [
          FilledButton.icon(
            key: const Key('retry-web-page'),
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Try again'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            key: const Key('error-open-browser'),
            onPressed: _openExternally,
            child: const Text('Open in system browser'),
          ),
        ],
      );
    }

    final controller = _controller;
    if (controller == null) {
      return _BrowserMessage(
        icon: Icons.public_rounded,
        title: 'Preparing ${widget.activity.domain}',
        body: 'Starting the in-app browser.',
        busy: true,
        technical: null,
        actions: const [],
      );
    }

    return Stack(
      children: [
        Positioned.fill(child: WebViewWidget(controller: controller)),
        if (widget.activity.kind == ActivityKind.villaSecurity) ...[
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.3),
                    width: 0.9,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 20,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 0.8,
                  ),
                ),
                child: const Text(
                  'PUBLIC WEBSITE  ·  NOT A LIVE FEED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
        if (_loading)
          Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(
                color: mono.canvas.withValues(alpha: 0.94),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          value: _progress > 0 && _progress < 1
                              ? _progress
                              : null,
                          strokeWidth: 1.6,
                          color: mono.ink,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading ${widget.activity.domain}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10.5,
                          letterSpacing: 0.2,
                          color: mono.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _BrowserToolbar extends StatelessWidget {
  const _BrowserToolbar({
    required this.canGoBack,
    required this.onBack,
    required this.onReload,
    required this.domain,
  });

  final bool canGoBack;
  final VoidCallback onBack;
  final VoidCallback onReload;
  final String domain;

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: mono.canvas,
        border: Border(bottom: BorderSide(color: mono.line, width: 0.8)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: canGoBack ? onBack : null,
            tooltip: 'Back in page',
            icon: const Icon(Icons.chevron_left_rounded, size: 21),
            style: IconButton.styleFrom(
              minimumSize: const Size(44, 42),
              foregroundColor: mono.ink,
              disabledForegroundColor: mono.line,
            ),
          ),
          IconButton(
            onPressed: onReload,
            tooltip: 'Reload page',
            icon: const Icon(Icons.refresh_rounded, size: 17),
            style: IconButton.styleFrom(
              minimumSize: const Size(44, 42),
              foregroundColor: mono.ink,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline_rounded, size: 10, color: mono.muted),
                const SizedBox(width: 5),
                Text(
                  domain,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 9.5,
                    letterSpacing: 0.1,
                    color: mono.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrowserMessage extends StatelessWidget {
  const _BrowserMessage({
    required this.icon,
    required this.title,
    required this.body,
    required this.actions,
    this.technical,
    this.busy = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final List<Widget> actions;
  final String? technical;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    final text = Theme.of(context).textTheme;

    return ColoredBox(
      color: mono.canvas,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (busy)
                SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.6,
                    color: mono.ink,
                  ),
                )
              else
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: mono.line, width: 0.8),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 27, color: mono.ink),
                ),
              const SizedBox(height: 22),
              Text(
                title,
                textAlign: TextAlign.center,
                style: text.headlineSmall?.copyWith(fontSize: 27),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Text(
                  body,
                  textAlign: TextAlign.center,
                  style: text.bodyMedium?.copyWith(
                    color: mono.muted,
                    height: 1.55,
                  ),
                ),
              ),
              if (technical != null) ...[
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: Text(
                    technical!,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall?.copyWith(
                      fontSize: 9.5,
                      color: mono.muted,
                    ),
                  ),
                ),
              ],
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 22),
                ...actions,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
