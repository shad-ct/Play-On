import 'package:flutter/material.dart';
import 'package:playon/features/profile/data/models/player_card_data.dart';
import 'package:playon/features/profile/presentation/widgets/card_rarity_theme.dart';

class PlayerCardBackWidget extends StatelessWidget {
  final PlayerCardData data;
  final SpecialEdition edition;

  const PlayerCardBackWidget({
    super.key,
    required this.data,
    this.edition = SpecialEdition.none,
  });

  @override
  Widget build(BuildContext context) {
    final theme = getCardTheme(data.rarity, edition);
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: LayoutBuilder(builder: (_, box) {
        final sf = box.maxWidth / 300;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.backBgBase,
                Color.lerp(theme.backBgBase, theme.borderColor.withValues(alpha: 0.08), 0.5)!,
                theme.backBgBase,
              ],
            ),
            borderRadius: BorderRadius.circular(16 * sf),
            border: Border.all(color: theme.borderColor, width: 1.5 * sf),
            boxShadow: [
              BoxShadow(color: theme.glowColor, blurRadius: theme.glowRadius * sf, spreadRadius: sf),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14 * sf, vertical: 12 * sf),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _backHeader(theme, sf),
                _divider(theme, sf),
                _performanceStats(theme, sf),
                _divider(theme, sf),
                _bioSection(theme, sf),
                _divider(theme, sf),
                _badgesRow(theme, sf),
                const Spacer(),
                Center(
                  child: Text('playON',
                      style: TextStyle(
                          color: theme.borderColor.withValues(alpha: 0.4),
                          fontSize: 7 * sf,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4)),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _divider(PlayOnCardTheme theme, double sf) =>
      Padding(
        padding: EdgeInsets.symmetric(vertical: 7 * sf),
        child: Divider(color: theme.borderColor.withValues(alpha: 0.25), height: 0),
      );

  Widget _backHeader(PlayOnCardTheme theme, double sf) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(data.name.toUpperCase(),
            style: TextStyle(
                color: theme.nameColor,
                fontSize: 15 * sf,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5)),
        SizedBox(height: 5 * sf),
        _infoRow(theme, sf, 'City', data.city),
        _infoRow(theme, sf, 'Age', '${data.age}'),
        _infoRow(theme, sf, 'Foot', data.preferredFoot),
        _infoRow(theme, sf, 'Position',
            data.secondaryPosition != null
                ? '${data.position}  •  ${data.secondaryPosition}'
                : data.position),
      ],
    );
  }

  Widget _infoRow(PlayOnCardTheme theme, double sf, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.5 * sf),
      child: Row(
        children: [
          SizedBox(
            width: 60 * sf,
            child: Text(label,
                style: TextStyle(
                    color: theme.statsLabelColor,
                    fontSize: 8 * sf,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8)),
          ),
          Text(value,
              style: TextStyle(
                  color: theme.statsValueColor,
                  fontSize: 9 * sf,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _performanceStats(PlayOnCardTheme theme, double sf) {
    final stats = [
      ('Games', '${data.gamesPlayed}'),
      ('Wins', '${data.wins}'),
      ('Win %', '${data.winPercentage}%'),
      ('Goals', '${data.goals}'),
      ('Assists', '${data.assists}'),
      if (data.cleanSheets > 0) ('Clean Sheets', '${data.cleanSheets}'),
      ('Reliability', '${(data.reliabilityScore * 100).toStringAsFixed(0)}%'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PERFORMANCE',
            style: TextStyle(
                color: theme.borderColor,
                fontSize: 7 * sf,
                fontWeight: FontWeight.w800,
                letterSpacing: 2)),
        SizedBox(height: 5 * sf),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.4,
          mainAxisSpacing: 4 * sf,
          crossAxisSpacing: 4 * sf,
          children: stats
              .map((s) => _statTile(theme, sf, s.$1, s.$2))
              .toList(),
        ),
      ],
    );
  }

  Widget _statTile(PlayOnCardTheme theme, double sf, String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 3 * sf, horizontal: 4 * sf),
      decoration: BoxDecoration(
        color: theme.borderColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(4 * sf),
        border: Border.all(color: theme.borderColor.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style: TextStyle(
                  color: theme.statsValueColor,
                  fontSize: 11 * sf,
                  fontWeight: FontWeight.w900)),
          Text(label,
              style: TextStyle(
                  color: theme.statsLabelColor,
                  fontSize: 6.5 * sf,
                  fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _bioSection(PlayOnCardTheme theme, double sf) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('BIO',
            style: TextStyle(
                color: theme.borderColor,
                fontSize: 7 * sf,
                fontWeight: FontWeight.w800,
                letterSpacing: 2)),
        SizedBox(height: 4 * sf),
        Text(data.bio,
            style: TextStyle(
                color: theme.statsValueColor.withValues(alpha: 0.75),
                fontSize: 8 * sf,
                height: 1.5),
            maxLines: 3,
            overflow: TextOverflow.ellipsis),
        SizedBox(height: 5 * sf),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8 * sf, vertical: 4 * sf),
          decoration: BoxDecoration(
            color: theme.borderColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4 * sf),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, color: theme.borderColor, size: 10 * sf),
              SizedBox(width: 4 * sf),
              Text(data.recentMatchSummary,
                  style: TextStyle(
                      color: theme.statsValueColor,
                      fontSize: 7.5 * sf,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        SizedBox(height: 4 * sf),
        Text('Avg Rating: ${data.avgMatchRating.toStringAsFixed(1)}',
            style: TextStyle(
                color: theme.borderColor,
                fontSize: 9 * sf,
                fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _badgesRow(PlayOnCardTheme theme, double sf) {
    if (data.badges.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ACHIEVEMENTS',
            style: TextStyle(
                color: theme.borderColor,
                fontSize: 7 * sf,
                fontWeight: FontWeight.w800,
                letterSpacing: 2)),
        SizedBox(height: 5 * sf),
        Wrap(
          spacing: 6 * sf,
          runSpacing: 4 * sf,
          children: data.badges.map((b) => _badge(theme, sf, b)).toList(),
        ),
      ],
    );
  }

  Widget _badge(PlayOnCardTheme theme, double sf, BadgeType badge) {
    final info = _badgeInfo(badge);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7 * sf, vertical: 3 * sf),
      decoration: BoxDecoration(
        color: theme.borderColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20 * sf),
        border: Border.all(color: theme.borderColor.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info.$1, color: theme.borderColor, size: 9 * sf),
          SizedBox(width: 3 * sf),
          Text(info.$2,
              style: TextStyle(
                  color: theme.nameColor,
                  fontSize: 7 * sf,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  (IconData, String) _badgeInfo(BadgeType badge) {
    switch (badge) {
      case BadgeType.mvp:
        return (Icons.emoji_events_rounded, 'MVP');
      case BadgeType.topScorer:
        return (Icons.sports_soccer_rounded, 'Top Scorer');
      case BadgeType.ironDefender:
        return (Icons.shield_rounded, 'Iron Defender');
      case BadgeType.cleanSheet:
        return (Icons.lock_rounded, 'Clean Sheet');
      case BadgeType.assistKing:
        return (Icons.compare_arrows_rounded, 'Assist King');
    }
  }
}
