import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:playon/core/models/user_model.dart';
import 'package:playon/core/services/auth_service.dart';
import 'package:playon/features/shell/presentation/pages/shell_page.dart';

// ── Sport positions data ───────────────────────────────────────────────────

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

// ── Page ───────────────────────────────────────────────────────────────────

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  // Steps: 0=Credentials, 1=Profile, 2=Sports, 3=Positions
  int _step = 0;
  final int _totalSteps = 4;

  // ── Step 0 ────────────────────────────────────────────────────────────────
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  // ── Step 1 ────────────────────────────────────────────────────────────────
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  DateTime? _dob;
  String _foot = 'Right';

  // ── Step 2 ────────────────────────────────────────────────────────────────
  final Set<String> _selectedSports = {};

  // ── Step 3 ────────────────────────────────────────────────────────────────
  // sport → chosen positions (up to 3)
  final Map<String, List<String>> _sportPositionMap = {};

  // ── Shared state ──────────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _error;

  late final AnimationController _stepAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _stepAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _stepAnim, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.06, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _stepAnim, curve: Curves.easeOut));
    _stepAnim.forward();
  }

  @override
  void dispose() {
    _stepAnim.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _animateStep(VoidCallback fn) {
    _stepAnim.reset();
    setState(fn);
    _stepAnim.forward();
  }

  bool _validateStep() {
    switch (_step) {
      case 0:
        if (_emailCtrl.text.trim().isEmpty) {
          _error = 'Enter your email address.';
          return false;
        }
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailCtrl.text.trim())) {
          _error = 'Enter a valid email address.';
          return false;
        }
        if (_passCtrl.text.length < 6) {
          _error = 'Password must be at least 6 characters.';
          return false;
        }
        if (_passCtrl.text != _confirmCtrl.text) {
          _error = 'Passwords do not match.';
          return false;
        }
      case 1:
        if (_nameCtrl.text.trim().isEmpty) {
          _error = 'Enter your full name.';
          return false;
        }
        if (_phoneCtrl.text.trim().isEmpty) {
          _error = 'Enter your phone number.';
          return false;
        }
        if (_cityCtrl.text.trim().isEmpty) {
          _error = 'Enter your city.';
          return false;
        }
        if (_dob == null) {
          _error = 'Select your date of birth.';
          return false;
        }
      case 2:
        if (_selectedSports.isEmpty) {
          _error = 'Pick at least one sport.';
          return false;
        }
      case 3:
        for (final s in _selectedSports) {
          if (!_sportPositionMap.containsKey(s) || _sportPositionMap[s]!.isEmpty) {
            _error = 'Pick at least one position for $s.';
            return false;
          }
        }
    }
    return true;
  }

  void _next() {
    setState(() => _error = null);
    if (!_validateStep()) {
      setState(() {});
      return;
    }
    if (_step < _totalSteps - 1) {
      _animateStep(() => _step++);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_step == 0) {
      Navigator.of(context).pop();
    } else {
      _animateStep(() {
        _step--;
        _error = null;
      });
    }
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dob = _dob!;
      final age = _ageFrom(dob);
      final primarySport = _selectedSports.first;
      final primaryPos = _sportPositionMap[primarySport]?.isNotEmpty == true
          ? _sportPositionMap[primarySport]!.first
          : '';

      final user = await AuthService.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        displayName: _nameCtrl.text.trim(),
        metadata: {
          'full_name': _nameCtrl.text.trim(),
          'phone_number': _phoneCtrl.text.trim(),
          'city': _cityCtrl.text.trim(),
          'dob': dob.toIso8601String().substring(0, 10),
          'age': age,
          'preferredFoot': _foot,
          'primaryPosition': primaryPos,
          'sportPreferences': _selectedSports.toList(),
          'sportPositions': _sportPositionMap,
        },
      );

      if (!mounted) return;

      if (user.isVerified) {
        _goToShell(user);
      } else {
        Navigator.of(context).pop(); // back to login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Account created! Check your email then sign in.'),
            backgroundColor: Color(0xFF2E7D32),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } on AuthException catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Something went wrong. Try again.';
      });
    }
  }

  void _goToShell(UserModel user) {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (ctx, anim, sanim) => ShellPage(user: user),
        transitionsBuilder: (ctx, anim, sanim, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (_) => false,
    );
  }

  int _ageFrom(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black87),
          onPressed: _isLoading ? null : _back,
        ),
        title: const Text(
          'Create Account',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStepHeader(),
                        const SizedBox(height: 24),
                        _buildStepBody(),
                        if (_error != null) ...[
                          const SizedBox(height: 16),
                          _buildError(),
                        ],
                        const SizedBox(height: 24),
                        _buildNextButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Progress bar ──────────────────────────────────────────────────────────

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Row(
        children: List.generate(_totalSteps, (i) {
          final active = i <= _step;
          return Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(right: i < _totalSteps - 1 ? 6 : 0),
              decoration: BoxDecoration(
                color: active ? Colors.black : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Step headers ──────────────────────────────────────────────────────────

  static const _stepTitles = [
    'Set up your credentials',
    'Tell us about yourself',
    'Pick your sports',
    'Your positions',
  ];
  static const _stepSubtitles = [
    'You\'ll use these to sign in',
    'Your name, city & birthday',
    'Select all sports you play',
    'Choose your role in each sport',
  ];

  Widget _buildStepHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step ${_step + 1} of $_totalSteps',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: Colors.black38,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _stepTitles[_step],
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _stepSubtitles[_step],
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black45,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ── Step body router ──────────────────────────────────────────────────────

  Widget _buildStepBody() {
    switch (_step) {
      case 0:
        return _buildCredentialsStep();
      case 1:
        return _buildProfileStep();
      case 2:
        return _buildSportsStep();
      case 3:
        return _buildPositionsStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Step 0: Credentials ───────────────────────────────────────────────────

  Widget _buildCredentialsStep() {
    return Column(
      children: [
        _field(
          controller: _emailCtrl,
          hint: 'Email Address',
          icon: Icons.email_outlined,
          keyboard: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        _field(
          controller: _passCtrl,
          hint: 'Password',
          icon: Icons.lock_outline_rounded,
          obscure: _obscurePass,
          suffix: _eyeBtn(() => setState(() => _obscurePass = !_obscurePass), _obscurePass),
        ),
        const SizedBox(height: 14),
        _field(
          controller: _confirmCtrl,
          hint: 'Confirm Password',
          icon: Icons.lock_outline_rounded,
          obscure: _obscureConfirm,
          suffix: _eyeBtn(() => setState(() => _obscureConfirm = !_obscureConfirm), _obscureConfirm),
        ),
      ],
    );
  }

  // ── Step 1: Profile ───────────────────────────────────────────────────────

  Widget _buildProfileStep() {
    return Column(
      children: [
        _field(
          controller: _nameCtrl,
          hint: 'Full Name',
          icon: Icons.person_outline_rounded,
          keyboard: TextInputType.name,
        ),
        const SizedBox(height: 14),
        _field(
          controller: _phoneCtrl,
          hint: 'Phone Number',
          icon: Icons.phone_outlined,
          keyboard: TextInputType.phone,
        ),
        const SizedBox(height: 14),
        _field(
          controller: _cityCtrl,
          hint: 'City',
          icon: Icons.location_city_outlined,
        ),
        const SizedBox(height: 14),

        // DOB picker
        GestureDetector(
          onTap: _pickDob,
          child: _fieldShell(
            child: Row(
              children: [
                const SizedBox(width: 16),
                const Icon(Icons.cake_outlined, color: Colors.black38, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _dob == null
                        ? 'Date of Birth'
                        : '${_dob!.day.toString().padLeft(2, '0')} / '
                            '${_dob!.month.toString().padLeft(2, '0')} / '
                            '${_dob!.year}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: _dob == null ? FontWeight.w400 : FontWeight.w500,
                      color: _dob == null
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.black87,
                    ),
                  ),
                ),
                const Icon(Icons.expand_more_rounded, color: Colors.black26, size: 20),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Preferred foot
        _sectionLabel('Preferred Foot'),
        const SizedBox(height: 10),
        Row(
          children: ['Right', 'Left', 'Both'].map((f) {
            final selected = _foot == f;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _foot = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? Colors.black : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? Colors.black : const Color(0xFFE8E8E8),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    f,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1960),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.black,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  // ── Step 2: Sport selection ────────────────────────────────────────────────

  Widget _buildSportsStep() {
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: sel ? Colors.black : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: sel ? Colors.black : const Color(0xFFE8E8E8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_sportEmojis[sport]!, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Text(
                  sport,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : Colors.black87,
                  ),
                ),
                if (sel) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Step 3: Positions per sport ────────────────────────────────────────────

  Widget _buildPositionsStep() {
    final sports = _selectedSports.toList();
    return Column(
      children: sports.map((sport) {
        final positions = _sportPositions[sport] ?? [];
        final chosen = _sportPositionMap[sport] ?? [];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _sportEmojis[sport] ?? '',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    sport,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${chosen.length}/3',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: chosen.length == 3 ? Colors.black87 : Colors.black45,
                    ),
                  ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: sel ? Colors.black : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: sel ? Colors.black : const Color(0xFFE8E8E8),
                        ),
                      ),
                      child: Text(
                        pos,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : Colors.black54,
                        ),
                      ),
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

  // ── Error banner ──────────────────────────────────────────────────────────

  Widget _buildError() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.error_outline, size: 16, color: Color(0xFFE53935)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _error!,
            style: const TextStyle(
              color: Color(0xFFE53935),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ── Next / submit button ──────────────────────────────────────────────────

  Widget _buildNextButton() {
    final isLast = _step == _totalSteps - 1;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _next,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.black87,
          disabledForegroundColor: Colors.white70,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Text(
                isLast ? 'Create Account  🚀' : 'Continue',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
      ),
    );
  }

  // ── Shared field widgets ──────────────────────────────────────────────────

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboard,
  }) {
    return _fieldShell(
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        textInputAction: TextInputAction.next,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.black38, size: 20),
          suffixIcon: suffix,
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.black.withValues(alpha: 0.3),
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _fieldShell({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: child,
    );
  }

  Widget _eyeBtn(VoidCallback onTap, bool obscured) {
    return IconButton(
      icon: Icon(
        obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: Colors.black38,
        size: 20,
      ),
      onPressed: onTap,
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: Colors.black45,
      ),
    );
  }
}
