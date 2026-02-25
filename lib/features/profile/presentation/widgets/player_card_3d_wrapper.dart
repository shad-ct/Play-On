import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:playon/features/profile/data/models/player_card_data.dart';
import 'package:playon/features/profile/presentation/widgets/player_card_widget.dart';
import 'package:playon/features/profile/presentation/widgets/player_card_back_widget.dart';

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
  double _tiltX = 0.0;
  double _tiltY = 0.0;

  late AnimationController _tiltReturnCtrl;
  Animation<double>? _tiltXAnim;
  Animation<double>? _tiltYAnim;

  // ── Flip ─────────────────────────────────────────────────────────────────────
  late AnimationController _flipCtrl;
  bool _showFront = true;
  bool _isFlipping = false;
  bool _cardAnimPaused = false;

  // ── Raw pointer tracking for tap-vs-drag ─────────────────────────────────────
  Offset? _pointerDown;
  static const _tapSlop = 18.0; // px — if moved less than this, it's a tap

  static const _maxTiltRad = 15.0 * math.pi / 180;
  static const _perspective = 0.0008;

  @override
  void initState() {
    super.initState();

    _tiltReturnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..addListener(_onTiltReturn);

    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipCtrl.addListener(_onFlipTick);
    _flipCtrl.addStatusListener(_onFlipStatus);
  }

  // ── Tilt via GestureDetector ────────────────────────────────────────────────
  void _onPanUpdate(DragUpdateDetails d, BoxConstraints box) {
    if (_isFlipping) return;
    setState(() {
      _tiltY = (_tiltY + d.delta.dx / box.maxWidth * 2.5).clamp(-1.0, 1.0);
      _tiltX = (_tiltX - d.delta.dy / box.maxHeight * 2.5).clamp(-1.0, 1.0);
    });
  }

  void _onPanEnd(DragEndDetails d) {
    if (_isFlipping) return;
    _springReturn();
  }

  void _springReturn() {
    _tiltReturnCtrl.stop();
    final fromX = _tiltX;
    final fromY = _tiltY;
    _tiltXAnim = Tween<double>(begin: fromX, end: 0.0).animate(
      CurvedAnimation(parent: _tiltReturnCtrl, curve: Curves.elasticOut),
    );
    _tiltYAnim = Tween<double>(begin: fromY, end: 0.0).animate(
      CurvedAnimation(parent: _tiltReturnCtrl, curve: Curves.elasticOut),
    );
    _tiltReturnCtrl.forward(from: 0.0);
  }

  void _onTiltReturn() {
    if (_tiltXAnim != null && _tiltYAnim != null) {
      setState(() {
        _tiltX = _tiltXAnim!.value;
        _tiltY = _tiltYAnim!.value;
      });
    }
  }

  // ── Flip ─────────────────────────────────────────────────────────────────────
  void _triggerFlip() {
    if (_isFlipping) return;
    setState(() {
      _isFlipping = true;
      _cardAnimPaused = true;
    });
    _tiltX = 0;
    _tiltY = 0;
    _tiltReturnCtrl.stop();

    if (_showFront) {
      // Front → Back: animate 0.0 → 1.0
      _flipCtrl.forward(from: 0.0);
    } else {
      // Back → Front: animate 1.0 → 0.0
      _flipCtrl.reverse(from: 1.0);
    }
  }

  void _onFlipTick() {
    if (!_isFlipping) return;

    // Toggle face at the midpoint (0.5)
    if (_showFront && _flipCtrl.value >= 0.5) {
      setState(() => _showFront = false);
    } else if (!_showFront && _flipCtrl.value < 0.5) {
      setState(() => _showFront = true);
    } else {
      setState(() {}); // rebuild for scale/shadow
    }
  }

  void _onFlipStatus(AnimationStatus status) {
    // completed = forward finished (value=1), dismissed = reverse finished (value=0)
    if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
      setState(() {
        _isFlipping = false;
        _cardAnimPaused = false;
      });
      // Don't reset! Keep value at 0.0 (front) or 1.0 (back)
    }
  }

  @override
  void dispose() {
    _tiltReturnCtrl.dispose();
    _flipCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, box) {
      final angle = _flipCtrl.value * math.pi;
      final scale = 1.0 + math.sin(angle) * 0.05;
      final shadow = 0.3 + math.sin(angle) * 0.35;

      Widget face;
      if (_showFront) {
        face = PlayerCardWidget(
          data: widget.data,
          edition: widget.edition,
          reducedMotion: widget.reducedMotion,
          animationPaused: _cardAnimPaused,
        );
      } else {
        face = Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..rotateY(math.pi),
          child: PlayerCardBackWidget(
            data: widget.data,
            edition: widget.edition,
          ),
        );
      }

      // Listener sits ABOVE GestureDetector to catch raw pointer events
      // for tap detection, while GestureDetector handles pan/drag for tilt.
      return Listener(
        onPointerDown: (e) {
          _pointerDown = e.localPosition;
        },
        onPointerUp: (e) {
          if (_isFlipping || _pointerDown == null) return;
          final dist = (e.localPosition - _pointerDown!).distance;
          if (dist < _tapSlop) {
            _triggerFlip();
          }
          _pointerDown = null;
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: _isFlipping ? null : (d) => _onPanUpdate(d, box),
          onPanEnd: _isFlipping ? null : _onPanEnd,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, _perspective)
              ..rotateX(_tiltX * _maxTiltRad)
              ..rotateY(_tiltY * _maxTiltRad + angle),
            child: Transform.scale(
              scale: scale,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: shadow),
                      blurRadius: 30 + math.sin(angle) * 15,
                      spreadRadius: 2,
                      offset: Offset(0, 10 + math.sin(angle) * 8),
                    ),
                  ],
                ),
                child: face,
              ),
            ),
          ),
        ),
      );
    });
  }
}
