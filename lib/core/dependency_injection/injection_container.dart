import 'package:get_it/get_it.dart';
import 'package:roadlink/core/network/api_client.dart';
import 'package:roadlink/core/services/location_service.dart';
import 'package:roadlink/core/services/realtime_tracker_service.dart';
import 'package:roadlink/features/community/presentation/cubit/community_cubit.dart';
import 'package:roadlink/features/home/presentation/cubit/location_cubit.dart';
import 'package:roadlink/features/services/presentation/cubit/service_request_cubit.dart';
import 'package:roadlink/features/settings/presentation/cubit/theme_cubit.dart';
import 'package:roadlink/features/tracking/presentation/cubit/tracking_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global service locator instance.
final GetIt sl = GetIt.instance;

/// Initialises core and feature-level dependencies.
Future<void> initDependencies() async {
  // External / Local Preferences
  if (!sl.isRegistered<SharedPreferences>()) {
    final sharedPreferences = await SharedPreferences.getInstance();
    sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  }

  // Core Network Client
  if (!sl.isRegistered<ApiClient>()) {
    sl.registerLazySingleton<ApiClient>(() => ApiClient());
  }

  // Core Geolocation Service
  if (!sl.isRegistered<LocationService>()) {
    sl.registerLazySingleton<LocationService>(() => LocationService());
  }

  // Standalone Realtime Tracker Service
  if (!sl.isRegistered<RealtimeTrackerService>()) {
    sl.registerLazySingleton<RealtimeTrackerService>(
      () => RealtimeTrackerService(),
    );
  }

  // Settings / Theme Cubit
  if (!sl.isRegistered<ThemeCubit>()) {
    sl.registerLazySingleton<ThemeCubit>(
      () => ThemeCubit(
        prefs: sl.isRegistered<SharedPreferences>()
            ? sl<SharedPreferences>()
            : null,
      ),
    );
  }

  // Location Cubit
  if (!sl.isRegistered<LocationCubit>()) {
    sl.registerLazySingleton<LocationCubit>(
      () => LocationCubit(
        locationService: sl<LocationService>(),
        prefs: sl.isRegistered<SharedPreferences>()
            ? sl<SharedPreferences>()
            : null,
      ),
    );
  }

  // Community Cubit
  if (!sl.isRegistered<CommunityCubit>()) {
    sl.registerLazySingleton<CommunityCubit>(() => CommunityCubit());
  }

  // Service Request Cubit
  if (!sl.isRegistered<ServiceRequestCubit>()) {
    sl.registerLazySingleton<ServiceRequestCubit>(() => ServiceRequestCubit());
  }

  // Standalone Tracking Cubit
  if (!sl.isRegistered<TrackingCubit>()) {
    sl.registerLazySingleton<TrackingCubit>(
      () => TrackingCubit(trackerService: sl<RealtimeTrackerService>()),
    );
  }
}
