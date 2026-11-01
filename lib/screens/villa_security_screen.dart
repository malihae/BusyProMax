import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../theme/app_theme.dart';

/// A deliberately simulated estate camera.
///
/// The footage is a pre-generated AI loop bundled from the LTX-Video model on
/// Hugging Face. It is not a live stream, does not open the camera, and never
/// connects to a real villa or security system.
class VillaSecurityScreen extends StatefulWidget {
  const VillaSecurityScreen({super.key});

  @override
  State<VillaSecurityScreen> createState() => _VillaSecurityScreenState();
}

class _VillaSecurityScreenState extends State<VillaSecurityScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  static const _videoAsset = 'assets/video/villa_garden_loop.mp4';
  static const _posterAsset = 'assets/video/villa_garden_poster.jpg';

  VideoPlayerController? _controller;
  Timer? _clock;
  DateTime _now = DateTime.now();
  bool _ready = false;
  bool _failed = false;
  bool _playing = true;
  bool _resumeOnForeground = false;

  late final AnimationController _scan = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  )..repeat();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
    unawaited(_openLoop());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clock?.cancel();
    _scan.dispose();
    final controller = _controller;
    _controller = null;
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      final controller = _controller;
      _resumeOnForeground = controller != null && controller.value.isPlaying;
      unawaited(controller?.pause());
      return;
    }
    if (state == AppLifecycleState.resumed && _resumeOnForeground) {
      _resumeOnForeground = false;
      unawaited(_controller?.play());
    }
  }

  Future<void> _openLoop() async {
    final controller = VideoPlayerController.asset(_videoAsset);
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();
      if (!mounted) return;
      setState(() {
        _ready = true;
        _failed = false;
        _playing = true;
      });
    } catch (_) {
      if (!mounted) return;
      await controller.dispose();
      if (_controller == controller) _controller = null;
      setState(() {
        _ready = false;
        _failed = true;
        _playing = false;
      });
    }
  }

  Future<void> _togglePlay() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isPlaying) {
      await controller.pause();
      if (!mounted) return;
      setState(() => _playing = false);
    } else {
      await controller.play();
      if (!mounted) return;
      setState(() => _playing = true);
    }
  }

  Future<void> _restart() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    await controller.seekTo(Duration.zero);
    await controller.play();
    if (!mounted) return;
    setState(() => _playing = true);
  }

  String get _time {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(_now.hour)}:${two(_now.minute)}:${two(_now.second)}';
  }

  String get _date {
    const months = <String>[
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return '${_now.day.toString().padLeft(2, '0')} '
        '${months[_now.month - 1]} ${_now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final initialized =
        _ready && controller != null && controller.value.isInitialized;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Semantics(
          label:
              'Simulated villa camera. An AI-generated loop, not a live feed.',
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (initialized)
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                )
              else
                Image.asset(
                  _posterAsset,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                ),
              const _CameraGrade(),
              AnimatedBuilder(
                animation: _scan,
                builder: (context, child) {
                  return IgnorePointer(
                    child: Align(
                      alignment: Alignment(0, -1 + (_scan.value * 2)),
                      child: Container(
                        height: 1,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              Colors.transparent,
                              Color(0x22FFFFFF),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
                  child: Column(
                    children: [
                      _TopBar(
                        onClose: () => Navigator.of(context).pop(),
                        time: _time,
                        date: _date,
                      ),
                      const Spacer(),
                      _CameraFrame(
                        playing: _playing,
                        ready: initialized,
                        failed: _failed,
                        onToggle: _togglePlay,
                        onRestart: _restart,
                        onClose: () => Navigator.of(context).pop(),
                      ),
                    ],
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

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.onClose,
    required this.time,
    required this.date,
  });

  final VoidCallback onClose;
  final String time;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _GlassButton(
              key: const Key('villa-close'),
              icon: Icons.close_rounded,
              tooltip: 'Back to BusyProMax',
              onPressed: onClose,
            ),
            const Spacer(),
            Column(
              children: [
                const Text(
                  'VILLA 09',
                  style: TextStyle(
                    fontFamily: AppTheme.serifFamily,
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'ESTATE CAM',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.62),
                    fontSize: 7.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.66),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.32),
                  width: 0.8,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'SIM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              '$date  $time',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.78),
                fontSize: 9.5,
                letterSpacing: 0.8,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const Spacer(),
            Icon(
              Icons.play_circle_outline_rounded,
              size: 11,
              color: Colors.white.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 5),
            Text(
              'LOOP',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.62),
                fontSize: 8,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CameraFrame extends StatelessWidget {
  const _CameraFrame({
    required this.playing,
    required this.ready,
    required this.failed,
    required this.onToggle,
    required this.onRestart,
    required this.onClose,
  });

  final bool playing;
  final bool ready;
  final bool failed;
  final VoidCallback onToggle;
  final VoidCallback onRestart;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Grounds',
                      style: TextStyle(
                        fontFamily: AppTheme.serifFamily,
                        color: Colors.white,
                        fontSize: 25,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      failed
                          ? 'Still frame. Loop unavailable.'
                          : 'AI-generated loop. Not a live feed.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.58),
                        fontSize: 10,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.28),
                    width: 0.8,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'AI DEMO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 7.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              _RoundControl(
                key: const Key('villa-play-pause'),
                icon: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                label: playing ? 'Pause loop' : 'Play loop',
                onPressed: ready ? onToggle : null,
              ),
              const SizedBox(width: 9),
              _RoundControl(
                key: const Key('villa-restart'),
                icon: Icons.replay_rounded,
                label: 'Restart loop',
                onPressed: ready ? onRestart : null,
              ),
              const Spacer(),
              TextButton(
                key: const Key('villa-back-home'),
                onPressed: onClose,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text('Back home'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                'PRE-GENERATED  ·  NOT LIVE',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.42),
                  fontSize: 7.5,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundControl extends StatelessWidget {
  const _RoundControl({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.white.withValues(alpha: 0.1),
        shape: const CircleBorder(),
        child: IconButton(
          onPressed: onPressed,
          tooltip: label,
          icon: Icon(icon, size: 19, color: Colors.white),
          style: IconButton.styleFrom(
            minimumSize: const Size(42, 42),
            disabledForegroundColor: Colors.white24,
          ),
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.58),
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(icon, size: 18, color: Colors.white),
        style: IconButton.styleFrom(minimumSize: const Size(40, 40)),
      ),
    );
  }
}

class _CameraGrade extends StatelessWidget {
  const _CameraGrade();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          const CustomPaint(painter: _ScanlinePainter()),
          const CustomPaint(painter: _GrainPainter()),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 0.95,
                colors: <Color>[
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.48),
                ],
              ),
            ),
          ),
          const CustomPaint(painter: _CornerPainter()),
        ],
      ),
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  const _ScanlinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 1;
    for (var y = 0.0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GrainPainter extends CustomPainter {
  const _GrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(19);
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.075);
    final count = (size.width * size.height / 4200).clamp(80, 480).toInt();
    for (var index = 0; index < count; index++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        random.nextDouble() * 0.7 + 0.2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.38)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;
    const inset = 18.0;
    const length = 18.0;
    final corners = <Offset>[
      const Offset(inset, inset),
      Offset(size.width - inset, inset),
      Offset(inset, size.height - inset),
      Offset(size.width - inset, size.height - inset),
    ];
    for (final corner in corners) {
      final left = corner.dx < size.width / 2;
      final top = corner.dy < size.height / 2;
      canvas.drawLine(
        corner,
        corner + Offset(left ? length : -length, 0),
        paint,
      );
      canvas.drawLine(
        corner,
        corner + Offset(0, top ? length : -length),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
