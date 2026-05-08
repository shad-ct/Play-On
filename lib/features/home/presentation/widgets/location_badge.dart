import 'package:flutter/material.dart';
import 'package:playon/core/services/location_service.dart';
import 'package:playon/core/theme/app_colors.dart';

class LocationBadge extends StatelessWidget {
  final String location;
  final LocationStatus status;
  final VoidCallback? onTap;

  const LocationBadge({
    super.key,
    required this.location,
    required this.status,
    this.onTap,
  });

  IconData _iconFor(LocationStatus s) {
    if (s == LocationStatus.permissionDeniedForever) return Icons.settings_outlined;
    if (s == LocationStatus.serviceDisabled) return Icons.location_disabled;
    if (s == LocationStatus.permissionDenied) return Icons.location_off;
    if (s == LocationStatus.error) return Icons.refresh;
    return Icons.location_on; // success
  }

  Color _colorFor(LocationStatus s) {
    if (s == LocationStatus.permissionDeniedForever) return Colors.orange;
    if (s == LocationStatus.serviceDisabled ||
        s == LocationStatus.permissionDenied ||
        s == LocationStatus.error) return Colors.redAccent;
    return AppColors.primaryBlue; // success
  }

  @override
  Widget build(BuildContext context) {
    final isLocating = location == 'Locating...';
    final badgeColor = _colorFor(status);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: status == LocationStatus.success
                ? AppColors.divider
                : badgeColor.withAlpha(100),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLocating)
              SizedBox(
                width: 13,
                height: 13,
                child: CircularProgressIndicator(
                  strokeWidth: 1.8,
                  color: AppColors.primaryBlue,
                ),
              )
            else
              Icon(_iconFor(status), color: badgeColor, size: 14),
            const SizedBox(width: 5),
            Text(
              location,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
