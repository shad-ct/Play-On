import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:playon/features/profile/data/models/player_card_data.dart';
import 'package:playon/features/profile/presentation/widgets/player_card_widget.dart';

/// Wraps the card with:
///   • Parallax tilt (±15°) via drag
///   • Spring ease-out return on finger lift
///   • Y-axis flip on tap (detected via Listener + distance check)
///   • Card animation paused during flip
class PlayerCard3dWrapper extends StatefulWidget {
  final PlayerCardData data;
  final SpecialEdition edition;
  final bool reducedMotion;

  const PlayerCard3dWrapper({
    super.key,
    required this.data,
    this.edition = SpecialEdition.none,
    this.reducedMotion = false,
  });

  @override
  State<PlayerCard3dWrapper> createState() => _PlayerCard3dWrapperState();
}

class _PlayerCard3dWrapperState extends State<PlayerCard3dWrapper>
    with TickerProviderStateMixin {
  // ── Tilt ─────────────────────────────────────────────────────────────────────
  Offset _dragTilt = Offset.zero;
  Offset _gyroTilt = Offset.zero;
  Offset _targetGyroTilt = Offset.zero;
  final ValueNotifier<Offset> _tiltNotifier = ValueNotifier(Offset.zero);

  late AnimationController _tiltReturnCtrl;
  Animation<Offset>? _tiltAnim;

  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  Ticker? _ticker;


  static const _maxTiltRad = 15.0 * math.pi / 180;
  static const _perspective = 0.0008;

  @override
  void initState() {
    super.initState();

    _tiltReturnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..addListener(_onTiltReturn);

    if (!widget.reducedMotion) {
      _ticker = createTicker((_) {
        // Interpolate continuously at the display refresh rate (e.g. 60-120fps)
        _gyroTilt = Offset(
          _gyroTilt.dx + (_targetGyroTilt.dx - _gyroTilt.dx) * 0.15,
          _gyroTilt.dy + (_targetGyroTilt.dy - _gyroTilt.dy) * 0.15,
        );
        _updateTilt();
      })..start();

      _accelSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
        if (!mounted) return;
        // Update target asynchronously, so that interpolation happens smoothly regardless of sensor frequency
        _targetGyroTilt = Offset(
          ((event.y - 4.5) / 4.0).clamp(-1.0, 1.0),
          (-event.x / 4.0).clamp(-1.0, 1.0),
        );
      });
    }
  }

  void _updateTilt() {
    _tiltNotifier.value = Offset(
      (_dragTilt.dx + _gyroTilt.dx).clamp(-1.0, 1.0),
      (_dragTilt.dy + _gyroTilt.dy).clamp(-1.0, 1.0),
    );
  }

  // ── Tilt via GestureDetector ────────────────────────────────────────────────
  void _onPanUpdate(DragUpdateDetails d, BoxConstraints box) {
    _dragTilt = Offset(
      (_dragTilt.dx - d.delta.dy / box.maxHeight * 2.5).clamp(-1.0, 1.0),
      (_dragTilt.dy + d.delta.dx / box.maxWidth * 2.5).clamp(-1.0, 1.0),
    );
    _updateTilt();
  }

  void _onPanEnd(DragEndDetails d) {
    _springReturn();
  }

  void _springReturn() {
    _tiltReturnCtrl.stop();
    _tiltAnim = Tween<Offset>(begin: _dragTilt, end: Offset.zero).animate(
      CurvedAnimation(parent: _tiltReturnCtrl, curve: Curves.elasticOut),
    );
    _tiltReturnCtrl.forward(from: 0.0);
  }

  void _onTiltReturn() {
    if (_tiltAnim != null) {
      _dragTilt = _tiltAnim!.value;
      _updateTilt();
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _accelSubscription?.cancel();
    _tiltReturnCtrl.dispose();
    _tiltNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, box) {
      // GestureDetector handles pan/drag for tilt.
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (d) => _onPanUpdate(d, box),
        onPanEnd: _onPanEnd,
        child: ValueListenableBuilder<Offset>(
          valueListenable: _tiltNotifier,
          builder: (context, tilt, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, _perspective)
                ..rotateX(tilt.dx * _maxTiltRad)
                ..rotateY(tilt.dy * _maxTiltRad),
              child: child,
            );
          },
          child: Transform.scale(
            scale: 1.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: PlayerCardWidget(
                data: widget.data,
                edition: widget.edition,
                reducedMotion: widget.reducedMotion,
                animationPaused: false,
              ),
            ),
          ),
        ),
      );
    });
  }
}
