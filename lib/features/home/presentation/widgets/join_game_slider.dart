import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../create/presentation/pages/join_game_page.dart';
import '../pages/public_game_details_page.dart';

class JoinGameSlider extends StatefulWidget {
  const JoinGameSlider({super.key});

  @override
  State<JoinGameSlider> createState() => _JoinGameSliderState();
}

class _JoinGameSliderState extends State<JoinGameSlider> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _games = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGames();
  }

  Future<void> _fetchGames() async {
    try {
      final data = await _supabase
          .from('games')
          .select('*, turfs(name)')
          .eq('is_public', true)
          .eq('status', 'open')
          .order('created_at', ascending: false)
          .limit(10);
      setState(() {
        _games = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  final _sportEmojis = {
    'Football': '⚽',
    'Cricket': '🏏',
    'Badminton': '🏸',
  };

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 150,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_games.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(child: Text('No public games available right now.')),
      );
    }

    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _games.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final game = _games[index];
          final sport = game['sport'] ?? 'Unknown';
          final emoji = _sportEmojis[sport] ?? '🎯';
          
          return Container(
            width: 190,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        sport,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: AppColors.textSecondary, size: 13),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        game['turfs']?['name'] ?? 'Unknown Turf',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.people,
                        color: AppColors.textSecondary, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      'Max ${game['max_players']} players',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                       Navigator.push(context, MaterialPageRoute(builder: (_) => PublicGameDetailsPage(game: game)));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Text('Join',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
