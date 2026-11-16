import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Live coordinate fix emitted by [RealtimeTrackerService].
class TrackedCoordinate {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  const TrackedCoordinate({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });
}

/// Standalone realtime geolocation & tracking service.
///
/// Kept separate from one-time [LocationService] lookups so continuous GPS
/// streaming only runs during an active, user-initiated tracking session
/// (per `.agent/GEMINI.md` Section 7) and stops immediately when disposed.
class RealtimeTrackerService {
  StreamSubscription<Position>? _gpsSubscription;

  bool get isTrackingUserGps => _gpsSubscription != null;

  /// Starts foreground-only GPS tracking while an active service session is
  /// running. Silently skips if permission is not granted so tracking falls
  /// back to the user's selected coordinates without crashing.
  Future<void> startUserPositionStream({
    required void Function(TrackedCoordinate fix) onPosition,
    int distanceFilterMeters = 15,
  }) async {
    await stopUserPositionStream();

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final settings = LocationSettings(
        accuracy: kIsWeb ? LocationAccuracy.medium : LocationAccuracy.high,
        distanceFilter: distanceFilterMeters,
      );

      _gpsSubscription =
          Geolocator.getPositionStream(locationSettings: settings).listen(
        (pos) {
          onPosition(
            TrackedCoordinate(
              latitude: pos.latitude,
              longitude: pos.longitude,
              timestamp: DateTime.now(),
            ),
          );
        },
        onError: (_) {
          // Keep session alive using last known/selected coordinates.
        },
      );
    } catch (_) {
      // Safe fallback when running in headless tests or unsupported environments.
    }
  }

  /// Stops foreground GPS tracking immediately.
  Future<void> stopUserPositionStream() async {
    await _gpsSubscription?.cancel();
    _gpsSubscription = null;
  }
}
