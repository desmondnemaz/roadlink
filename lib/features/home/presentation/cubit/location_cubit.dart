import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roadlink/core/services/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationState extends Equatable {
  final String areaLabel;
  final double latitude;
  final double longitude;
  final bool isLoading;
  final bool isGpsVerified;
  final String? errorMessage;

  const LocationState({
    this.areaLabel = 'Avondale, Harare',
    this.latitude = -17.7956,
    this.longitude = 31.0369,
    this.isLoading = false,
    this.isGpsVerified = false,
    this.errorMessage,
  });

  /// Short suburb/city prefix (e.g., `'Avondale'` from `'Avondale, Harare'`).
  String get shortAreaName => areaLabel.split(',').first.trim();

  /// Distance in km from the current location to Tawanda's Auto Care
  /// (`-17.7820, 31.0450` in Avondale, Harare).
  String get tawandaDistanceLabel {
    final km = LocationService.distanceInKm(
      latitude,
      longitude,
      -17.7820,
      31.0450,
    );
    return '${km.toStringAsFixed(1)} km away';
  }

  LocationState copyWith({
    String? areaLabel,
    double? latitude,
    double? longitude,
    bool? isLoading,
    bool? isGpsVerified,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LocationState(
      areaLabel: areaLabel ?? this.areaLabel,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isLoading: isLoading ?? this.isLoading,
      isGpsVerified: isGpsVerified ?? this.isGpsVerified,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        areaLabel,
        latitude,
        longitude,
        isLoading,
        isGpsVerified,
        errorMessage,
      ];
}

/// Manages user-controlled foreground GPS location and manual area selection.
class LocationCubit extends Cubit<LocationState> {
  static const String _areaKey = 'roadlink_location_area';
  static const String _latKey = 'roadlink_location_lat';
  static const String _lngKey = 'roadlink_location_lng';

  final LocationService _locationService;
  final SharedPreferences? _prefs;

  LocationCubit({
    LocationService? locationService,
    SharedPreferences? prefs,
  })  : _locationService = locationService ?? LocationService(),
        _prefs = prefs,
        super(_loadInitial(prefs));

  static LocationState _loadInitial(SharedPreferences? prefs) {
    final savedArea = prefs?.getString(_areaKey);
    final savedLat = prefs?.getDouble(_latKey);
    final savedLng = prefs?.getDouble(_lngKey);
    if (savedArea != null && savedLat != null && savedLng != null) {
      return LocationState(
        areaLabel: savedArea,
        latitude: savedLat,
        longitude: savedLng,
      );
    }
    return const LocationState();
  }

  /// Triggered explicitly by the user to read current GPS coordinates via
  /// `geolocator`.
  Future<bool> detectGpsLocation() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final resolved = await _locationService.getCurrentLocation();
      await _persist(resolved.areaLabel, resolved.latitude, resolved.longitude);
      emit(
        state.copyWith(
          areaLabel: resolved.areaLabel,
          latitude: resolved.latitude,
          longitude: resolved.longitude,
          isLoading: false,
          isGpsVerified: true,
          clearError: true,
        ),
      );
      return true;
    } on LocationServiceException catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.message,
        ),
      );
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Unable to determine GPS location right now.',
        ),
      );
      return false;
    }
  }

  /// Allows the user to manually choose a Zimbabwe suburb or city.
  Future<void> selectPlace(ZimbabwePlace place) async {
    await _persist(place.name, place.latitude, place.longitude);
    emit(
      state.copyWith(
        areaLabel: place.name,
        latitude: place.latitude,
        longitude: place.longitude,
        isLoading: false,
        isGpsVerified: false,
        clearError: true,
      ),
    );
  }

  Future<void> _persist(String area, double lat, double lng) async {
    await _prefs?.setString(_areaKey, area);
    await _prefs?.setDouble(_latKey, lat);
    await _prefs?.setDouble(_lngKey, lng);
  }
}

