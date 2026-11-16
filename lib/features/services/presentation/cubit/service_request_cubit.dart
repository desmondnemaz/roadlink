import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roadlink/features/home/data/nearby_providers.dart';

/// A bid submitted by a service provider in response to a [ServiceRequest].
class ServiceBid {
  final String id;
  final String providerName;
  final String providerCategory;
  final double rating;
  final int priceUsd;
  final int etaMinutes;
  final String note;

  const ServiceBid({
    required this.id,
    required this.providerName,
    required this.providerCategory,
    required this.rating,
    required this.priceUsd,
    required this.etaMinutes,
    required this.note,
  });
}

/// A user's request for an automotive service at a specific location.
class ServiceRequest {
  final String id;
  final String serviceType;
  final String locationLabel;
  final String details;
  final String createdAtLabel;
  final List<ServiceBid> bids;
  final String? acceptedBidId;

  const ServiceRequest({
    required this.id,
    required this.serviceType,
    required this.locationLabel,
    required this.details,
    required this.createdAtLabel,
    required this.bids,
    this.acceptedBidId,
  });

  int? get lowestBidUsd {
    if (bids.isEmpty) return null;
    return bids.map((b) => b.priceUsd).reduce((a, b) => a < b ? a : b);
  }

  ServiceRequest copyWith({
    List<ServiceBid>? bids,
    String? acceptedBidId,
  }) {
    return ServiceRequest(
      id: id,
      serviceType: serviceType,
      locationLabel: locationLabel,
      details: details,
      createdAtLabel: createdAtLabel,
      bids: bids ?? this.bids,
      acceptedBidId: acceptedBidId ?? this.acceptedBidId,
    );
  }
}

class ServiceRequestState {
  final List<ServiceRequest> requests;

  const ServiceRequestState({required this.requests});

  ServiceRequest? get latestRequest =>
      requests.isEmpty ? null : requests.first;
}

/// Manages user service requests and incoming service-provider bids.
class ServiceRequestCubit extends Cubit<ServiceRequestState> {
  ServiceRequestCubit()
      : super(
          ServiceRequestState(
            requests: [
              ServiceRequest(
                id: 'req-seed-1',
                serviceType: 'Mechanics',
                locationLabel: 'Avondale, Harare',
                details: 'Brake inspection · Toyota Vitz',
                createdAtLabel: 'Requested today',
                bids: const [
                  ServiceBid(
                    id: 'bid-1',
                    providerName: 'Tawanda’s Auto Care',
                    providerCategory: 'Mobile mechanic',
                    rating: 4.8,
                    priceUsd: 25,
                    etaMinutes: 20,
                    note: 'Includes front & rear pad check and fluid test.',
                  ),
                  ServiceBid(
                    id: 'bid-2',
                    providerName: 'Borrowdale Motors & Garage',
                    providerCategory: 'Full service garage',
                    rating: 4.9,
                    priceUsd: 35,
                    etaMinutes: 30,
                    note: 'Full diagnostic scan + brake line pressure check.',
                  ),
                  ServiceBid(
                    id: 'bid-3',
                    providerName: 'Mbare Fleet & Diagnostics',
                    providerCategory: 'Auto electrician',
                    rating: 4.6,
                    priceUsd: 22,
                    etaMinutes: 35,
                    note: 'Mobile call-out with brake caliper inspection.',
                  ),
                ],
              ),
            ],
          ),
        );

  /// Creates a new service request for [serviceType] at [locationLabel] and
  /// collects initial bids from matching nearby service providers.
  ServiceRequest createRequest({
    required String serviceType,
    required String locationLabel,
    String details = '',
  }) {
    final id = 'req-${DateTime.now().millisecondsSinceEpoch}';
    final bids = _generateProviderBids(serviceType, id);
    final request = ServiceRequest(
      id: id,
      serviceType: serviceType,
      locationLabel: locationLabel.trim().isEmpty
          ? 'Avondale, Harare'
          : locationLabel.trim(),
      details: details.trim(),
      createdAtLabel: 'Just now',
      bids: bids,
    );
    emit(ServiceRequestState(requests: [request, ...state.requests]));
    return request;
  }

  void acceptBid(String requestId, String bidId) {
    final updated = state.requests.map((r) {
      if (r.id != requestId) return r;
      return r.copyWith(acceptedBidId: bidId);
    }).toList();
    emit(ServiceRequestState(requests: updated));
  }

  List<ServiceBid> _generateProviderBids(String serviceType, String reqId) {
    final basePrice = switch (serviceType) {
      'Towing' => 45,
      'Tyres' => 18,
      'Diagnostics' => 20,
      _ => 25,
    };

    final matching = kNearbyProviders.where((p) {
      final cat = p.category.toLowerCase();
      return switch (serviceType) {
        'Towing' => cat.contains('towing') || cat.contains('roadside'),
        'Tyres' => cat.contains('tyre') || cat.contains('suspension'),
        'Diagnostics' =>
          cat.contains('diagnostic') || cat.contains('electrician'),
        _ => cat.contains('mechanic') || cat.contains('garage'),
      };
    }).toList();

    final providers = matching.isNotEmpty
        ? matching.take(3).toList()
        : kNearbyProviders.take(3).toList();

    return [
      for (var i = 0; i < providers.length; i++)
        ServiceBid(
          id: '$reqId-bid-$i',
          providerName: providers[i].name,
          providerCategory: providers[i].category,
          rating: providers[i].rating,
          priceUsd: basePrice + (i * 6),
          etaMinutes: 15 + (i * 10),
          note: providers[i].description,
        ),
    ];
  }
}

