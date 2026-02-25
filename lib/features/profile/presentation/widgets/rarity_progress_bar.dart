import 'package:flutter/material.dart';
import 'package:playon/features/profile/data/models/player_card_data.dart';
import 'package:playon/features/profile/presentation/widgets/card_rarity_theme.dart';

/// Animated fill bar showing progress toward the next rarity tier.
/// Hidden automatically when the player is already at 95+.
class RarityProgressBar extends StatelessWidget {
  final int rating;
  final SpecialEdition edition;

  const RarityProgressBar({
    super.key,
    required this.rating,
    this.edition = SpecialEdition.none,
  });

  @override
  Widget build(BuildContext context) {
    final next = nextTierThreshold(rating);
    if (next == null) {
      // Max tier — show a "MAX" chip
      final theme = getCardTheme(CardRarity.elite, edition);
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: theme.borderColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.borderColor.withValues(alpha: 0.5)),
          ),
          child: Text('✦  MAXIMUM TIER  ✦',
              style: TextStyle(
                  color: theme.borderColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2)),
        ),
      );
    }

    final currentStart = currentTierStart(rating);
    final range = next - currentStart;
    final progress = ((rating - currentStart) / range).clamp(0.0, 1.0);
    final rarity = getRarityFromRating(rating);
    final theme = getCardTheme(rarity, edition);
    final nextLabel = nextRarityLabel(rating);
    final gap = next - rating;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: progress),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOut,
      builder: (ctx, value, child2) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(rarityLabel(rarity).toUpperCase(),
                    style: TextStyle(
                        color: theme.borderColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5)),
                Text('+$gap to $nextLabel',
                    style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 7,
                backgroundColor: theme.borderColor.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(theme.borderColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
