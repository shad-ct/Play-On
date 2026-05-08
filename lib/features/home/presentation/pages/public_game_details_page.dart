import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PublicGameDetailsPage extends StatefulWidget {
  final Map<String, dynamic> game;
  const PublicGameDetailsPage({super.key, required this.game});

  @override
  State<PublicGameDetailsPage> createState() => _PublicGameDetailsPageState();
}

class _PublicGameDetailsPageState extends State<PublicGameDetailsPage> {
  final _supabase = Supabase.instance.client;
  List<dynamic> _players = [];
  bool _isLoading = true;
  bool _isRequesting = false;
  String? _myStatus;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      
      // Fetch players
      final playersData = await _supabase
          .from('game_players')
          .select('status, player_id, users(raw_user_meta_data)')
          .eq('game_id', widget.game['id']);

      setState(() {
        _players = playersData;
        if (userId != null) {
          final myRecord = playersData.where((p) => p['player_id'] == userId).toList();
          if (myRecord.isNotEmpty) {
            _myStatus = myRecord.first['status'];
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _requestJoin() async {
    setState(() => _isRequesting = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw 'Not logged in';

      await _supabase.from('game_players').insert({
        'game_id': widget.game['id'],
        'player_id': userId,
        'status': 'pending',
      });
      
      await _fetchDetails();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent to host!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isRequesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final acceptedPlayers = _players.where((p) => p['status'] == 'accepted').toList();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.game['sport']} Game'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Turf: ${widget.game['turfs']?['name'] ?? 'Unknown'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('Date: ${widget.game['game_date'] ?? 'TBD'}'),
                  Text('Time: ${widget.game['start_time'] ?? 'TBD'}'),
                  const SizedBox(height: 20),
                  Text('Players (${acceptedPlayers.length}/${widget.game['max_players']})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: acceptedPlayers.length,
                      itemBuilder: (context, index) {
                        final p = acceptedPlayers[index];
                        final meta = p['users']?['raw_user_meta_data'] ?? {};
                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(meta['full_name'] ?? 'Unknown Player'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_myStatus == null && _supabase.auth.currentUser?.id != widget.game['host_id'])
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isRequesting ? null : _requestJoin,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                        child: _isRequesting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Request to Join', style: TextStyle(color: Colors.white)),
                      ),
                    )
                  else if (_myStatus != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: _myStatus == 'accepted' ? Colors.green.shade100 : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Your status: ${_myStatus!.toUpperCase()}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _myStatus == 'accepted' ? Colors.green.shade800 : Colors.orange.shade800,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
