import 'package:flutter/material.dart';

class TrophyCard extends StatelessWidget {
  const TrophyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A3A6E), Color(0xFF1A73E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber, size: 48),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekly Leaderboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Compete and win prizes this week!',
                  style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white),
        ],
      ),
    );
  }
}
