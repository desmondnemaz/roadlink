import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:roadlink/app/router/app_router.dart';
import 'package:roadlink/app/theme/app_theme.dart';
import 'package:roadlink/features/home/data/nearby_providers.dart';
import 'package:roadlink/features/home/presentation/cubit/location_cubit.dart';
import 'package:roadlink/features/home/presentation/widgets/home_navigation.dart';
import 'package:roadlink/features/services/presentation/cubit/service_request_cubit.dart';
import 'package:roadlink/features/tracking/presentation/cubit/tracking_cubit.dart';

/// Opens a simple bottom sheet where the user picks a service and location
/// so nearby providers can bid on the request.
void showServiceRequestSheet(
  BuildContext context, {
  String? initialServiceType,
}) {
  const serviceTypes = ['Mechanics', 'Towing', 'Tyres', 'Diagnostics'];
  var selectedService = serviceTypes.contains(initialServiceType)
      ? initialServiceType!
      : serviceTypes.first;

  final locationController = TextEditingController(
    text: context.read<LocationCubit>().state.areaLabel,
  );
  final detailsController = TextEditingController();

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surfaceDefault,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setSheetState) {
          final c = context.colors;

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.s24,
                AppSpacing.s20,
                AppSpacing.s24,
                AppSpacing.s24 + MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Request a service',
                          style: AppTypography.h3.copyWith(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          icon: Icon(
                            Icons.close,
                            size: 20,
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Choose what you need and your location. Nearby service providers will send bids.',
                      style: AppTypography.bodySmall.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    Text(
                      'Service needed',
                      style: AppTypography.caption.copyWith(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Wrap(
                      spacing: AppSpacing.s8,
                      runSpacing: AppSpacing.s8,
                      children: [
                        for (final type in serviceTypes)
                          ChoiceChip(
                            label: Text(type),
                            selected: selectedService == type,
                            onSelected: (_) =>
                                setSheetState(() => selectedService = type),
                            selectedColor: AppPalette.navy900,
                            backgroundColor: c.surfaceRaised,
                            labelStyle: AppTypography.caption.copyWith(
                              color: selectedService == type
                                  ? AppPalette.neutral0
                                  : c.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    Text(
                      'Your location',
                      style: AppTypography.caption.copyWith(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: locationController,
                            style: AppTypography.bodySmall.copyWith(
                              color: c.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g. Avondale, Harare',
                              prefixIcon: Icon(
                                Icons.location_on_outlined,
                                size: 18,
                                color: c.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await showLocationPickerSheet(context);
                            if (!context.mounted) return;
                            locationController.text =
                                context.read<LocationCubit>().state.areaLabel;
                          },
                          icon: const Icon(Icons.search, size: 16),
                          label: const Text('Pick'),
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await triggerGpsDetection(context);
                            if (!context.mounted) return;
                            locationController.text =
                                context.read<LocationCubit>().state.areaLabel;
                          },
                          icon: const Icon(Icons.my_location_outlined, size: 16),
                          label: const Text('GPS'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    TextField(
                      controller: detailsController,
                      maxLines: 2,
                      style: AppTypography.bodySmall.copyWith(
                        color: c.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Optional note (e.g. Brake check · Toyota Vitz)',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s20),
                    ElevatedButton(
                      onPressed: () {
                        final created = context
                            .read<ServiceRequestCubit>()
                            .createRequest(
                              serviceType: selectedService,
                              locationLabel: locationController.text,
                              details: detailsController.text,
                            );
                        Navigator.of(sheetContext).pop();
                        showServiceBidsSheet(context, created.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPalette.buttonBlue,
                        foregroundColor: AppPalette.navy900,
                        elevation: 0,
                        minimumSize: const Size.fromHeight(48),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.mdAll,
                        ),
                      ),
                      child: Text(
                        'Request service & get bids',
                        style: AppTypography.button.copyWith(
                          color: AppPalette.navy900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

/// Lists all service requests created by the user and opens bids on tap.
void showMyRequestsSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surfaceDefault,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (sheetContext) {
      return BlocBuilder<ServiceRequestCubit, ServiceRequestState>(
        builder: (context, state) {
          final c = context.colors;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My service requests',
                          style: AppTypography.h3.copyWith(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          icon: Icon(
                            Icons.close,
                            size: 20,
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    if (state.requests.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.s24,
                        ),
                        child: Text(
                          'No service requests yet.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                      )
                    else
                      for (var i = 0; i < state.requests.length; i++) ...[
                        if (i > 0) const SizedBox(height: AppSpacing.s12),
                        InkWell(
                          onTap: () {
                            Navigator.of(sheetContext).pop();
                            showServiceBidsSheet(context, state.requests[i].id);
                          },
                          borderRadius: AppRadius.lgAll,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.s16),
                            decoration: BoxDecoration(
                              color: c.surfaceRaised,
                              borderRadius: AppRadius.lgAll,
                              border: Border.all(color: c.borderDefault),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.requests[i].details.isNotEmpty
                                            ? '${state.requests[i].serviceType} · ${state.requests[i].details}'
                                            : '${state.requests[i].serviceType} request',
                                        style: AppTypography.label.copyWith(
                                          color: c.textPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${state.requests[i].locationLabel} · ${state.requests[i].createdAtLabel}',
                                        style: AppTypography.caption.copyWith(
                                          color: c.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.s12),
                                Text(
                                  state.requests[i].acceptedBidId != null
                                      ? 'Accepted'
                                      : '${state.requests[i].bids.length} bids →',
                                  style: AppTypography.caption.copyWith(
                                    color: AppPalette.blue500,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    const SizedBox(height: AppSpacing.s16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        showServiceRequestSheet(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPalette.buttonBlue,
                        foregroundColor: AppPalette.navy900,
                        elevation: 0,
                        minimumSize: const Size.fromHeight(46),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.mdAll,
                        ),
                      ),
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: Text(
                        'New service request',
                        style: AppTypography.button.copyWith(
                          color: AppPalette.navy900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

/// Displays incoming service-provider bids for a [ServiceRequest] and lets
/// the user accept a bid.
void showServiceBidsSheet(BuildContext context, String requestId) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surfaceDefault,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (sheetContext) {
      return BlocBuilder<ServiceRequestCubit, ServiceRequestState>(
        builder: (context, state) {
          final c = context.colors;
          final request = state.requests.firstWhere(
            (r) => r.id == requestId,
            orElse: () => state.requests.first,
          );

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${request.serviceType} bids',
                                style: AppTypography.h3.copyWith(
                                  color: c.textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '${request.locationLabel} · ${request.createdAtLabel}',
                                style: AppTypography.caption.copyWith(
                                  color: c.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          icon: Icon(
                            Icons.close,
                            size: 20,
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (request.details.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        request.details,
                        style: AppTypography.bodySmall.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.s16),
                    for (var i = 0; i < request.bids.length; i++) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.s12),
                      _BidTile(
                        bid: request.bids[i],
                        isAccepted: request.acceptedBidId == request.bids[i].id,
                        anyAccepted: request.acceptedBidId != null,
                        onTrackLive: () {
                          Navigator.of(sheetContext).pop();
                          context.push(AppRoutes.mapPath);
                        },
                        onAccept: () {
                          final bid = request.bids[i];
                          final loc = context.read<LocationCubit>().state;
                          final matchedProvider = kNearbyProviders
                              .where((p) => p.name == bid.providerName)
                              .firstOrNull;
                          context.read<ServiceRequestCubit>().acceptBid(
                                request.id,
                                bid.id,
                              );
                          context.read<TrackingCubit>().startTracking(
                                requestId: request.id,
                                providerName: bid.providerName,
                                serviceType: request.serviceType,
                                destinationLabel: request.locationLabel,
                                userLat: loc.latitude,
                                userLng: loc.longitude,
                                providerLat: matchedProvider?.latitude ??
                                    (loc.latitude + 0.012),
                                providerLng: matchedProvider?.longitude ??
                                    (loc.longitude + 0.014),
                                initialEtaMinutes: bid.etaMinutes,
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Accepted US\$${bid.priceUsd} bid from ${bid.providerName}.',
                              ),
                              action: SnackBarAction(
                                label: 'Track live',
                                onPressed: () =>
                                    context.push(AppRoutes.mapPath),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

class _BidTile extends StatelessWidget {
  final ServiceBid bid;
  final bool isAccepted;
  final bool anyAccepted;
  final VoidCallback onAccept;
  final VoidCallback onTrackLive;

  const _BidTile({
    required this.bid,
    required this.isAccepted,
    required this.anyAccepted,
    required this.onAccept,
    required this.onTrackLive,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: isAccepted ? AppPalette.navy900 : c.surfaceRaised,
        borderRadius: AppRadius.lgAll,
        border: Border.all(
          color: isAccepted ? AppPalette.blue500 : c.borderDefault,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bid.providerName,
                      style: AppTypography.label.copyWith(
                        color: isAccepted ? AppPalette.neutral0 : c.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${bid.providerCategory} · ${bid.etaMinutes} mins away · ★ ${bid.rating.toStringAsFixed(1)}',
                      style: AppTypography.caption.copyWith(
                        color:
                            isAccepted ? AppPalette.neutral300 : c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'US\$${bid.priceUsd}',
                style: AppTypography.h3.copyWith(
                  color: AppPalette.blue500,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            bid.note,
            style: AppTypography.bodySmall.copyWith(
              color: isAccepted ? AppPalette.neutral200 : c.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Align(
            alignment: Alignment.centerRight,
            child: isAccepted
                ? ElevatedButton.icon(
                    onPressed: onTrackLive,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.buttonBlue,
                      foregroundColor: AppPalette.navy900,
                      elevation: 0,
                      minimumSize: const Size(124, 36),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.mdAll,
                      ),
                    ),
                    icon: const Icon(Icons.my_location_outlined, size: 15),
                    label: Text(
                      'Track live',
                      style: AppTypography.caption.copyWith(
                        color: AppPalette.navy900,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: anyAccepted ? null : onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.navy900,
                      foregroundColor: AppPalette.neutral0,
                      elevation: 0,
                      minimumSize: const Size(110, 36),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.mdAll,
                      ),
                    ),
                    child: Text(
                      'Accept bid',
                      style: AppTypography.caption.copyWith(
                        color: AppPalette.neutral0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

