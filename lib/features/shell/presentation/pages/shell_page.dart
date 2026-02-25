import 'package:flutter/material.dart';
import 'package:playon/core/services/location_service.dart';
import 'package:playon/features/home/presentation/pages/home_page.dart';
import 'package:playon/features/explore/presentation/pages/explore_page.dart';
import 'package:playon/features/create/presentation/pages/create_page.dart';
import 'package:playon/features/notifications/presentation/pages/notifications_page.dart';
import 'package:playon/features/profile/presentation/pages/profile_page.dart';
import 'package:playon/features/home/presentation/widgets/custom_bottom_nav.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  late final PageController _pageController;
  int _currentIndex = 0;

  // Location fetched once here, passed down to HomePage
  LocationResult _locationResult = const LocationResult(
    city: 'Locating...',
    status: LocationStatus.success,
  );

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    final result = await LocationService.getLocation();
    if (mounted) setState(() => _locationResult = result);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(
        locationResult: _locationResult,
        onRefreshLocation: _fetchLocation,
      ),
      const ExplorePage(),
      const CreatePage(),
      const NotificationsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: pages,
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
