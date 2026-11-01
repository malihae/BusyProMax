import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/formatters.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen>
    with WidgetsBindingObserver {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  CameraController? _controller;
  List<CameraDescription> _cameras = const <CameraDescription>[];
  int _cameraIndex = 0;
  bool _initializing = true;
  bool _starting = false;
  bool _cameraEnabled = true;
  bool _micEnabled = false;
  bool _previewSkipped = false;
  bool _cameraDenied = false;
  String? _cameraError;
  bool _resumeCameraOnForeground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startClock();
    _startCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _stopwatch.stop();
    final controller = _controller;
    _controller = null;
    controller?.dispose();
    super.dispose();
  }

  void _startClock() {
    if (_timer != null) return;
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed = _stopwatch.elapsed);
    });
  }

  void _stopClock() {
    _timer?.cancel();
    _timer = null;
    _stopwatch.stop();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _stopClock();
      if (_controller != null) {
        _resumeCameraOnForeground = true;
        final controller = _controller;
        _controller = null;
        controller?.dispose();
        if (mounted) {
          setState(() => _cameraEnabled = false);
        }
      }
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _startClock();
      if (_resumeCameraOnForeground) {
        _resumeCameraOnForeground = false;
        _startCamera();
      }
    }
  }

  Future<void> _startCamera() async {
    if (_starting) return;
    _starting = true;
    if (mounted) {
      setState(() {
        _initializing = true;
        _cameraError = null;
        _cameraDenied = false;
      });
    }

    CameraController? nextController;
    final previous = _controller;
    _controller = null;
    await previous?.dispose();

    try {
      if (_cameras.isEmpty) {
        _cameras = await availableCameras();
      }
      if (_cameras.isEmpty) {
        throw CameraException(
          'NoCamera',
          'No camera was found on this device.',
        );
      }
      _cameraIndex = _cameraIndex % _cameras.length;
      nextController = CameraController(
        _cameras[_cameraIndex],
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await nextController.initialize();
      if (!mounted) {
        await nextController.dispose();
        return;
      }

      _controller = nextController;
      nextController = null;
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _previewSkipped = false;
        _cameraDenied = false;
        _cameraError = null;
        _cameraEnabled = true;
      });
    } on CameraException catch (error) {
      await nextController?.dispose();
      if (!mounted) return;
      final denied =
          error.code.toLowerCase().contains('denied') ||
          error.code.toLowerCase().contains('restricted');
      setState(() {
        _initializing = false;
        _cameraDenied = denied;
        _cameraError = denied
            ? 'Camera access is off.'
            : 'The camera could not start. It may be in use.';
      });
    } catch (_) {
      await nextController?.dispose();
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _cameraDenied = false;
        _cameraError =
            'The preview is unavailable. The call screen still works.';
      });
    } finally {
      _starting = false;
    }
  }

  Future<void> _toggleCamera() async {
    if (_initializing) return;
    final controller = _controller;
    if (controller == null) {
      await _startCamera();
      return;
    }

    try {
      if (_cameraEnabled) {
        await controller.pausePreview();
      } else {
        await controller.resumePreview();
      }
      if (!mounted) return;
      setState(() => _cameraEnabled = !_cameraEnabled);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cameraError = 'Camera restart failed.';
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_initializing) return;
    if (_cameras.length < 2) {
      _showSnack('Only one camera available.');
      return;
    }
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _startCamera();
  }

  void _toggleMic() {
    setState(() => _micEnabled = !_micEnabled);
    _showSnack('Visual only. The microphone is never used.');
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _continueWithoutPreview() {
    setState(() {
      _previewSkipped = true;
      _initializing = false;
      _cameraError = null;
    });
  }

  Future<void> _showInfo() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return Theme(
          data: AppTheme.dark,
          child: Builder(
            builder: (context) {
              final text = Theme.of(context).textTheme;
              return SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'This call is a simulation.',
                        style: text.headlineSmall?.copyWith(fontSize: 29),
                      ),
                      const SizedBox(height: 18),
                      const _InfoPoint(
                        text: 'Camera preview stays on this phone.',
                      ),
                      const _InfoPoint(text: 'Microphone is never used.'),
                      const _InfoPoint(text: 'The timer is screen time.'),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: const Text('Back to the call'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.dark,
      child: Builder(builder: _buildCall),
    );
  }

  Widget _buildCall(BuildContext context) {
    final mono = context.mono;
    final text = Theme.of(context).textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: mono.canvas,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: mono.canvas,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Row(
                  children: [
                    _IconAction(
                      icon: Icons.close_rounded,
                      tooltip: 'Close simulated call',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    const DemoPill(inverted: true, label: 'SIMULATED CALL'),
                    const Spacer(),
                    _IconAction(
                      icon: Icons.info_outline_rounded,
                      tooltip: 'About this simulation',
                      onTap: _showInfo,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: mono.muted, width: 1),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'No one is connected',
                    style: TextStyle(
                      color: mono.muted,
                      fontSize: 10.5,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Text('·', style: TextStyle(color: mono.muted, fontSize: 11)),
                  const SizedBox(width: 9),
                  Text(
                    formatElapsed(_elapsed),
                    style: TextStyle(
                      color: mono.ink,
                      fontSize: 11,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      letterSpacing: 0.7,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      color: mono.surface,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildPreview(context),
                          Positioned(
                            left: 14,
                            top: 14,
                            child: _PreviewTag(
                              label: _controller != null && _cameraEnabled
                                  ? 'YOU  ·  LOCAL'
                                  : 'PREVIEW  ·  OFF',
                            ),
                          ),
                          if (_controller != null && _cameraEnabled)
                            Positioned(
                              right: 14,
                              bottom: 14,
                              child: _PreviewTag(
                                label: formatElapsed(_elapsed),
                                icon: Icons.fiber_manual_record_rounded,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CallControl(
                    icon: _micEnabled
                        ? Icons.mic_rounded
                        : Icons.mic_off_rounded,
                    label: 'Mic',
                    active: _micEnabled,
                    onTap: _toggleMic,
                  ),
                  _CallControl(
                    icon: _cameraEnabled
                        ? Icons.videocam_outlined
                        : Icons.videocam_off_outlined,
                    label: 'Camera',
                    active: _cameraEnabled && _controller != null,
                    onTap: _initializing ? null : _toggleCamera,
                  ),
                  _CallControl(
                    icon: Icons.cameraswitch_outlined,
                    label: 'Flip',
                    onTap: _initializing ? null : _switchCamera,
                  ),
                  _CallControl(
                    icon: Icons.call_end_rounded,
                    label: 'End',
                    isEnd: true,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'SIMULATION  ·  NO REAL CALL  ·  NO MICROPHONE',
                style: text.labelMedium?.copyWith(
                  fontSize: 7.5,
                  color: mono.muted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    final mono = context.mono;

    if (_initializing) {
      return _PreviewMessage(
        icon: Icons.videocam_outlined,
        title: 'Opening your camera',
        body: 'Stays on this phone.',
        busy: true,
      );
    }

    if (_cameraError != null && !_previewSkipped) {
      return _PreviewMessage(
        icon: Icons.no_photography_outlined,
        title: _cameraDenied ? 'Camera access is off' : 'Camera unavailable',
        body: _cameraDenied
            ? 'Allow Camera in settings, or continue without it.'
            : _cameraError!,
        actions: [
          FilledButton(
            onPressed: _startCamera,
            child: const Text('Try camera again'),
          ),
          const SizedBox(height: 10),
          TextButton(
            key: const Key('continue-without-preview'),
            onPressed: _continueWithoutPreview,
            style: TextButton.styleFrom(foregroundColor: mono.ink),
            child: const Text('Continue without preview'),
          ),
        ],
      );
    }

    final controller = _controller;
    if (controller == null || !_cameraEnabled || _previewSkipped) {
      return _PreviewMessage(
        icon: Icons.videocam_off_outlined,
        title: _previewSkipped ? 'Preview off' : 'Camera paused',
        body: 'No one is on the other side.',
        actions: [
          OutlinedButton(
            onPressed: _previewSkipped ? _startCamera : _toggleCamera,
            child: Text(
              _previewSkipped ? 'Try camera again' : 'Resume preview',
            ),
          ),
        ],
      );
    }

    final previewSize = controller.value.previewSize;
    if (previewSize == null) {
      return CameraPreview(controller);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final portrait = constraints.maxHeight >= constraints.maxWidth;
        final width = portrait ? previewSize.height : previewSize.width;
        final height = portrait ? previewSize.width : previewSize.height;
        return FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: width,
            height: height,
            child: CameraPreview(controller),
          ),
        );
      },
    );
  }
}

class _PreviewMessage extends StatelessWidget {
  const _PreviewMessage({
    required this.icon,
    required this.title,
    required this.body,
    this.actions = const <Widget>[],
    this.busy = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final List<Widget> actions;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    final text = Theme.of(context).textTheme;

    return ColoredBox(
      color: mono.surface,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (busy)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.6,
                    color: mono.ink,
                  ),
                )
              else
                Icon(icon, size: 34, color: mono.ink),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: text.headlineSmall?.copyWith(fontSize: 25),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 310),
                child: Text(
                  body,
                  textAlign: TextAlign.center,
                  style: text.bodySmall?.copyWith(
                    color: mono.muted,
                    fontSize: 11.5,
                    height: 1.5,
                  ),
                ),
              ),
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 20),
                ...actions,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewTag extends StatelessWidget {
  const _PreviewTag({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.28),
          width: 0.8,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 8, color: Colors.white),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      icon: Icon(icon, size: 20, color: mono.ink),
      style: IconButton.styleFrom(
        shape: const CircleBorder(),
        side: BorderSide(color: mono.line, width: 0.8),
        minimumSize: const Size(42, 42),
      ),
    );
  }
}

class _CallControl extends StatelessWidget {
  const _CallControl({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.isEnd = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool active;
  final bool isEnd;

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    final disabled = onTap == null;
    final filled = active || isEnd;
    final foreground = filled ? mono.onInverse : mono.ink;
    final background = filled ? mono.inverse : Colors.transparent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: label,
          child: Semantics(
            button: true,
            enabled: !disabled,
            label: label,
            child: Opacity(
              opacity: disabled ? 0.4 : 1,
              child: Material(
                color: background,
                shape: CircleBorder(
                  side: BorderSide(
                    color: filled
                        ? Colors.transparent
                        : mono.ink.withValues(alpha: 0.32),
                    width: 0.9,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  key: Key('call-${label.toLowerCase()}'),
                  onTap: onTap,
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    width: 54,
                    height: 54,
                    child: Icon(icon, size: 21, color: foreground),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          style: TextStyle(
            color: disabled ? mono.muted : mono.muted,
            fontSize: 9,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _InfoPoint extends StatelessWidget {
  const _InfoPoint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final mono = context.mono;
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: mono.line, width: 0.8),
            ),
            alignment: Alignment.center,
            child: Text(
              '—',
              style: TextStyle(fontSize: 9, color: mono.muted, height: 1),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(fontSize: 11.5, height: 1.5, color: mono.muted),
            ),
          ),
        ],
      ),
    );
  }
}
