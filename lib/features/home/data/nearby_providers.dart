import 'package:flutter/material.dart';
import 'package:roadlink/core/services/location_service.dart';

/// Represents an automotive service provider displayed in the **Near you**
/// scrollable strip and on the **Nearby map**.
class NearbyServiceProvider {
  final String name;
  final String category;
  final String area;
  final String description;
  final double rating;
  final int reviews;
  final double latitude;
  final double longitude;
  final IconData icon;

  const NearbyServiceProvider({
    required this.name,
    required this.category,
    required this.area,
    required this.description,
    required this.rating,
    required this.reviews,
    required this.latitude,
    required this.longitude,
    required this.icon,
  });

  double distanceFrom(double userLat, double userLng) {
    return LocationService.distanceInKm(userLat, userLng, latitude, longitude);
  }
}

/// Sample automotive service providers across Zimbabwe, sorted dynamically by
/// proximity to the user's active location.
const List<NearbyServiceProvider> kNearbyProviders = [
  NearbyServiceProvider(
    name: 'Tawanda’s Auto Care',
    category: 'Mobile mechanic',
    area: 'Avondale, Harare',
    description: 'Servicing, diagnostics and brake repairs.',
    rating: 4.8,
    reviews: 24,
    latitude: -17.7820,
    longitude: 31.0450,
    icon: Icons.build_outlined,
  ),
  NearbyServiceProvider(
    name: 'Rusape Motor Clinic',
    category: 'Mechanic & diagnostics',
    area: 'Rusape',
    description: 'Engine tune-ups, suspension and electrical repairs.',
    rating: 4.8,
    reviews: 15,
    latitude: -18.5328,
    longitude: 32.1284,
    icon: Icons.build_outlined,
  ),
  NearbyServiceProvider(
    name: 'Vengere Tyre & Alignment',
    category: 'Tyres & wheel balance',
    area: 'Vengere, Rusape',
    description: 'Puncture repairs, new tyres and 3D wheel alignment.',
    rating: 4.7,
    reviews: 18,
    latitude: -18.5450,
    longitude: 32.1180,
    icon: Icons.album_outlined,
  ),
  NearbyServiceProvider(
    name: 'Makoni Breakdown Towing',
    category: '24/7 Towing',
    area: 'Rusape–Mutare Hwy',
    description: 'Fast flatbed recovery along the A3 highway.',
    rating: 4.9,
    reviews: 11,
    latitude: -18.5210,
    longitude: 32.1450,
    icon: Icons.local_shipping_outlined,
  ),
  NearbyServiceProvider(
    name: 'Harare Roadside & Towing',
    category: '24/7 Towing',
    area: 'Harare CBD',
    description: 'Emergency roadside recovery and battery jump-starts.',
    rating: 4.7,
    reviews: 19,
    latitude: -17.8292,
    longitude: 31.0522,
    icon: Icons.local_shipping_outlined,
  ),
  NearbyServiceProvider(
    name: 'Msasa Tyre & Alignment',
    category: 'Tyres & suspension',
    area: 'Msasa, Harare',
    description: 'Tyre fitting, shocks, bushes and wheel balancing.',
    rating: 4.9,
    reviews: 31,
    latitude: -17.8350,
    longitude: 31.1130,
    icon: Icons.album_outlined,
  ),
  NearbyServiceProvider(
    name: 'Mutare Roadside Rescue',
    category: 'Towing & battery',
    area: 'Mutare',
    description: 'Roadside assistance, towing and alternator repairs.',
    rating: 4.6,
    reviews: 12,
    latitude: -18.9707,
    longitude: 32.6709,
    icon: Icons.local_shipping_outlined,
  ),
];

/// Returns [kNearbyProviders] sorted by distance from `(latitude, longitude)`.
List<NearbyServiceProvider> sortedProvidersNear(
  double latitude,
  double longitude,
) {
  final sorted = List<NearbyServiceProvider>.from(kNearbyProviders);
  sorted.sort(
    (a, b) => a
        .distanceFrom(latitude, longitude)
        .compareTo(b.distanceFrom(latitude, longitude)),
  );
  return sorted;
}

