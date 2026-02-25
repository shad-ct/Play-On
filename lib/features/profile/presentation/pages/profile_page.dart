import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              // Avatar
              const CircleAvatar(
                radius: 46,
                backgroundColor: Color(0xFFF0F0F0),
                child: Icon(Icons.person_rounded, size: 54, color: Colors.black54),
              ),
              const SizedBox(height: 14),
              const Text('Rohan Sharma',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Mumbai, India',
                  style: TextStyle(color: Colors.black45, fontSize: 14)),
              const SizedBox(height: 24),
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _Stat(value: '24', label: 'Games'),
                  _Stat(value: '8', label: 'Wins'),
                  _Stat(value: '1.2k', label: 'Points'),
                ],
              ),
              const SizedBox(height: 32),
              // Menu items
              _MenuItem(icon: Icons.sports_soccer, title: 'My Sport Preferences'),
              _MenuItem(icon: Icons.history, title: 'Game History'),
              _MenuItem(icon: Icons.bookmark_outline, title: 'Saved Turfs'),
              _MenuItem(icon: Icons.settings_outlined, title: 'Settings'),
              _MenuItem(icon: Icons.help_outline, title: 'Help & Support'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    side: const BorderSide(color: Colors.black12),
                  ),
                  child: const Text('Log Out',
                      style: TextStyle(color: Colors.red, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.black45, fontSize: 13)),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  const _MenuItem({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: Colors.black87),
          title: Text(title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          trailing: const Icon(Icons.arrow_forward_ios,
              size: 14, color: Colors.black38),
        ),
        const Divider(height: 1, color: Color(0xFFF0F0F0)),
      ],
    );
  }
}
