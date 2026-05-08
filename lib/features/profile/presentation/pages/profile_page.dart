import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:playon/core/models/user_model.dart';
import 'package:playon/core/services/auth_service.dart';
import 'package:playon/features/auth/presentation/pages/login_page.dart';
import 'package:playon/features/profile/presentation/widgets/player_card_3d_wrapper.dart';
import 'package:playon/features/profile/presentation/widgets/rarity_progress_bar.dart';

class ProfilePage extends StatefulWidget {
  final UserModel user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _reducedMotion = false;
  final GlobalKey _cardKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _handleShare() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      // Find the RepaintBoundary and capture the card as an image
      final boundary = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      // Write to temp file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/playon_card.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      // Share via system share sheet
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Check out my PlayON player card! ⚽🔥',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not share card: $e'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              _MenuItem(icon: Icons.sports_soccer, title: 'My Sport Preferences'),
              _MenuItem(icon: Icons.history, title: 'Game History'),
              _MenuItem(icon: Icons.bookmark_outline, title: 'Saved Turfs'),
              _MenuItem(icon: Icons.settings_outlined, title: 'Settings'),
              _MenuItem(icon: Icons.help_outline, title: 'Help & Support'),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(ctx); // close bottom sheet first
                    _handleLogout();
                  },
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reducedMotion = MediaQuery.of(context).devicePixelRatio < 2.0;
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.user.toPlayerCardData();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 4, 0),
              child: Row(
                children: [
                  Text(
                    'MY CARD',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: _isSharing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black38,
                            ),
                          )
                        : const Icon(Icons.ios_share_rounded, color: Colors.black54, size: 20),
                    onPressed: _isSharing ? null : _handleShare,
                    tooltip: 'Share Card',
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz_rounded, color: Colors.black54),
                    onPressed: _showMoreOptions,
                  ),
                ],
              ),
            ),

            // ── Player card (fills remaining space) ────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Center(
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: PlayerCard3dWrapper(
                      data: data,
                      reducedMotion: _reducedMotion,
                    ),
                  ),
                ),
              ),
            ),

            // ── Progress bar ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 8),
              child: RarityProgressBar(rating: data.rating),
            ),

            // ── Hint ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'TAP TO FLIP  •  DRAG TO TILT',
                style: TextStyle(
                  color: Colors.black26,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5,
                ),
              ),
            ),
          ],
        ),
      ),
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

