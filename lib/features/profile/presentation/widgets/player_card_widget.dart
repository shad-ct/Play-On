import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:playon/features/profile/data/models/player_card_data.dart';
import 'package:playon/features/profile/presentation/widgets/card_rarity_theme.dart';
import 'package:playon/features/profile/presentation/widgets/shimmer_overlay.dart';
import 'package:playon/features/profile/presentation/widgets/elite_bg_painter.dart';

class PlayerCardWidget extends StatefulWidget {
  final PlayerCardData data;
  final SpecialEdition edition;
  final bool reducedMotion;
  final bool animationPaused;

  const PlayerCardWidget({
    super.key,
    required this.data,
    this.edition = SpecialEdition.none,
    this.reducedMotion = false,
    this.animationPaused = false,
  });

  @override
  State<PlayerCardWidget> createState() => _PlayerCardWidgetState();
}

class _PlayerCardWidgetState extends State<PlayerCardWidget>
    with TickerProviderStateMixin {
  AnimationController? _shimmerCtrl;
  AnimationController? _eliteCtrl;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final theme = getCardTheme(widget.data.rarity, widget.edition);
    if (!widget.reducedMotion && theme.shimmerIntensity > 0 && !theme.hasEliteBackground) {
      _shimmerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))
        ..repeat(reverse: true);
    }
    if (!widget.reducedMotion && theme.hasEliteBackground) {
      _eliteCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))
        ..repeat();
    }
  }

  void _disposeControllers() {
    _shimmerCtrl?.dispose();
    _shimmerCtrl = null;
    _eliteCtrl?.dispose();
    _eliteCtrl = null;
  }

  @override
  void didUpdateWidget(PlayerCardWidget old) {
    super.didUpdateWidget(old);
    // Pause / resume on flip
    if (widget.animationPaused != old.animationPaused) {
      if (widget.animationPaused) {
        _shimmerCtrl?.stop();
        _eliteCtrl?.stop();
      } else {
        _shimmerCtrl?.repeat();
        _eliteCtrl?.repeat();
      }
    }
    // Rarity or edition changed — recreate controllers
    if (widget.data.rarity != old.data.rarity || widget.edition != old.edition) {
      _disposeControllers();
      _initControllers();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = getCardTheme(widget.data.rarity, widget.edition);
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: LayoutBuilder(
        builder: (ctx, box) {
          final sf = box.maxWidth / 300;
          return _buildCard(theme, sf, box.maxWidth);
        },
      ),
    );
  }

  Widget _buildCard(PlayOnCardTheme theme, double sf, double cardW) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.bgGradient,
          begin: theme.gradientBegin,
          end: theme.gradientEnd,
        ),
        borderRadius: BorderRadius.circular(16 * sf),
        border: Border.all(color: theme.borderColor, width: 1.5 * sf),
        boxShadow: [
          BoxShadow(
            color: theme.glowColor,
            blurRadius: theme.glowRadius * sf,
            spreadRadius: 2 * sf,
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Elite animated background
          if (theme.hasEliteBackground)
            Positioned.fill(
              child: _eliteCtrl != null
                  ? AnimatedBuilder(
                      animation: _eliteCtrl!,
                      builder: (ctx2, child2) => CustomPaint(
                        painter: EliteBgPainter(value: _eliteCtrl!.value, theme: theme),
                      ),
                    )
                  : CustomPaint(painter: EliteBgPainter(value: 0.3, theme: theme)),
            ),
          // Shimmer overlay (Gold / In-Form)
          if (_shimmerCtrl != null)
            Positioned.fill(
              child: ShimmerOverlay(
                animation: _shimmerCtrl!,
                intensity: theme.shimmerIntensity,
              ),
            ),
          // In-Form shimmer (hasEliteBackground=true but shimmerIntensity>0)
          if (theme.hasEliteBackground && theme.shimmerIntensity > 0 && _shimmerCtrl != null)
            Positioned.fill(
              child: ShimmerOverlay(
                animation: _shimmerCtrl!,
                intensity: theme.shimmerIntensity * 0.5,
              ),
            ),
          // Card content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14 * sf, vertical: 12 * sf),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TopSection(data: widget.data, theme: theme, sf: sf),
                SizedBox(height: 6 * sf),
                _AvatarSection(data: widget.data, theme: theme, sf: sf, cardW: cardW),
                SizedBox(height: 8 * sf),
                _NameBar(data: widget.data, theme: theme, sf: sf),
                SizedBox(height: 10 * sf),
                _StatsGrid(data: widget.data, theme: theme, sf: sf),
                const Spacer(),
                _Footer(theme: theme, sf: sf),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top Section ───────────────────────────────────────────────────────────────
class _TopSection extends StatelessWidget {
  final PlayerCardData data;
  final PlayOnCardTheme theme;
  final double sf;
  const _TopSection({required this.data, required this.theme, required this.sf});

  @override
  Widget build(BuildContext context) {
    final isElite = data.rarity == CardRarity.elite;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating
            Text(
              '${data.rating}',
              style: TextStyle(
                color: theme.ratingColor,
                fontSize: 48 * sf,
                fontWeight: FontWeight.w900,
                height: 1.0,
                letterSpacing: -1,
                shadows: isElite
                    ? [
                        Shadow(color: theme.glowColor, blurRadius: 14 * sf),
                        Shadow(color: theme.borderColor.withValues(alpha: 0.9), blurRadius: 4 * sf),
                      ]
                    : null,
              ),
            ),
            // Position
            Text(
              data.position,
              style: TextStyle(
                color: theme.positionColor,
                fontSize: 11 * sf,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const Spacer(),
        // Jersey badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 9 * sf, vertical: 5 * sf),
          decoration: BoxDecoration(
            color: theme.borderColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20 * sf),
            border: Border.all(color: theme.borderColor.withValues(alpha: 0.7), width: sf),
          ),
          child: Text(
            '#${data.jerseyNumber}',
            style: TextStyle(
              color: theme.ratingColor,
              fontSize: 11 * sf,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Avatar Section ────────────────────────────────────────────────────────────
class _AvatarSection extends StatelessWidget {
  final PlayerCardData data;
  final PlayOnCardTheme theme;
  final double sf;
  final double cardW;
  const _AvatarSection(
      {required this.data, required this.theme, required this.sf, required this.cardW});

  @override
  Widget build(BuildContext context) {
    final size = cardW * 0.52;
    final hasImage = data.profileImageUrl != null && data.profileImageUrl!.isNotEmpty;
    return Center(
      child: Transform.translate(
        offset: Offset(0, -6 * sf),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.borderColor, width: 2.5 * sf),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.55),
                    blurRadius: 18 * sf,
                    offset: Offset(0, 8 * sf),
                  ),
                  BoxShadow(
                    color: theme.glowColor.withValues(alpha: 0.45),
                    blurRadius: 14 * sf,
                  ),
                ],
              ),
              child: ClipOval(
                child: hasImage
                    ? Image.network(
                        data.profileImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => _buildFallbackAvatar(size),
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return _buildFallbackAvatar(size);
                        },
                      )
                    : _buildFallbackAvatar(size),
              ),
            ),
            // Verified badge
            if (data.isVerified)
              Positioned(
                right: 2 * sf,
                bottom: 2 * sf,
                child: Container(
                  width: 22 * sf,
                  height: 22 * sf,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1DA1F2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.bgGradient.first,
                      width: 2 * sf,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1DA1F2).withValues(alpha: 0.4),
                        blurRadius: 6 * sf,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 13 * sf,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar(double size) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.borderColor.withValues(alpha: 0.12),
            Colors.black.withValues(alpha: 0.35),
          ],
        ),
      ),
      child: Icon(
        Icons.person_rounded,
        size: size * 0.72,
        color: theme.ratingColor.withValues(alpha: 0.85),
      ),
    );
  }
}

// ── Name Bar ──────────────────────────────────────────────────────────────────
class _NameBar extends StatelessWidget {
  final PlayerCardData data;
  final PlayOnCardTheme theme;
  final double sf;
  const _NameBar({required this.data, required this.theme, required this.sf});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 7 * sf, horizontal: 10 * sf),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.nameBgGradient,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(4 * sf),
        border: Border.all(color: theme.borderColor.withValues(alpha: 0.35), width: 0.5 * sf),
      ),
      child: Text(
        data.name.toUpperCase(),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: theme.nameColor,
          fontSize: 13 * sf,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.5,
        ),
      ),
    );
  }
}

// ── Stats Grid ────────────────────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final PlayerCardData data;
  final PlayOnCardTheme theme;
  final double sf;
  const _StatsGrid({required this.data, required this.theme, required this.sf});

  @override
  Widget build(BuildContext context) {
    final left = [
      ('GMS', data.gamesPlayed.toString()),
      ('WNS', data.wins.toString()),
      ('GLS', data.goals.toString()),
    ];
    final right = [
      ('AST', data.assists.toString()),
      ('CLN', data.cleanSheets.toString()),
      ('AVG', data.avgMatchRating.toStringAsFixed(1)),
    ];

    return LayoutBuilder(builder: (ctx, box) {
      final colW = box.maxWidth / 2;
      final valSz = math.min(18.0 * sf, colW * 0.36);
      final lblSz = math.min(9.0 * sf, colW * 0.2);

      return Row(
        children: [
          _StatCol(stats: left, theme: theme, valSz: valSz, lblSz: lblSz, sf: sf),
          Container(width: 0.6, height: 60 * sf, color: theme.borderColor.withValues(alpha: 0.25)),
          _StatCol(stats: right, theme: theme, valSz: valSz, lblSz: lblSz, sf: sf),
        ],
      );
    });
  }
}

class _StatCol extends StatelessWidget {
  final List<(String, String)> stats;
  final PlayOnCardTheme theme;
  final double valSz, lblSz, sf;
  const _StatCol(
      {required this.stats, required this.theme, required this.valSz, required this.lblSz, required this.sf});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: stats
            .map((s) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.5 * sf, horizontal: 8 * sf),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s.$1,
                          style: TextStyle(
                              color: theme.statsLabelColor,
                              fontSize: lblSz,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1)),
                      Text(s.$2,
                          style: TextStyle(
                              color: theme.statsValueColor,
                              fontSize: valSz,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  final PlayOnCardTheme theme;
  final double sf;
  const _Footer({required this.theme, required this.sf});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'playON',
        style: TextStyle(
          color: theme.borderColor.withValues(alpha: 0.55),
          fontSize: 8 * sf,
          fontWeight: FontWeight.w900,
          letterSpacing: 4,
        ),
      ),
    );
  }
}
