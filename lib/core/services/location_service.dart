import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

enum LocationStatus {
  success,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  error,
}

class LocationResult {
  final String city;
  final LocationStatus status;
  const LocationResult({required this.city, required this.status});
}

class LocationService {
  LocationService._();

  static Future<LocationResult> getLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult(city: 'Location Off', status: LocationStatus.serviceDisabled);
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        return const LocationResult(city: 'Allow Location', status: LocationStatus.permissionDenied);
      }
      if (permission == LocationPermission.deniedForever) {
        return const LocationResult(city: 'Open Settings', status: LocationStatus.permissionDeniedForever);
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      ).timeout(const Duration(seconds: 10));

      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final city = (place.locality?.isNotEmpty == true) ? place.locality! : (place.administrativeArea ?? 'Unknown');
        return LocationResult(city: city, status: LocationStatus.success);
      }
      return const LocationResult(city: 'Unknown', status: LocationStatus.success);
    } catch (_) {
      return const LocationResult(city: 'Retry', status: LocationStatus.error);
    }
  }

  static Future<void> openAppSettings() => Geolocator.openAppSettings();
  static Future<void> openLocationSettings() => Geolocator.openLocationSettings();
}
