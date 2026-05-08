import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:playon/core/models/user_model.dart';
import 'package:playon/core/services/auth_service.dart';
import 'package:playon/features/auth/presentation/pages/sign_up_page.dart';
import 'package:playon/features/shell/presentation/pages/shell_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  bool _isLoading = false;
  bool _obscure = true;
  String? _error;
  String? _success;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _handleSignIn() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });

    try {
      final user = await AuthService.signIn(email, pass);
      if (!mounted) return;
      _goToShell(user);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Something went wrong. Please try again.';
      });
    }
  }

  void _goToShell(UserModel user) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (ctx, anim, sanim) => ShellPage(user: user),
        transitionsBuilder: (ctx, anim, sanim, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _goToSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SignUpPage()),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: Colors.white,
      // resizeToAvoidBottomInset lets the scroll view react to the keyboard
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: CustomScrollView(
              // ClampingScrollPhysics: scroll only when needed, never over-scroll
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  // hasScrollBody: false means the child fills the space exactly;
                  // the scroll view only activates when the keyboard pushes content up.
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(28, 0, 28, bottom + 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),

                        // ── Branding ─────────────────────────────────────────
                        _buildBranding(),
                        const SizedBox(height: 40),

                        // ── Success banner (e.g. post-registration) ───────────
                        if (_success != null) ...[
                          _buildBanner(message: _success!, isError: false),
                          const SizedBox(height: 12),
                        ],

                        // ── Email ─────────────────────────────────────────────
                        _buildField(
                          controller: _emailCtrl,
                          focusNode: _emailFocus,
                          hint: 'Email Address',
                          icon: Icons.email_outlined,
                          keyboard: TextInputType.emailAddress,
                          onSubmit: (v) => _passFocus.requestFocus(),
                        ),
                        const SizedBox(height: 14),

                        // ── Password ──────────────────────────────────────────
                        _buildField(
                          controller: _passCtrl,
                          focusNode: _passFocus,
                          hint: 'Password',
                          icon: Icons.lock_outline_rounded,
                          obscure: _obscure,
                          onSubmit: (v) => _handleSignIn(),
                          suffix: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.black38,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),

                    // ── Error ─────────────────────────────────────────────
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      child: _error != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: _buildBanner(message: _error!, isError: true),
                            )
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 20),

                    // ── Sign In button ────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.black87,
                          disabledForegroundColor: Colors.white70,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: Colors.white),
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Divider ───────────────────────────────────────────
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Color(0xFFEEEEEE))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'or',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: Color(0xFFEEEEEE))),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Sign Up button ────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _goToSignUp,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────────────────

  Widget _buildBranding() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text('⚽', style: TextStyle(fontSize: 32)),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'PlayON',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Welcome back, player',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboard,
    ValueChanged<String>? onSubmit,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscure,
        keyboardType: keyboard,
        textInputAction: TextInputAction.next,
        onSubmitted: onSubmit,
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildBanner({required String message, required bool isError}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isError ? Icons.error_outline : Icons.check_circle_outline,
          size: 16,
          color: isError ? const Color(0xFFE53935) : const Color(0xFF2E7D32),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              color: isError ? const Color(0xFFE53935) : const Color(0xFF2E7D32),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
