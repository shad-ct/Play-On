import 'package:playon/features/profile/data/models/player_card_data.dart';

class UserModel {
  final String id;
  final String username;
  final String password;
  final String email;
  final String fullName;
  final String? profileImageUrl;
  final bool isVerified;
  final int age;
  final String city;
  final String country;
  final String preferredFoot;
  final String primaryPosition;
  final List<String> secondaryPositions;
  final int jerseyNumber;
  final int rating;
  final String rarity;
  final String? specialEdition;
  final String sportPreference;
  final Map<String, int> stats;
  final Map<String, dynamic> career;
  final List<String> badges;
  final List<String> savedTurfs;
  final List<Map<String, dynamic>> recentMatches;

  const UserModel({
    required this.id,
    required this.username,
    required this.password,
    required this.email,
    required this.fullName,
    this.profileImageUrl,
    this.isVerified = false,
    required this.age,
    required this.city,
    required this.country,
    required this.preferredFoot,
    required this.primaryPosition,
    required this.secondaryPositions,
    required this.jerseyNumber,
    required this.rating,
    required this.rarity,
    this.specialEdition,
    required this.sportPreference,
    required this.stats,
    required this.career,
    required this.badges,
    required this.savedTurfs,
    required this.recentMatches,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      age: json['age'] as int,
      city: json['city'] as String,
      country: json['country'] as String,
      preferredFoot: json['preferredFoot'] as String,
      primaryPosition: json['primaryPosition'] as String,
      secondaryPositions: List<String>.from(json['secondaryPositions'] ?? []),
      jerseyNumber: json['jerseyNumber'] as int,
      rating: json['rating'] as int,
      rarity: json['rarity'] as String,
      specialEdition: json['specialEdition'] as String?,
      sportPreference: json['sportPreference'] as String,
      stats: Map<String, int>.from(json['stats'] ?? {}),
      career: Map<String, dynamic>.from(json['career'] ?? {}),
      badges: List<String>.from(json['badges'] ?? []),
      savedTurfs: List<String>.from(json['savedTurfs'] ?? []),
      recentMatches: List<Map<String, dynamic>>.from(
        (json['recentMatches'] as List?)?.map((e) => Map<String, dynamic>.from(e)) ?? [],
      ),
    );
  }

  /// Convert to [PlayerCardData] for the profile card widget.
  PlayerCardData toPlayerCardData() {
    final badgeList = badges.map((b) {
      switch (b) {
        case 'mvp':
          return BadgeType.mvp;
        case 'topScorer':
          return BadgeType.topScorer;
        case 'ironDefender':
          return BadgeType.ironDefender;
        case 'cleanSheet':
          return BadgeType.cleanSheet;
        case 'assist':
          return BadgeType.assistKing;
        default:
          return null;
      }
    }).whereType<BadgeType>().toList();

    final gamesPlayed = (career['gamesPlayed'] as num?)?.toInt() ?? 0;
    final wins = (career['wins'] as num?)?.toInt() ?? 0;
    final goals = (career['goals'] as num?)?.toInt() ?? 0;
    final assists = (career['assists'] as num?)?.toInt() ?? 0;
    final cleanSheets = (career['cleanSheets'] as num?)?.toInt() ?? 0;
    final reliabilityScore = (career['reliabilityScore'] as num?)?.toDouble() ?? 0;
    final avgMatchRating = (career['averageMatchRating'] as num?)?.toDouble() ?? 0;

    return PlayerCardData(
      name: fullName,
      position: primaryPosition,
      secondaryPosition: secondaryPositions.isNotEmpty ? secondaryPositions.first : null,
      rating: rating,
      jerseyNumber: jerseyNumber,
      city: city,
      age: age,
      preferredFoot: preferredFoot,
      profileImageUrl: profileImageUrl,
      isVerified: isVerified,
      pace: stats['PAC'] ?? 50,
      shooting: stats['SHO'] ?? 50,
      passing: stats['PAS'] ?? 50,
      dribbling: stats['DRI'] ?? 50,
      defense: stats['DEF'] ?? 50,
      physical: stats['PHY'] ?? 50,
      gamesPlayed: gamesPlayed,
      wins: wins,
      goals: goals,
      assists: assists,
      cleanSheets: cleanSheets,
      reliabilityScore: reliabilityScore / 100, // JSON stores 0-100, model expects 0.0-1.0
      bio: '$fullName from $city. $primaryPosition specialist.',
      recentMatchSummary: _buildRecentSummary(),
      avgMatchRating: avgMatchRating,
      badges: badgeList,
    );
  }

  String _buildRecentSummary() {
    if (recentMatches.isEmpty) return 'No recent matches';
    final results = recentMatches.map((m) {
      final r = m['result'] as String? ?? '?';
      return r[0]; // W / L / D
    }).join(' ');
    return 'Recent: $results · Avg ${(career['averageMatchRating'] as num?)?.toStringAsFixed(1) ?? '-'}';
  }
}
