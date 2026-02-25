import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  static const _notifications = [
    _Notification('⚽ Rahul joined your Football game', '2 min ago'),
    _Notification('🏸 Your badminton booking is confirmed', '15 min ago'),
    _Notification('🏆 Weekly leaderboard has been updated', '1 hr ago'),
    _Notification('🎯 New turf available near you', '3 hrs ago'),
    _Notification('👋 Arjun sent you a game invite', 'Yesterday'),
    _Notification('✅ Payment received for turf booking', 'Yesterday'),
  ];

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Alerts',
                      style: TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Mark all read',
                        style: TextStyle(color: Colors.black54)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  itemBuilder: (context, index) {
                    final n = _notifications[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(n.message.split(' ').first,
                            style: const TextStyle(fontSize: 20)),
                      ),
                      title: Text(
                        n.message.substring(n.message.indexOf(' ') + 1),
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text(n.time,
                          style: const TextStyle(
                              color: Colors.black38, fontSize: 12)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Notification {
  final String message;
  final String time;
  const _Notification(this.message, this.time);
}
