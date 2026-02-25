// Rarity logic lives here only — UI must never compute rarity.

enum CardRarity { bronze, silver, gold, elite }

enum SpecialEdition { none, inForm, legend, streetKing }

enum BadgeType { mvp, topScorer, ironDefender, cleanSheet, assistKing }

CardRarity getRarityFromRating(int rating) {
  if (rating >= 90) return CardRarity.elite;
  if (rating >= 75) return CardRarity.gold;
  if (rating >= 60) return CardRarity.silver;
  return CardRarity.bronze;
}

bool isSpecialEligible(int rating) => rating >= 90;

String rarityLabel(CardRarity r) =>
    const {
      CardRarity.bronze: 'Bronze',
      CardRarity.silver: 'Silver',
      CardRarity.gold: 'Gold',
      CardRarity.elite: 'Elite',
    }[r]!;

/// Returns the bottom of the current tier.
int currentTierStart(int rating) {
  if (rating >= 90) return 90;
  if (rating >= 75) return 75;
  if (rating >= 60) return 60;
  return 0;
}

/// Returns the threshold for the next tier, or null at max.
int? nextTierThreshold(int rating) {
  if (rating < 60) return 60;
  if (rating < 75) return 75;
  if (rating < 90) return 90;
  if (rating < 95) return 95;
  return null;
}

String nextRarityLabel(int rating) {
  if (rating < 60) return 'Silver';
  if (rating < 75) return 'Gold';
  if (rating < 90) return 'Elite';
  return 'Special';
}

class PlayerCardData {
  final String name;
  final String position;
  final String? secondaryPosition;
  final int rating;
  final int jerseyNumber;
  final String city;
  final int age;
  final String preferredFoot;
  final String? profileImageUrl;
  final bool isVerified;

  // Front stats
  final int pace;
  final int shooting;
  final int passing;
  final int dribbling;
  final int defense;
  final int physical;

  // Back stats
  final int gamesPlayed;
  final int wins;
  final int goals;
  final int assists;
  final int cleanSheets;
  final double reliabilityScore; // 0.0–1.0
  final String bio;
  final String recentMatchSummary;
  final double avgMatchRating;
  final List<BadgeType> badges;

  const PlayerCardData({
    required this.name,
    required this.position,
    this.secondaryPosition,
    required this.rating,
    required this.jerseyNumber,
    required this.city,
    required this.age,
    required this.preferredFoot,
    this.profileImageUrl,
    this.isVerified = false,
    required this.pace,
    required this.shooting,
    required this.passing,
    required this.dribbling,
    required this.defense,
    required this.physical,
    required this.gamesPlayed,
    required this.wins,
    required this.goals,
    required this.assists,
    required this.cleanSheets,
    required this.reliabilityScore,
    required this.bio,
    required this.recentMatchSummary,
    required this.avgMatchRating,
    required this.badges,
  });

  CardRarity get rarity => getRarityFromRating(rating);
  bool get specialEligible => isSpecialEligible(rating);
  int get winPercentage =>
      gamesPlayed > 0 ? ((wins / gamesPlayed) * 100).round() : 0;

  PlayerCardData copyWith({int? rating}) => PlayerCardData(
        name: name,
        position: position,
        secondaryPosition: secondaryPosition,
        rating: rating ?? this.rating,
        jerseyNumber: jerseyNumber,
        city: city,
        age: age,
        preferredFoot: preferredFoot,
        profileImageUrl: profileImageUrl,
        isVerified: isVerified,
        pace: pace,
        shooting: shooting,
        passing: passing,
        dribbling: dribbling,
        defense: defense,
        physical: physical,
        gamesPlayed: gamesPlayed,
        wins: wins,
        goals: goals,
        assists: assists,
        cleanSheets: cleanSheets,
        reliabilityScore: reliabilityScore,
        bio: bio,
        recentMatchSummary: recentMatchSummary,
        avgMatchRating: avgMatchRating,
        badges: badges,
      );
}

// ── Sample data for the showcase page ────────────────────────────────────────
const kSamplePlayerCard = PlayerCardData(
  name: 'Rohan Sharma',
  position: 'ST',
  secondaryPosition: 'CAM',
  rating: 82,
  jerseyNumber: 10,
  city: 'Mumbai',
  age: 24,
  preferredFoot: 'Right',
  pace: 85,
  shooting: 82,
  passing: 76,
  dribbling: 80,
  defense: 45,
  physical: 74,
  gamesPlayed: 48,
  wins: 31,
  goals: 27,
  assists: 14,
  cleanSheets: 0,
  reliabilityScore: 0.92,
  bio: 'Clinical striker with lethal finishing and electric pace. '
      'Known for big-game performances and pressure-situation goals.',
  recentMatchSummary: 'Last 5: W W L W W · 3G 2A · Avg 8.4',
  avgMatchRating: 7.9,
  badges: [BadgeType.topScorer, BadgeType.mvp],
);
