import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:roadlink/app/theme/app_theme.dart';
import 'package:roadlink/features/home/data/nearby_providers.dart';
import 'package:roadlink/features/home/presentation/cubit/location_cubit.dart';
import 'package:roadlink/features/home/presentation/widgets/home_navigation.dart';

/// Interactive OpenStreetMap-powered nearby services map wired to [LocationCubit].
///
/// Uses free OpenStreetMap tiles (no paid API key required) and only requests
/// foreground GPS when explicitly triggered by the user.
class NearbyMapPage extends StatefulWidget {
  const NearbyMapPage({super.key});

  @override
  State<NearbyMapPage> createState() => _NearbyMapPageState();
}

class _NearbyMapPageState extends State<NearbyMapPage> {
  final MapController _mapController = MapController();
  double _currentZoom = 13.0;
  NearbyServiceProvider? _selectedProvider;

  NearbyServiceProvider _closestProvider(LocationState location) {
    return sortedProvidersNear(location.latitude, location.longitude).first;
  }

  void _moveCamera(double lat, double lng, {double? zoom}) {
    final targetZoom = zoom ?? _currentZoom;
    _currentZoom = targetZoom;
    _mapController.move(LatLng(lat, lng), targetZoom);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return BlocConsumer<LocationCubit, LocationState>(
      listenWhen: (prev, curr) =>
          prev.latitude != curr.latitude || prev.longitude != curr.longitude,
      listener: (context, state) {
        _moveCamera(state.latitude, state.longitude, zoom: 13.0);
        setState(() => _selectedProvider = _closestProvider(state));
      },
      builder: (context, locationState) {
        final activeProvider =
            _selectedProvider ?? _closestProvider(locationState);
        final distanceKm = activeProvider.distanceFrom(
          locationState.latitude,
          locationState.longitude,
        );

        return Scaffold(
          backgroundColor: AppPalette.navy900,
          appBar: AppBar(
            backgroundColor: AppPalette.navy900,
            foregroundColor: AppPalette.neutral0,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nearby map',
                  style: AppTypography.label.copyWith(
                    color: AppPalette.neutral0,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  locationState.areaLabel,
                  style: AppTypography.caption.copyWith(
                    color: AppPalette.neutral300,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                onPressed: () => showLocationPickerSheet(context),
                icon: const Icon(
                  Icons.edit_location_alt_outlined,
                  size: 16,
                  color: AppPalette.orange500,
                ),
                label: Text(
                  'Change',
                  style: AppTypography.caption.copyWith(
                    color: AppPalette.orange500,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(
                    locationState.latitude,
                    locationState.longitude,
                  ),
                  initialZoom: _currentZoom,
                  minZoom: 5,
                  maxZoom: 18,
                  onPositionChanged: (camera, _) {
                    _currentZoom = camera.zoom;
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.roadlink.app',
                  ),
                  MarkerLayer(
                    markers: [
                      // User's active GPS / selected location marker
                      Marker(
                        point: LatLng(
                          locationState.latitude,
                          locationState.longitude,
                        ),
                        width: 44,
                        height: 44,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppPalette.orange500.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppPalette.orange500,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppPalette.neutral0,
                                width: 2.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Nearby automotive provider pins
                      for (final provider in kNearbyProviders)
                        Marker(
                          point: LatLng(provider.latitude, provider.longitude),
                          width: 44,
                          height: 44,
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedProvider = provider);
                              _moveCamera(
                                provider.latitude,
                                provider.longitude,
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: activeProvider.name == provider.name
                                    ? AppPalette.orange500
                                    : AppPalette.navy900,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppPalette.neutral0,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                provider.icon,
                                size: 18,
                                color: activeProvider.name == provider.name
                                    ? AppPalette.navy900
                                    : AppPalette.neutral0,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // Right-side map controls: GPS + Zoom
              Positioned(
                right: AppSpacing.s16,
                top: AppSpacing.s16,
                child: Column(
                  children: [
                    _MapControlButton(
                      icon: Icons.my_location_outlined,
                      tooltip: 'Use current GPS location',
                      isLoading: locationState.isLoading,
                      onTap: () => triggerGpsDetection(context),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    _MapControlButton(
                      icon: Icons.add,
                      tooltip: 'Zoom in',
                      onTap: () => _moveCamera(
                        _mapController.camera.center.latitude,
                        _mapController.camera.center.longitude,
                        zoom: (_currentZoom + 1).clamp(5.0, 18.0),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    _MapControlButton(
                      icon: Icons.remove,
                      tooltip: 'Zoom out',
                      onTap: () => _moveCamera(
                        _mapController.camera.center.latitude,
                        _mapController.camera.center.longitude,
                        zoom: (_currentZoom - 1).clamp(5.0, 18.0),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom selected provider summary card
              Positioned(
                left: AppSpacing.s16,
                right: AppSpacing.s16,
                bottom: AppSpacing.s16,
                child: SafeArea(
                  top: false,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.s16),
                        decoration: BoxDecoration(
                          color: c.surfaceDefault,
                          borderRadius: AppRadius.lgAll,
                          border: Border.all(color: c.borderDefault),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: AppPalette.orange50,
                                borderRadius: AppRadius.mdAll,
                              ),
                              child: Icon(
                                activeProvider.icon,
                                size: 20,
                                color: AppPalette.navy900,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    activeProvider.name,
                                    style: AppTypography.label.copyWith(
                                      color: c.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${activeProvider.category} · ${activeProvider.area}',
                                    style: AppTypography.caption.copyWith(
                                      color: c.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star_border,
                                        size: 14,
                                        color: AppPalette.orange500,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${activeProvider.rating} (${activeProvider.reviews})',
                                        style: AppTypography.caption.copyWith(
                                          color: c.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.s12),
                                      Text(
                                        '${distanceKm.toStringAsFixed(1)} km away',
                                        style: AppTypography.caption.copyWith(
                                          color: c.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isLoading;

  const _MapControlButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Material(
      color: c.surfaceDefault,
      elevation: 2,
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: AppRadius.mdAll,
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(icon, size: 20, color: c.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

