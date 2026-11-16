import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roadlink/core/services/location_service.dart';
import 'package:roadlink/core/services/realtime_tracker_service.dart';

enum TrackingStatus { idle, enRoute, arriving, arrived }

class TrackingState extends Equatable {
  final String? requestId;
  final String providerName;
  final String serviceType;
  final String destinationLabel;
  final double userLat;
  final double userLng;
  final double providerLat;
  final double providerLng;
  final int etaMinutes;
  final double distanceKm;
  final TrackingStatus status;
  final bool isLiveGpsActive;

  const TrackingState({
    this.requestId,
    this.providerName = '',
    this.serviceType = '',
    this.destinationLabel = '',
    this.userLat = 0,
    this.userLng = 0,
    this.providerLat = 0,
    this.providerLng = 0,
    this.etaMinutes = 0,
    this.distanceKm = 0,
    this.status = TrackingStatus.idle,
    this.isLiveGpsActive = false,
  });

  bool get isActive => status != TrackingStatus.idle && requestId != null;

  TrackingState copyWith({
    String? requestId,
    String? providerName,
    String? serviceType,
    String? destinationLabel,
    double? userLat,
    double? userLng,
    double? providerLat,
    double? providerLng,
    int? etaMinutes,
    double? distanceKm,
    TrackingStatus? status,
    bool? isLiveGpsActive,
  }) {
    return TrackingState(
      requestId: requestId ?? this.requestId,
      providerName: providerName ?? this.providerName,
      serviceType: serviceType ?? this.serviceType,
      destinationLabel: destinationLabel ?? this.destinationLabel,
      userLat: userLat ?? this.userLat,
      userLng: userLng ?? this.userLng,
      providerLat: providerLat ?? this.providerLat,
      providerLng: providerLng ?? this.providerLng,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      distanceKm: distanceKm ?? this.distanceKm,
      status: status ?? this.status,
      isLiveGpsActive: isLiveGpsActive ?? this.isLiveGpsActive,
    );
  }

  @override
  List<Object?> get props => [
        requestId,
        providerName,
        serviceType,
        destinationLabel,
        userLat,
        userLng,
        providerLat,
        providerLng,
        etaMinutes,
        distanceKm,
        status,
        isLiveGpsActive,
      ];
}

/// Standalone cubit managing an active realtime service-tracking session.
///
/// Only runs while a user has an active accepted service bid or explicitly
/// starts live tracking, and stops cleanly when completed or cancelled.
class TrackingCubit extends Cubit<TrackingState> {
  final RealtimeTrackerService _trackerService;
  Timer? _providerStepTimer;

  TrackingCubit({RealtimeTrackerService? trackerService})
      : _trackerService = trackerService ?? RealtimeTrackerService(),
        super(const TrackingState());

  Future<void> startTracking({
    required String requestId,
    required String providerName,
    required String serviceType,
    required String destinationLabel,
    required double userLat,
    required double userLng,
    required double providerLat,
    required double providerLng,
    int initialEtaMinutes = 15,
  }) async {
    _providerStepTimer?.cancel();

    final initialDistance = LocationService.distanceInKm(
      userLat,
      userLng,
      providerLat,
      providerLng,
    );

    emit(
      TrackingState(
        requestId: requestId,
        providerName: providerName,
        serviceType: serviceType,
        destinationLabel: destinationLabel,
        userLat: userLat,
        userLng: userLng,
        providerLat: providerLat,
        providerLng: providerLng,
        etaMinutes: initialEtaMinutes,
        distanceKm: initialDistance,
        status: initialDistance <= 0.3
            ? TrackingStatus.arrived
            : (initialDistance <= 1.2
                ? TrackingStatus.arriving
                : TrackingStatus.enRoute),
        isLiveGpsActive: false,
      ),
    );

    await _trackerService.startUserPositionStream(
      onPosition: (fix) {
        if (isClosed || !state.isActive) return;
        final d = LocationService.distanceInKm(
          fix.latitude,
          fix.longitude,
          state.providerLat,
          state.providerLng,
        );
        emit(
          state.copyWith(
            userLat: fix.latitude,
            userLng: fix.longitude,
            distanceKm: d,
            isLiveGpsActive: true,
          ),
        );
      },
    );

    if (isClosed) return;
    if (_trackerService.isTrackingUserGps) {
      emit(state.copyWith(isLiveGpsActive: true));
    }

    // Simulates incoming provider telemetry updates until Spring WebSocket /
    // STOMP provider location frames are connected.
    _providerStepTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _stepProviderTowardUser(),
    );
  }

  void _stepProviderTowardUser() {
    if (!state.isActive || state.status == TrackingStatus.arrived) {
      _providerStepTimer?.cancel();
      return;
    }

    final nextLat =
        state.providerLat + (state.userLat - state.providerLat) * 0.22;
    final nextLng =
        state.providerLng + (state.userLng - state.providerLng) * 0.22;
    final nextDistance = LocationService.distanceInKm(
      state.userLat,
      state.userLng,
      nextLat,
      nextLng,
    );

    final nextEta = nextDistance <= 0.2
        ? 0
        : (state.etaMinutes > 1 ? state.etaMinutes - 1 : 1);
    final nextStatus = nextDistance <= 0.25
        ? TrackingStatus.arrived
        : (nextDistance <= 1.0
            ? TrackingStatus.arriving
            : TrackingStatus.enRoute);

    emit(
      state.copyWith(
        providerLat: nextLat,
        providerLng: nextLng,
        distanceKm: nextDistance,
        etaMinutes: nextEta,
        status: nextStatus,
      ),
    );

    if (nextStatus == TrackingStatus.arrived) {
      _providerStepTimer?.cancel();
    }
  }

  Future<void> stopTracking() async {
    _providerStepTimer?.cancel();
    _providerStepTimer = null;
    await _trackerService.stopUserPositionStream();
    emit(const TrackingState());
  }

  @override
  Future<void> close() async {
    _providerStepTimer?.cancel();
    await _trackerService.stopUserPositionStream();
    return super.close();
  }
}
