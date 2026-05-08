import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:playon/core/services/auth_service.dart';
import 'package:playon/features/auth/presentation/pages/login_page.dart';
import 'package:playon/features/shell/presentation/pages/shell_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://wwuguqavinfyozpspbog.supabase.co',
    anonKey: 'sb_publishable_jUJi4AQq29iSCbL9BVjtrg_Lx3j7lS6',
  );
  runApp(const PlayOnApp());
}

class PlayOnApp extends StatelessWidget {
  const PlayOnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlayON',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.light,
        ),
      ),
      home: const _SessionGate(),
    );
  }
}

/// Checks Supabase for a valid session before deciding the initial route.
class _SessionGate extends StatefulWidget {
  const _SessionGate();

  @override
  State<_SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<_SessionGate> {
  @override
  void initState() {
    super.initState();
    _tryRestore();
  }

  Future<void> _tryRestore() async {
    final user = await AuthService.tryRestoreSession();
    if (!mounted) return;

    final destination = user != null ? ShellPage(user: user) : const LoginPage();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, anim, secondaryAnimation, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Splash screen while restoring session
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '⚽',
              style: TextStyle(fontSize: 48),
            ),
            SizedBox(height: 16),
            Text(
              'PlayON',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.black26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}