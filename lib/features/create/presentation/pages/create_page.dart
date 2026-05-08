import 'package:flutter/material.dart';
import 'create_game_page.dart';
import 'join_game_page.dart';

class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('What would you like to create?',
                  style: TextStyle(color: Colors.black54, fontSize: 15)),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateGamePage()));
                },
                child: const _CreateOption(
                  icon: Icons.sports_soccer_rounded,
                  title: 'New Game',
                  subtitle: 'Set up a game and invite players',
                  color: Color(0xFFE8F5E9),
                  iconColor: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              const _CreateOption(
                icon: Icons.stadium_rounded,
                title: 'Book a Turf',
                subtitle: 'Reserve a slot at your nearest turf',
                color: Color(0xFFE3F2FD),
                iconColor: Colors.blue,
              ),
              const SizedBox(height: 16),
              const _CreateOption(
                icon: Icons.emoji_events_rounded,
                title: 'Host a Tournament',
                subtitle: 'Organize a competitive event',
                color: Color(0xFFFFF8E1),
                iconColor: Colors.orange,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const JoinGamePage()));
        },
        backgroundColor: Colors.black,
        icon: const Icon(Icons.login, color: Colors.white),
        label: const Text('Join Game', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _CreateOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;

  const _CreateOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black38),
        ],
      ),
    );
  }
}
