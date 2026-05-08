import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:playon/features/profile/data/models/player_card_data.dart';

class UserModel {
  final String id;
  final String username;
  // NOTE: password is never stored — authentication is handled by Supabase Auth.
  final String email;
  final String? phoneNumber;
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
  final List<String> sportPreferences;
  final Map<String, List<String>> sportPositions;
  final String? dateOfBirth;
  final Map<String, int> stats;
  final Map<String, dynamic> career;
  final List<String> badges;
  final List<String> savedTurfs;
  final List<Map<String, dynamic>> recentMatches;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.phoneNumber,
    required this.fullName,
    this.profileImageUrl,
    this.isVerified = false,
    this.age = 0,
    this.city = '',
    this.country = '',
    this.preferredFoot = 'Right',
    this.primaryPosition = 'MID',
    this.secondaryPositions = const [],
    this.jerseyNumber = 0,
    this.rating = 50,
    this.rarity = 'Common',
    this.specialEdition,
    this.sportPreference = 'Football',
    this.sportPreferences = const [],
    this.sportPositions = const {},
    this.dateOfBirth,
    this.stats = const {},
    this.career = const {},
    this.badges = const [],
    this.savedTurfs = const [],
    this.recentMatches = const [],
  });

  // ── Factories ──────────────────────────────────────────────────────────────

  /// Build a minimal [UserModel] from a Supabase [User].
  /// Player-profile fields default to neutral values until the user fills them in.
  factory UserModel.fromSupabaseUser(User user) {
    final meta = user.userMetadata ?? {};
    final fullName = (meta['full_name'] as String?)?.trim() ?? '';
    final email = user.email ?? '';
    // Derive a clean username: use the part before '@' in the email.
    final username = fullName.isNotEmpty
        ? fullName.split(' ').first.toLowerCase()
        : email.split('@').first;

    return UserModel(
      id: user.id,
      username: username,
      email: email,
      phoneNumber: meta['phone_number'] as String? ?? user.phone,
      fullName: fullName.isNotEmpty ? fullName : username,
      profileImageUrl: meta['avatar_url'] as String?,
      isVerified: user.emailConfirmedAt != null,
      age: (meta['age'] as num?)?.toInt() ?? 0,
      city: meta['city'] as String? ?? '',
      country: meta['country'] as String? ?? '',
      preferredFoot: meta['preferredFoot'] as String? ?? 'Right',
      primaryPosition: meta['primaryPosition'] as String? ?? 'MID',
      secondaryPositions: List<String>.from(meta['secondaryPositions'] ?? []),
      jerseyNumber: (meta['jerseyNumber'] as num?)?.toInt() ?? 0,
      rating: (meta['rating'] as num?)?.toInt() ?? 50,
      rarity: meta['rarity'] as String? ?? 'Common',
      specialEdition: meta['specialEdition'] as String?,
      sportPreference: meta['sportPreference'] as String? ?? 'Football',
      sportPreferences: List<String>.from(meta['sportPreferences'] ?? []),
      sportPositions: meta['sportPositions'] != null
          ? Map<String, List<String>>.from(
              (meta['sportPositions'] as Map).map((k, v) => MapEntry(
                  k.toString(),
                  v is List ? List<String>.from(v) : [v.toString()])))
          : {},
      dateOfBirth: meta['dob'] as String?,
      stats: Map<String, int>.from(meta['stats'] ?? {}),
      career: Map<String, dynamic>.from(meta['career'] ?? {}),
      badges: List<String>.from(meta['badges'] ?? []),
      savedTurfs: List<String>.from(meta['savedTurfs'] ?? []),
      recentMatches: List<Map<String, dynamic>>.from(
        (meta['recentMatches'] as List?)?.map((e) => Map<String, dynamic>.from(e)) ?? [],
      ),
    );
  }

  /// Build from a raw JSON map (legacy / local data support).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      fullName: json['fullName'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      age: json['age'] as int? ?? 0,
      city: json['city'] as String? ?? '',
      country: json['country'] as String? ?? '',
      preferredFoot: json['preferredFoot'] as String? ?? 'Right',
      primaryPosition: json['primaryPosition'] as String? ?? 'MID',
      secondaryPositions: List<String>.from(json['secondaryPositions'] ?? []),
      jerseyNumber: json['jerseyNumber'] as int? ?? 0,
      rating: json['rating'] as int? ?? 50,
      rarity: json['rarity'] as String? ?? 'Common',
      specialEdition: json['specialEdition'] as String?,
      sportPreference: json['sportPreference'] as String? ?? 'Football',
      sportPreferences: List<String>.from(json['sportPreferences'] ?? []),
      sportPositions: json['sportPositions'] != null
          ? Map<String, List<String>>.from(
              (json['sportPositions'] as Map).map((k, v) => MapEntry(
                  k.toString(),
                  v is List ? List<String>.from(v) : [v.toString()])))
          : {},
      dateOfBirth: json['dob'] as String?,
      stats: Map<String, int>.from(json['stats'] ?? {}),
      career: Map<String, dynamic>.from(json['career'] ?? {}),
      badges: List<String>.from(json['badges'] ?? []),
      savedTurfs: List<String>.from(json['savedTurfs'] ?? []),
      recentMatches: List<Map<String, dynamic>>.from(
        (json['recentMatches'] as List?)?.map((e) => Map<String, dynamic>.from(e)) ?? [],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

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

    // Calculate rating based on performance.
    int calculatedRating = 50;
    if (gamesPlayed > 0) {
      calculatedRating += (avgMatchRating * 4).toInt(); // up to +40
      calculatedRating += (wins / gamesPlayed * 10).toInt(); // up to +10
      calculatedRating += (goals * 0.5).toInt();
      calculatedRating += (assists * 0.5).toInt();
      calculatedRating += (cleanSheets * 1.0).toInt();
      if (calculatedRating > 99) calculatedRating = 99;
    }

    return PlayerCardData(
      name: fullName.isNotEmpty ? fullName : username,
      position: primaryPosition,
      secondaryPosition: secondaryPositions.isNotEmpty ? secondaryPositions.first : null,
      rating: gamesPlayed > 0 ? calculatedRating : rating,
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
      reliabilityScore: reliabilityScore / 100,
      bio: city.isNotEmpty
          ? '$fullName from $city. $primaryPosition specialist.'
          : '$fullName · $primaryPosition',
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
