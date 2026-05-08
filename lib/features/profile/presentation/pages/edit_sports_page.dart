import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:playon/core/models/user_model.dart';
import 'package:playon/features/shell/presentation/pages/shell_page.dart';

const _sportEmojis = {
  'Football': '⚽',
  'Cricket': '🏏',
  'Badminton': '🏸',
};

const _sportPositions = {
  'Football': [
    'Goalkeeper (GK)',
    'Centre-Back (CB)',
    'Left-Back (LB)',
    'Right-Back (RB)',
    'Def. Midfielder (CDM)',
    'Central Midfielder (CM)',
    'Att. Midfielder (CAM)',
    'Left Wing (LW)',
    'Right Wing (RW)',
    'Striker (ST)',
    'Centre Forward (CF)',
  ],
  'Cricket': [
    'Batsman',
    'Fast Bowler',
    'Spin Bowler',
    'All-Rounder',
    'Wicket-Keeper',
    'Wicket-Keeper Batsman',
    'Opening Batsman',
  ],
  'Badminton': [
    'Singles Player',
    'Doubles Player',
    'Mixed Doubles',
    'Smash Specialist',
    'Net Player',
  ],
};

class EditSportsPage extends StatefulWidget {
  final UserModel user;
  const EditSportsPage({super.key, required this.user});

  @override
  State<EditSportsPage> createState() => _EditSportsPageState();
}

class _EditSportsPageState extends State<EditSportsPage> {
  late final Set<String> _selectedSports;
  late final Map<String, List<String>> _sportPositionMap;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedSports = Set.from(widget.user.sportPreferences);
    _sportPositionMap = Map.from(widget.user.sportPositions);
  }

  Future<void> _save() async {
    if (_selectedSports.isEmpty) {
      _showSnack('Pick at least one sport.');
      return;
    }
    for (final s in _selectedSports) {
      if (!(_sportPositionMap.containsKey(s)) || _sportPositionMap[s]!.isEmpty) {
        _showSnack('Pick at least one position for $s.');
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      final updates = {
        'sportPreferences': _selectedSports.toList(),
        'sportPositions': _sportPositionMap,
        if (_selectedSports.isNotEmpty)
          'primaryPosition': _sportPositionMap[_selectedSports.first]?.first ?? widget.user.primaryPosition,
      };

      final client = Supabase.instance.client;
      await client.auth.updateUser(UserAttributes(data: updates));
      
      try {
        await client.from('users').update(updates).eq('id', widget.user.id);
      } catch (_) {} // Best effort table update

      if (!mounted) return;
      _showSnack('Preferences saved!', success: true);
      
      // Update session locally by reloading the user. 
      // A full app restart/reload is easiest. For now, pop and user will see old data until refresh, 
      // or we can push a new ShellPage. Let's push a new shell page.
      final newUser = UserModel.fromSupabaseUser(client.auth.currentUser!);
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (ctx, anim, sanim) => ShellPage(user: newUser),
          transitionsBuilder: (ctx, anim, sanim, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
        (_) => false,
      );

    } catch (e) {
      _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? Colors.green.shade700 : Colors.red.shade700,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black87),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          'My Sport Preferences',
          style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select sports',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              _buildSports(),
              const SizedBox(height: 32),
              const Text(
                'Select positions (Max 3 per sport)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              _buildPositions(),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Save Preferences', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSports() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _sportEmojis.keys.map((sport) {
        final sel = _selectedSports.contains(sport);
        return GestureDetector(
          onTap: () => setState(() {
            if (sel) {
              _selectedSports.remove(sport);
              _sportPositionMap.remove(sport);
            } else {
              _selectedSports.add(sport);
            }
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: sel ? Colors.black : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: sel ? Colors.black : const Color(0xFFE8E8E8)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_sportEmojis[sport]!, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(sport, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: sel ? Colors.white : Colors.black87)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPositions() {
    if (_selectedSports.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text('Please select at least one sport above.', style: TextStyle(color: Colors.black38)),
      );
    }
    return Column(
      children: _selectedSports.map((sport) {
        final positions = _sportPositions[sport] ?? [];
        final chosen = _sportPositionMap[sport] ?? [];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(_sportEmojis[sport] ?? '', style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(sport, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.black87)),
                  const Spacer(),
                  Text('${chosen.length}/3', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: chosen.length == 3 ? Colors.black87 : Colors.black45)),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: positions.map((pos) {
                  final sel = chosen.contains(pos);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        final list = List<String>.from(chosen);
                        if (sel) {
                          list.remove(pos);
                        } else if (list.length < 3) {
                          list.add(pos);
                        }
                        _sportPositionMap[sport] = list;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? Colors.black : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: sel ? Colors.black : const Color(0xFFE8E8E8)),
                      ),
                      child: Text(pos, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: sel ? Colors.white : Colors.black54)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
