import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final double accuracy;
  final bool isFallback;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.isFallback,
  });
}

class LocationService {
  // Default Demo Fallback (Chennai Central)
  static const double fallbackLat = 13.0827;
  static const double fallbackLng = 80.2707;
  static const double fallbackAccuracy = 12.0;

  static Future<LocationResult> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult(
          latitude: fallbackLat,
          longitude: fallbackLng,
          accuracy: fallbackAccuracy,
          isFallback: true,
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult(
            latitude: fallbackLat,
            longitude: fallbackLng,
            accuracy: fallbackAccuracy,
            isFallback: true,
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult(
          latitude: fallbackLat,
          longitude: fallbackLng,
          accuracy: fallbackAccuracy,
          isFallback: true,
        );
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 6),
      );

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        isFallback: false,
      );
    } catch (e) {
      // Fallback on any error, timeout, or lack of GPS hardware
      return LocationResult(
        latitude: fallbackLat,
        longitude: fallbackLng,
        accuracy: fallbackAccuracy,
        isFallback: true,
      );
    }
  }
}
