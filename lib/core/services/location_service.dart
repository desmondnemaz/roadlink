import 'dart:async';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

/// Represents a resolved user location with coordinates and a human-readable
/// Zimbabwe area/city label.
class ResolvedLocation {
  final double latitude;
  final double longitude;
  final String areaLabel;

  const ResolvedLocation({
    required this.latitude,
    required this.longitude,
    required this.areaLabel,
  });
}

/// Known Zimbabwe locations used for fast, offline-friendly reverse lookup
/// and manual selection when GPS is unavailable.
class ZimbabwePlace {
  final String name;
  final double latitude;
  final double longitude;

  const ZimbabwePlace(this.name, this.latitude, this.longitude);
}

/// User-controlled geolocation service wrapping `geolocator`.
///
/// Follows `.agent/GEMINI.md` Section 7:
/// - Never performs continuous background location tracking.
/// - Requests location only when explicitly triggered by the user.
class LocationService {
  final Dio _dio;

  LocationService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 5),
                receiveTimeout: const Duration(seconds: 5),
              ),
            );

  /// Comprehensive list of Zimbabwe towns, cities, and major suburbs for
  /// accurate offline coordinate matching and manual selection.
  static const List<ZimbabwePlace> knownPlaces = [
    ZimbabwePlace('Rusape', -18.5328, 32.1284),
    ZimbabwePlace('Avondale, Harare', -17.7956, 31.0369),
    ZimbabwePlace('Borrowdale, Harare', -17.7497, 31.0894),
    ZimbabwePlace('Harare CBD', -17.8292, 31.0522),
    ZimbabwePlace('Mutare', -18.9707, 32.6709),
    ZimbabwePlace('Marondera', -18.1853, 31.5519),
    ZimbabwePlace('Nyanga', -18.2167, 32.7500),
    ZimbabwePlace('Headlands', -18.2833, 32.0500),
    ZimbabwePlace('Macheke', -18.1390, 31.8490),
    ZimbabwePlace('Chipinge', -20.1883, 32.6236),
    ZimbabwePlace('Chimanimani', -19.8000, 32.8667),
    ZimbabwePlace('Ruwa', -17.8897, 31.2447),
    ZimbabwePlace('Chitungwiza', -18.0127, 31.0756),
    ZimbabwePlace('Mount Pleasant, Harare', -17.7720, 31.0530),
    ZimbabwePlace('Belvedere, Harare', -17.8240, 31.0190),
    ZimbabwePlace('Eastlea, Harare', -17.8190, 31.0810),
    ZimbabwePlace('Highlands, Harare', -17.7950, 31.0890),
    ZimbabwePlace('Greendale, Harare', -17.8040, 31.1240),
    ZimbabwePlace('Msasa, Harare', -17.8350, 31.1130),
    ZimbabwePlace('Mabelreign, Harare', -17.7920, 30.9980),
    ZimbabwePlace('Marlborough, Harare', -17.7590, 30.9850),
    ZimbabwePlace('Westgate, Harare', -17.7680, 30.9540),
    ZimbabwePlace('Hatfield, Harare', -17.8680, 31.0820),
    ZimbabwePlace('Waterfalls, Harare', -17.8890, 31.0420),
    ZimbabwePlace('Norton', -17.8833, 30.7000),
    ZimbabwePlace('Chegutu', -18.1302, 30.1407),
    ZimbabwePlace('Kadoma', -18.3333, 29.9167),
    ZimbabwePlace('Chinhoyi', -17.3667, 30.2000),
    ZimbabwePlace('Karoi', -16.8099, 29.6925),
    ZimbabwePlace('Kariba', -16.5167, 28.8000),
    ZimbabwePlace('Bindura', -17.3019, 31.3306),
    ZimbabwePlace('Mazowe', -17.5040, 30.9739),
    ZimbabwePlace('Kwekwe', -18.9281, 29.8149),
    ZimbabwePlace('Gweru', -19.4500, 29.8167),
    ZimbabwePlace('Shurugwi', -19.6702, 30.0059),
    ZimbabwePlace('Zvishavane', -20.3267, 30.0665),
    ZimbabwePlace('Gokwe', -18.2048, 28.9349),
    ZimbabwePlace('Masvingo', -20.0744, 30.8328),
    ZimbabwePlace('Chiredzi', -21.0500, 31.6667),
    ZimbabwePlace('Bulawayo Central', -20.1500, 28.5833),
    ZimbabwePlace('Suburbs, Bulawayo', -20.1460, 28.6010),
    ZimbabwePlace('Hillside, Bulawayo', -20.1850, 28.6130),
    ZimbabwePlace('Gwanda', -20.9333, 29.0000),
    ZimbabwePlace('Beitbridge', -22.2167, 30.0000),
    ZimbabwePlace('Plumtree', -20.4833, 27.8167),
    ZimbabwePlace('Hwange', -18.3645, 26.4988),
    ZimbabwePlace('Victoria Falls', -17.9329, 25.8307),
  ];

  /// Requests a one-time foreground GPS reading via `geolocator` and resolves
  /// the exact Zimbabwe town, suburb, or city.
  ///
  /// Note: Does NOT fall back to ISP IP geolocation because Zimbabwe ISPs
  /// route traffic through Harare and would misidentify towns like Rusape as
  /// Harare.
  Future<ResolvedLocation> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const LocationServiceException(
          'Location services are turned off on your device. Please enable GPS/Location.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw const LocationServiceException(
            'Location permission was denied. Please allow location access when prompted.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw const LocationServiceException(
          'Location permission is blocked. Enable location access in your browser or device settings.',
        );
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 20),
          ),
        );
      } catch (_) {
        // Retry with low/network accuracy or last known device fix.
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
              timeLimit: Duration(seconds: 12),
            ),
          );
        } catch (_) {
          if (!kIsWeb) {
            position = await Geolocator.getLastKnownPosition();
          }
        }
      }

      if (position == null) {
        throw const LocationServiceException(
          'Could not get a GPS fix from your device/browser. Make sure OS Location Services are enabled, or select Rusape / your town below.',
        );
      }

      final label = await _resolveLabel(
        position.latitude,
        position.longitude,
      );
      return ResolvedLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        areaLabel: label,
      );
    } on LocationServiceException {
      rethrow;
    } on MissingPluginException {
      throw const LocationServiceException(
        'Geolocator plugin requires a full app restart (stop and run `flutter run` again).',
      );
    } on TimeoutException {
      throw const LocationServiceException(
        'GPS signal timed out. Please try again outdoors or select your town below.',
      );
    } catch (e) {
      throw LocationServiceException(
        'GPS unavailable (${e.runtimeType}). Enable device Location Services or pick your town below.',
      );
    }
  }

  /// Live reverse geocoding from `(latitude, longitude)` returning the most
  /// specific street, suburb, or town name first, falling back to offline
  /// Zimbabwe places only if network geocoders are unavailable.
  Future<String> reverseGeocode(double latitude, double longitude) =>
      _resolveLabel(latitude, longitude);

  Future<String> _resolveLabel(double latitude, double longitude) async {
    // 1. Query OpenStreetMap Nominatim reverse geocoding (street/suburb/town).
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: <String, dynamic>{
          'format': 'jsonv2',
          'lat': latitude,
          'lon': longitude,
          'zoom': 18,
          'addressdetails': 1,
        },
      );
      final data = response.data;
      final address = data?['address'];
      if (address is Map<String, dynamic>) {
        final formatted = _formatNominatimAddress(address);
        if (formatted != null && formatted.isNotEmpty) {
          return formatted;
        }
      }
      final displayName = (data?['display_name'] as String?)?.trim();
      if (displayName != null && displayName.isNotEmpty) {
        return displayName.split(',').take(2).map((s) => s.trim()).join(', ');
      }
    } catch (_) {
      // Fall through to BigDataCloud / offline lookup.
    }

    // 2. Query BigDataCloud client-side reverse geocoder (CORS-friendly on Web
    //    and mobile, no API key required).
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://api.bigdatacloud.net/data/reverse-geocode-client',
        queryParameters: <String, dynamic>{
          'latitude': latitude,
          'longitude': longitude,
          'localityLanguage': 'en',
        },
      );
      final data = response.data;
      if (data != null) {
        final locality = (data['locality'] as String?)?.trim();
        final city = (data['city'] as String?)?.trim();
        final principalSubdivision =
            (data['principalSubdivision'] as String?)?.trim();

        if (locality != null && locality.isNotEmpty) {
          if (city != null &&
              city.isNotEmpty &&
              city.toLowerCase() != locality.toLowerCase()) {
            return '$locality, $city';
          }
          return locality;
        }
        if (city != null && city.isNotEmpty) {
          return city;
        }
        if (principalSubdivision != null && principalSubdivision.isNotEmpty) {
          return principalSubdivision;
        }
      }
    } catch (_) {
      // Fall through to offline Zimbabwe place table.
    }

    return resolveAreaLabel(latitude, longitude);
  }

  /// Searches live Zimbabwe streets, suburbs, landmarks, and towns via
  /// OpenStreetMap Nominatim (like inDrive's live address autocomplete), falling
  /// back to [knownPlaces] when offline or for short queries.
  Future<List<ZimbabwePlace>> searchPlaces(String query) async {
    final trimmed = query.trim();
    final localMatches = knownPlaces
        .where(
          (p) =>
              trimmed.isEmpty ||
              p.name.toLowerCase().contains(trimmed.toLowerCase()),
        )
        .toList();

    if (trimmed.length < 2) {
      return localMatches;
    }

    try {
      final response = await _dio.get<List<dynamic>>(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: <String, dynamic>{
          'q': trimmed,
          'countrycodes': 'zw',
          'format': 'jsonv2',
          'addressdetails': 1,
          'limit': 8,
        },
      );
      final items = response.data;
      if (items == null) return localMatches;

      final liveResults = <ZimbabwePlace>[];
      final seen = <String>{};
      for (final raw in items) {
        if (raw is! Map<String, dynamic>) continue;
        final lat = double.tryParse('${raw['lat']}');
        final lon = double.tryParse('${raw['lon']}');
        if (lat == null || lon == null) continue;

        final address = raw['address'];
        String? label;
        if (address is Map<String, dynamic>) {
          label = _formatNominatimAddress(address);
        }
        label ??= (raw['display_name'] as String?)
            ?.split(',')
            .take(3)
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .join(', ');
        if (label == null || label.isEmpty) continue;

        if (seen.add(label.toLowerCase())) {
          liveResults.add(ZimbabwePlace(label, lat, lon));
        }
      }

      if (liveResults.isNotEmpty) {
        return liveResults;
      }
    } catch (_) {
      // Offline / rate-limited fallback to local matches.
    }

    return localMatches;
  }

  String? _formatNominatimAddress(Map<String, dynamic> address) {
    final road = (address['road'] ??
            address['amenity'] ??
            address['shop'] ??
            address['building']) as String?;
    final suburb = (address['suburb'] ??
            address['neighbourhood'] ??
            address['residential'] ??
            address['quarter']) as String?;
    final town = (address['town'] ??
            address['city'] ??
            address['village'] ??
            address['municipality'] ??
            address['state']) as String?;

    final parts = <String>[
      if (road != null && road.trim().isNotEmpty) road.trim(),
      if (suburb != null && suburb.trim().isNotEmpty) suburb.trim(),
      if (town != null && town.trim().isNotEmpty) town.trim(),
    ];

    final deduped = <String>[];
    for (final part in parts) {
      if (!deduped.any((e) => e.toLowerCase() == part.toLowerCase())) {
        deduped.add(part);
      }
    }
    if (deduped.isEmpty) return null;
    return deduped.take(3).join(', ');
  }

  static (ZimbabwePlace, double)? _findClosestPlace(
    double latitude,
    double longitude,
  ) {
    ZimbabwePlace? closest;
    var minDistanceKm = double.infinity;

    for (final place in knownPlaces) {
      final d = distanceInKm(
        latitude,
        longitude,
        place.latitude,
        place.longitude,
      );
      if (d < minDistanceKm) {
        minDistanceKm = d;
        closest = place;
      }
    }
    if (closest == null) return null;
    return (closest, minDistanceKm);
  }

  /// Resolves `(latitude, longitude)` to the closest known Zimbabwe town/area
  /// if within 35 km, or returns a clean coordinate summary if outside.
  static String resolveAreaLabel(
    double latitude,
    double longitude, {
    String? fallbackCity,
  }) {
    final closest = _findClosestPlace(latitude, longitude);
    if (closest != null && closest.$2 <= 35) {
      return closest.$1.name;
    }

    if (fallbackCity != null && fallbackCity.isNotEmpty) {
      return fallbackCity;
    }

    final latStr = latitude.toStringAsFixed(2);
    final lngStr = longitude.toStringAsFixed(2);
    return 'GPS ($latStr, $lngStr)';
  }

  /// Calculates the Haversine distance in kilometres between two coordinates.
  static double distanceInKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degToRad(double deg) => deg * (math.pi / 180.0);
}

class LocationServiceException implements Exception {
  final String message;

  const LocationServiceException(this.message);

  @override
  String toString() => message;
}
