import 'package:flutter/material.dart';
import 'package:playon/features/profile/data/models/player_card_data.dart';

class PlayOnCardTheme {
  final List<Color> bgGradient;
  final Alignment gradientBegin;
  final Alignment gradientEnd;
  final Color borderColor;
  final Color glowColor;
  final double glowRadius;
  final double shimmerIntensity; // 0 = off, 1 = full
  final bool hasEliteBackground;
  final Color ratingColor;
  final Color positionColor;
  final Color nameColor;
  final List<Color> nameBgGradient;
  final Color statsLabelColor;
  final Color statsValueColor;
  final Color backBgBase;

  const PlayOnCardTheme({
    required this.bgGradient,
    required this.gradientBegin,
    required this.gradientEnd,
    required this.borderColor,
    required this.glowColor,
    required this.glowRadius,
    required this.shimmerIntensity,
    required this.hasEliteBackground,
    required this.ratingColor,
    required this.positionColor,
    required this.nameColor,
    required this.nameBgGradient,
    required this.statsLabelColor,
    required this.statsValueColor,
    required this.backBgBase,
  });
}

PlayOnCardTheme getCardTheme(CardRarity rarity, SpecialEdition edition) {
  if (rarity == CardRarity.elite) {
    switch (edition) {
      case SpecialEdition.inForm:
        return _inFormTheme;
      case SpecialEdition.legend:
        return _legendTheme;
      case SpecialEdition.streetKing:
        return _streetKingTheme;
      case SpecialEdition.none:
        return _eliteTheme;
    }
  }
  switch (rarity) {
    case CardRarity.bronze:
      return _bronzeTheme;
    case CardRarity.silver:
      return _silverTheme;
    case CardRarity.gold:
      return _goldTheme;
    case CardRarity.elite:
      return _eliteTheme;
  }
}

// ── Bronze ────────────────────────────────────────────────────────────────────
const _bronzeTheme = PlayOnCardTheme(
  bgGradient: [Color(0xFF3D1F0E), Color(0xFF6B3A1F), Color(0xFF3D1F0E)],
  gradientBegin: Alignment.topLeft,
  gradientEnd: Alignment.bottomRight,
  borderColor: Color(0xFF8B5E3C),
  glowColor: Color(0x228B5E3C),
  glowRadius: 4,
  shimmerIntensity: 0.0,
  hasEliteBackground: false,
  ratingColor: Color(0xFFE8CCAA),
  positionColor: Color(0xFFD4A97A),
  nameColor: Color(0xFFEED8BE),
  nameBgGradient: [Color(0xFF5C3317), Color(0xFF2A1005)],
  statsLabelColor: Color(0xFFCBAA88),
  statsValueColor: Color(0xFFF5E6D0),
  backBgBase: Color(0xFF1E0D06),
);

// ── Silver ────────────────────────────────────────────────────────────────────
const _silverTheme = PlayOnCardTheme(
  bgGradient: [
    Color(0xFF2C2C2E),
    Color(0xFF6E6E73),
    Color(0xFF9A9AA0),
    Color(0xFF525254),
  ],
  gradientBegin: Alignment.topLeft,
  gradientEnd: Alignment.bottomRight,
  borderColor: Color(0xFFB0B0B8),
  glowColor: Color(0x44B0B0B8),
  glowRadius: 8,
  shimmerIntensity: 0.0,
  hasEliteBackground: false,
  ratingColor: Color(0xFFF0F0F5),
  positionColor: Color(0xFFCCCCD2),
  nameColor: Color(0xFFF0F0F5),
  nameBgGradient: [Color(0xFF3A3A3C), Color(0xFF1C1C1E)],
  statsLabelColor: Color(0xFFD0D0D6),
  statsValueColor: Color(0xFFF5F5FA),
  backBgBase: Color(0xFF111112),
);

// ── Gold ─────────────────────────────────────────────────────────────────────
const _goldTheme = PlayOnCardTheme(
  bgGradient: [
    Color(0xFF3D2800),
    Color(0xFF8B6914),
    Color(0xFFC8920A),
    Color(0xFF8B6914),
    Color(0xFF3D2800),
  ],
  gradientBegin: Alignment.topLeft,
  gradientEnd: Alignment.bottomRight,
  borderColor: Color(0xFFFFD700),
  glowColor: Color(0x66FFD700),
  glowRadius: 16,
  shimmerIntensity: 1.0,
  hasEliteBackground: false,
  ratingColor: Color(0xFFFFFFFF),
  positionColor: Color(0xFFFFE566),
  nameColor: Color(0xFFFFFFFF),
  nameBgGradient: [Color(0xFF6B4F00), Color(0xFF2A1A00)],
  statsLabelColor: Color(0xFFFFE070),
  statsValueColor: Color(0xFFFFFFFF),
  backBgBase: Color(0xFF1A1000),
);

// ── Elite ─────────────────────────────────────────────────────────────────────
const _eliteTheme = PlayOnCardTheme(
  bgGradient: [
    Color(0xFF0A0014),
    Color(0xFF1A0040),
    Color(0xFF0D0030),
    Color(0xFF0A0014),
  ],
  gradientBegin: Alignment.topCenter,
  gradientEnd: Alignment.bottomCenter,
  borderColor: Color(0xFF9B59FF),
  glowColor: Color(0x889B59FF),
  glowRadius: 24,
  shimmerIntensity: 0.0,
  hasEliteBackground: true,
  ratingColor: Color(0xFFFFFFFF),
  positionColor: Color(0xFFD4B8FF),
  nameColor: Color(0xFFFFFFFF),
  nameBgGradient: [Color(0xFF2D0080), Color(0xFF080010)],
  statsLabelColor: Color(0xFFD4B8FF),
  statsValueColor: Color(0xFFFFFFFF),
  backBgBase: Color(0xFF04000C),
);

// ── In-Form (black + gold) ────────────────────────────────────────────────────
const _inFormTheme = PlayOnCardTheme(
  bgGradient: [Color(0xFF000000), Color(0xFF1A1400), Color(0xFF000000)],
  gradientBegin: Alignment.topLeft,
  gradientEnd: Alignment.bottomRight,
  borderColor: Color(0xFFFFD700),
  glowColor: Color(0x88FFD700),
  glowRadius: 20,
  shimmerIntensity: 0.8,
  hasEliteBackground: true,
  ratingColor: Color(0xFFFFD700),
  positionColor: Color(0xFFFFE566),
  nameColor: Color(0xFFFFFFFF),
  nameBgGradient: [Color(0xFF2A2000), Color(0xFF000000)],
  statsLabelColor: Color(0xFFFFE070),
  statsValueColor: Color(0xFFFFFFFF),
  backBgBase: Color(0xFF050400),
);

// ── Legend (royal blue + gold) ────────────────────────────────────────────────
const _legendTheme = PlayOnCardTheme(
  bgGradient: [
    Color(0xFF000D2E),
    Color(0xFF001A5C),
    Color(0xFF002080),
    Color(0xFF001A5C),
    Color(0xFF000D2E),
  ],
  gradientBegin: Alignment.topCenter,
  gradientEnd: Alignment.bottomCenter,
  borderColor: Color(0xFFFFD700),
  glowColor: Color(0x88FFD700),
  glowRadius: 20,
  shimmerIntensity: 0.6,
  hasEliteBackground: true,
  ratingColor: Color(0xFFFFD700),
  positionColor: Color(0xFF8AB4FF),
  nameColor: Color(0xFFFFFFFF),
  nameBgGradient: [Color(0xFF001A5C), Color(0xFF000D2E)],
  statsLabelColor: Color(0xFF8AB4FF),
  statsValueColor: Color(0xFFFFFFFF),
  backBgBase: Color(0xFF00081A),
);

// ── Street King (neon cyber) ──────────────────────────────────────────────────
const _streetKingTheme = PlayOnCardTheme(
  bgGradient: [
    Color(0xFF000A0A),
    Color(0xFF001A1A),
    Color(0xFF000A14),
  ],
  gradientBegin: Alignment.topLeft,
  gradientEnd: Alignment.bottomRight,
  borderColor: Color(0xFF00FFDD),
  glowColor: Color(0x8800FFDD),
  glowRadius: 24,
  shimmerIntensity: 0.0,
  hasEliteBackground: true,
  ratingColor: Color(0xFF00FFDD),
  positionColor: Color(0xFF00FFDD),
  nameColor: Color(0xFF00FFDD),
  nameBgGradient: [Color(0xFF001A1A), Color(0xFF000505)],
  statsLabelColor: Color(0xFF00B8A0),
  statsValueColor: Color(0xFF00FFDD),
  backBgBase: Color(0xFF000505),
);
