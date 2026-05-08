import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HostManageGamePage extends StatefulWidget {
  final String gameId;
  final String gameCode;

  const HostManageGamePage({
    super.key,
    required this.gameId,
    required this.gameCode,
  });

  @override
  State<HostManageGamePage> createState() => _HostManageGamePageState();
}

class _HostManageGamePageState extends State<HostManageGamePage> {
  final _supabase = Supabase.instance.client;

  Future<void> _updatePlayerStatus(String playerId, String status) async {
    try {
      await _supabase
          .from('game_players')
          .update({'status': status})
          .eq('game_id', widget.gameId)
          .eq('player_id', playerId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating player: $e')),
        );
      }
    }
  }

  void _showPlayerCard(Map<String, dynamic> player) {
    // Navigate to player card or show modal
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(player['users']['full_name'] ?? 'Player Stats'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Rating: ${player['users']['rating'] ?? 'N/A'}'),
              Text('Preferred Position: ${player['users']['position'] ?? 'N/A'}'),
              const SizedBox(height: 10),
              const Text('Card would be displayed here.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Game'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Game Code', style: TextStyle(color: Colors.grey)),
                      Text(
                        widget.gameCode,
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 5),
                      ),
                    ],
                  ),
                ),
                QrImageView(
                  data: widget.gameCode,
                  version: QrVersions.auto,
                  size: 80.0,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _supabase
                  .from('game_players')
                  .stream(primaryKey: ['id'])
                  .eq('game_id', widget.gameId)
                  .order('created_at'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final players = snapshot.data ?? [];
                
                if (players.isEmpty) {
                  return const Center(child: Text('Waiting for players to join...'));
                }

                return ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final p = players[index];
                    final playerId = p['player_id'];
                    final status = p['status'];

                    return FutureBuilder<Map<String, dynamic>>(
                      future: _supabase.from('users').select().eq('id', playerId).single(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const ListTile(title: Text('Loading user...'));
                        }

                        final user = userSnapshot.data!;
                        final displayName = user['full_name'] ?? 'Unknown User';

                        return ListTile(
                          title: Text(displayName),
                          subtitle: Text('Status: $status'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.info_outline, color: Colors.blue),
                                onPressed: () {
                                  _showPlayerCard({'users': user});
                                },
                              ),
                              if (status == 'pending') ...[
                                IconButton(
                                  icon: const Icon(Icons.check_circle, color: Colors.green),
                                  onPressed: () => _updatePlayerStatus(playerId, 'accepted'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel, color: Colors.red),
                                  onPressed: () => _updatePlayerStatus(playerId, 'rejected'),
                                ),
                              ] else if (status == 'accepted') ...[
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () => _updatePlayerStatus(playerId, 'removed'),
                                ),
                              ]
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
