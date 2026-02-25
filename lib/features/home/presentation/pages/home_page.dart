import 'package:flutter/material.dart';
import 'package:playon/core/services/location_service.dart';
import 'package:playon/core/theme/app_colors.dart';
import 'package:playon/core/utils/constants.dart';
import '../widgets/join_game_slider.dart';
import '../widgets/location_badge.dart';
import '../widgets/nearest_turf_slider.dart';
import '../widgets/trophy_card.dart';

class HomePage extends StatelessWidget {
  final LocationResult locationResult;
  final VoidCallback onRefreshLocation;

  const HomePage({
    super.key,
    required this.locationResult,
    required this.onRefreshLocation,
  });

  Future<void> _handleLocationTap() async {
    switch (locationResult.status) {
      case LocationStatus.serviceDisabled:
        await LocationService.openLocationSettings();
        onRefreshLocation();
        break;
      case LocationStatus.permissionDeniedForever:
        await LocationService.openAppSettings();
        onRefreshLocation();
        break;
      case LocationStatus.permissionDenied:
      case LocationStatus.error:
        onRefreshLocation();
        break;
      case LocationStatus.success:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.horizontalPadding,
              vertical: AppConstants.verticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 28, color: AppColors.textDark),
                        children: [
                          const TextSpan(text: 'Play'),
                          TextSpan(
                            text: 'ON',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    LocationBadge(
                      location: locationResult.city,
                      status: locationResult.status,
                      onTap: _handleLocationTap,
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                _buildSectionTitle('Join Game', underline: true),
                const SizedBox(height: 15),
                const JoinGameSlider(),
                const SizedBox(height: 30),

                _buildSectionTitle('Nearest Turf', underline: false),
                const SizedBox(height: 15),
                const NearestTurfSlider(),
                const SizedBox(height: 30),

                const TrophyCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {required bool underline}) {
    return Container(
      decoration: underline
          ? BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: AppColors.primaryBlue, width: 3)),
            )
          : null,
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}