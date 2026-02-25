import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class JoinGameSlider extends StatelessWidget {
  const JoinGameSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final games = [
      {'sport': 'Football', 'emoji': '⚽', 'time': '6:00 PM', 'players': '8/10'},
      {'sport': 'Cricket', 'emoji': '🏏', 'time': '7:30 AM', 'players': '11/22'},
      {'sport': 'Basketball', 'emoji': '🏀', 'time': '5:00 PM', 'players': '5/10'},
      {'sport': 'Badminton', 'emoji': '🏸', 'time': '4:00 PM', 'players': '3/4'},
    ];

    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: games.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final game = games[index];
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
                    Text(game['emoji']!,
                        style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text(
                      game['sport']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        color: AppColors.textSecondary, size: 13),
                    const SizedBox(width: 4),
                    Text(game['time']!,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.people,
                        color: AppColors.textSecondary, size: 13),
                    const SizedBox(width: 4),
                    Text(game['players']!,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
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
              ],
            ),
          );
        },
      ),
    );
  }
}
