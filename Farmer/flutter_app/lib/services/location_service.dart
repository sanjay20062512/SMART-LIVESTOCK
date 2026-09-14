import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Result container for device GPS coordinates with fallback metadata.
class LocationResult {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final bool isGpsAcquired;
  final String source;
  final String? fallbackReason;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.isGpsAcquired,
    required this.source,
    this.fallbackReason,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'isGpsAcquired': isGpsAcquired,
        'source': source,
        'fallbackReason': fallbackReason,
      };

  @override
  String toString() =>
      'LocationResult(lat: $latitude, lon: $longitude, isGps: $isGpsAcquired, source: $source)';
}

/// Robust cross-platform Location Service managing device GPS acquisition,
/// runtime permissions, and graceful fallback to farm profile coordinates.
class LocationService {
  static final LocationService instance = LocationService._internal();
  LocationService._internal();

  // Standard Default: Green Meadows Farm, Uruli Kanchan, Haveli, Pune
  static const double defaultFarmLat = 18.4870;
  static const double defaultFarmLon = 74.1330;

  LocationResult? _lastAcquiredLocation;
  LocationResult? get lastAcquiredLocation => _lastAcquiredLocation;

  /// Acquires real device GPS coordinates.
  /// If location services are disabled, permission is denied, or GPS times out,
  /// gracefully returns fallback coordinates without throwing errors.
  Future<LocationResult> getCurrentLocation({
    double defaultLat = defaultFarmLat,
    double defaultLon = defaultFarmLon,
  }) async {
    try {
      // 1. Check if location services are enabled on device
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        final fallback = LocationResult(
          latitude: defaultLat,
          longitude: defaultLon,
          isGpsAcquired: false,
          source: 'Farm Location (GPS Disabled)',
          fallbackReason: 'Location services are disabled on device.',
        );
        _lastAcquiredLocation = fallback;
        return fallback;
      }

      // 2. Check and request location permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          final fallback = LocationResult(
            latitude: defaultLat,
            longitude: defaultLon,
            isGpsAcquired: false,
            source: 'Farm Location (Permission Denied)',
            fallbackReason: 'Location permission was denied.',
          );
          _lastAcquiredLocation = fallback;
          return fallback;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        final fallback = LocationResult(
          latitude: defaultLat,
          longitude: defaultLon,
          isGpsAcquired: false,
          source: 'Farm Location (Permission Blocked)',
          fallbackReason: 'Location permissions are permanently denied.',
        );
        _lastAcquiredLocation = fallback;
        return fallback;
      }

      // 3. Capture high-accuracy GPS position with a 6-second timeout limit
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 6),
          ),
        );

        final result = LocationResult(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          isGpsAcquired: true,
          source: 'Device GPS',
        );
        _lastAcquiredLocation = result;
        return result;
      } catch (gpsTimeout) {
        // Try last known position if active GPS query times out
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          final result = LocationResult(
            latitude: lastKnown.latitude,
            longitude: lastKnown.longitude,
            accuracy: lastKnown.accuracy,
            isGpsAcquired: true,
            source: 'Device GPS (Cached)',
          );
          _lastAcquiredLocation = result;
          return result;
        }

        final fallback = LocationResult(
          latitude: defaultLat,
          longitude: defaultLon,
          isGpsAcquired: false,
          source: 'Farm Location (GPS Timeout)',
          fallbackReason: 'GPS signal acquisition timed out.',
        );
        _lastAcquiredLocation = fallback;
        return fallback;
      }
    } catch (e) {
      debugPrint('LocationService unexpected error: $e');
      final fallback = LocationResult(
        latitude: defaultLat,
        longitude: defaultLon,
        isGpsAcquired: false,
        source: 'Farm Location',
        fallbackReason: e.toString(),
      );
      _lastAcquiredLocation = fallback;
      return fallback;
    }
  }

  /// Calculates great-circle distance between two geographic coordinates in kilometers.
  static double haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusKm = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return double.parse((earthRadiusKm * c).toStringAsFixed(2));
  }

  static double _toRadians(double degree) => degree * (math.pi / 180.0);
}
