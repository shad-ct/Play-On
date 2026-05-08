import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'host_manage_game_page.dart';

class CreateGamePage extends StatefulWidget {
  const CreateGamePage({super.key});

  @override
  State<CreateGamePage> createState() => _CreateGamePageState();
}

class _CreateGamePageState extends State<CreateGamePage> {
  final _supabase = Supabase.instance.client;
  String? _selectedSport;
  int _numPlayers = 10;
  String? _selectedTurfId;
  List<dynamic> _turfs = [];
  bool _isLoading = true;
  bool _isCreating = false;
  bool _isPublic = true;
  DateTime? _selectedDate;
  List<String> _availableSlots = [];
  String? _selectedSlot;

  String? _generatedCode;
  String? _generatedGameId;

  @override
  void initState() {
    super.initState();
    _fetchTurfs();
  }

  Future<void> _fetchTurfs() async {
    try {
      final data = await _supabase.from('turfs').select('id, name, open_time, close_time');
      setState(() {
        _turfs = data;
        if (_turfs.isNotEmpty) {
          _selectedTurfId = _turfs[0]['id'];
        }
        _selectedDate = DateTime.now();
        _isLoading = false;
      });
      _calculateSlots();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching turfs: $e')),
        );
      }
    }
  }

  Future<void> _calculateSlots() async {
    if (_selectedTurfId == null || _selectedDate == null) return;
    
    final turf = _turfs.firstWhere((t) => t['id'] == _selectedTurfId, orElse: () => null);
    if (turf == null) return;
    
    final openTimeStr = turf['open_time'] as String?;
    final closeTimeStr = turf['close_time'] as String?;
    
    if (openTimeStr == null || closeTimeStr == null) {
      setState(() {
        _availableSlots = [];
        _selectedSlot = null;
      });
      return;
    }
    
    final openHour = int.parse(openTimeStr.split(':')[0]);
    final closeHour = int.parse(closeTimeStr.split(':')[0]);
    
    final dateStr = _selectedDate!.toIso8601String().split('T')[0];
    try {
      final existingGames = await _supabase
          .from('games')
          .select('start_time')
          .eq('turf_id', _selectedTurfId!)
          .eq('game_date', dateStr);
          
      final Set<String> bookedTimes = existingGames
          .map((g) => (g['start_time'] as String).substring(0, 5))
          .toSet();
          
      List<String> slots = [];
      for (int i = openHour; i < closeHour; i++) {
        final timeStr = '${i.toString().padLeft(2, '0')}:00';
        if (!bookedTimes.contains(timeStr)) {
          slots.add(timeStr);
        }
      }
      
      setState(() {
        _availableSlots = slots;
        _selectedSlot = slots.isNotEmpty ? slots.first : null;
      });
    } catch (e) {
      setState(() {
        _availableSlots = [];
        _selectedSlot = null;
      });
    }
  }

  String _generateGameCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(
      6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  Future<void> _createGame() async {
    if (_selectedSport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a sport')),
      );
      return;
    }
    if (_selectedTurfId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a turf')),
      );
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an available time slot')),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    final code = _generateGameCode();
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in')),
      );
      setState(() => _isCreating = false);
      return;
    }

    try {
      final response = await _supabase.from('games').insert({
        'code': code,
        'host_id': userId,
        'sport': _selectedSport,
        'max_players': _numPlayers,
        'turf_id': _selectedTurfId,
        'is_public': _isPublic,
        'game_date': _selectedDate!.toIso8601String().split('T')[0],
        'start_time': _selectedSlot,
      }).select().single();

      setState(() {
        _isCreating = false;
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HostManageGamePage(
              gameId: response['id'],
              gameCode: code,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isCreating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating game: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Game'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Sport', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildSportChip('Football'),
                      const SizedBox(width: 10),
                      _buildSportChip('Cricket'),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text('Number of Players', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (_numPlayers > 2) setState(() => _numPlayers--);
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('$_numPlayers', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: () {
                          if (_numPlayers < 50) setState(() => _numPlayers++);
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text('Select Turf', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  _turfs.isEmpty
                      ? const Text('No turfs available')
                      : DropdownButtonFormField<String>(
                          value: _selectedTurfId,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          items: _turfs.map<DropdownMenuItem<String>>((turf) {
                            return DropdownMenuItem<String>(
                              value: turf['id'],
                              child: Text(turf['name']),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedTurfId = val;
                            });
                            _calculateSlots();
                          },
                        ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate ?? DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 30)),
                                );
                                if (date != null) {
                                  setState(() => _selectedDate = date);
                                  _calculateSlots();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(_selectedDate?.toIso8601String().split('T')[0] ?? 'Select Date'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Time Slot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: _selectedSlot,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              items: _availableSlots.map<DropdownMenuItem<String>>((slot) {
                                return DropdownMenuItem<String>(
                                  value: slot,
                                  child: Text(slot),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedSlot = val;
                                });
                              },
                              hint: const Text('Slot'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Public Game', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Switch(
                        value: _isPublic,
                        onChanged: (val) {
                          setState(() {
                            _isPublic = val;
                          });
                        },
                        activeColor: Colors.black,
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isCreating ? null : _createGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isCreating
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Create Game', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSportChip(String sport) {
    final isSelected = _selectedSport == sport;
    return ChoiceChip(
      label: Text(sport),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _selectedSport = sport);
      },
      selectedColor: Colors.black,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    );
  }
}
