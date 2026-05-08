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
  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;

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

  // Removed _calculateSlots as we use free form time selection now
  
  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
  
  String _formatTime(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';
  }

  bool _isOverlap(TimeOfDay start1, TimeOfDay end1, TimeOfDay start2, TimeOfDay end2) {
    final start1Mins = start1.hour * 60 + start1.minute;
    final end1Mins = end1.hour * 60 + end1.minute;
    final start2Mins = start2.hour * 60 + start2.minute;
    final end2Mins = end2.hour * 60 + end2.minute;
    return start1Mins < end2Mins && end1Mins > start2Mins;
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
    if (_fromTime == null || _toTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select From and To times')),
      );
      return;
    }

    final fromMins = _fromTime!.hour * 60 + _fromTime!.minute;
    final toMins = _toTime!.hour * 60 + _toTime!.minute;
    if (fromMins >= toMins) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('To time must be after From time')),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    final code = _generateGameCode();
    final user = _supabase.auth.currentUser;
    final userId = user?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in')),
      );
      setState(() => _isCreating = false);
      return;
    }

    try {
      final dateStr = _selectedDate!.toIso8601String().split('T')[0];

      // Check overlap
      final existingBookings = await _supabase
          .from('bookings')
          .select('start_time, end_time')
          .eq('turf_id', _selectedTurfId!)
          .eq('booking_date', dateStr)
          .neq('status', 'rejected');

      final existingGames = await _supabase
          .from('games')
          .select('start_time, end_time')
          .eq('turf_id', _selectedTurfId!)
          .eq('game_date', dateStr);

      for (var b in existingBookings) {
        if (b['start_time'] == null || b['end_time'] == null) continue;
        final bStart = _parseTime(b['start_time']);
        final bEnd = _parseTime(b['end_time']);
        if (_isOverlap(_fromTime!, _toTime!, bStart, bEnd)) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Time slot is already booked')));
          setState(() => _isCreating = false);
          return;
        }
      }

      for (var g in existingGames) {
        if (g['start_time'] == null || g['end_time'] == null) continue;
        final gStart = _parseTime(g['start_time']);
        final gEnd = _parseTime(g['end_time']);
        if (_isOverlap(_fromTime!, _toTime!, gStart, gEnd)) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Time slot is already booked')));
          setState(() => _isCreating = false);
          return;
        }
      }

      final meta = user?.userMetadata ?? {};
      final playerName = meta['full_name'] ?? user?.email ?? 'Unknown Player';
      final playerPhone = meta['phone_number'] ?? user?.phone ?? '0000000000';

      final startTimeStr = _formatTime(_fromTime!);
      final endTimeStr = _formatTime(_toTime!);

      // Insert booking for Turf owner approval
      await _supabase.from('bookings').insert({
        'turf_id': _selectedTurfId,
        'player_name': playerName,
        'player_phone': playerPhone,
        'booking_date': dateStr,
        'start_time': startTimeStr,
        'end_time': endTimeStr,
        'status': 'pending',
      });

      // Insert game
      final response = await _supabase.from('games').insert({
        'code': code,
        'host_id': userId,
        'sport': _selectedSport,
        'max_players': _numPlayers,
        'turf_id': _selectedTurfId,
        'is_public': _isPublic,
        'game_date': dateStr,
        'start_time': startTimeStr,
        'end_time': endTimeStr,
        'approval_status': 'pending',
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
                            const Text('From Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: _fromTime ?? TimeOfDay.now(),
                                );
                                if (time != null) setState(() => _fromTime = time);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(_fromTime?.format(context) ?? 'Select Time'),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text('To Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: _toTime ?? TimeOfDay.now(),
                                );
                                if (time != null) setState(() => _toTime = time);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(_toTime?.format(context) ?? 'Select Time'),
                              ),
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
