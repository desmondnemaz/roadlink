import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:roadlink/app/router/app_router.dart';
import 'package:roadlink/app/theme/app_theme.dart';
import 'package:roadlink/core/utils/responsive.dart';
import 'package:roadlink/features/home/data/nearby_providers.dart';
import 'package:roadlink/features/home/presentation/cubit/location_cubit.dart';
import 'package:roadlink/features/home/presentation/widgets/home_navigation.dart';
import 'package:roadlink/shared/widgets/section_layout.dart';

/// Full **All Services & Roadside Assistance** directory page.
///
/// Displays nearby mechanics, towing operators, tyre centres, and diagnostics
/// providers sorted by distance from the user's active [LocationState].
class ServicesPage extends StatefulWidget {
  final String? initialCategory;

  const ServicesPage({super.key, this.initialCategory});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  static const List<String> _categories = [
    'All',
    'Mechanics',
    'Towing',
    'Tyres',
  ];

  late String _selectedCategory;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final initial = widget.initialCategory;
    _selectedCategory =
        (initial != null && _categories.contains(initial)) ? initial : 'All';
  }

  bool _matchesCategory(NearbyServiceProvider provider) {
    if (_selectedCategory == 'All') return true;
    final cat = provider.category.toLowerCase();
    return switch (_selectedCategory) {
      'Mechanics' => cat.contains('mechanic') || cat.contains('diagnostic'),
      'Towing' => cat.contains('towing'),
      'Tyres' => cat.contains('tyre') || cat.contains('suspension'),
      _ => true,
    };
  }

  bool _matchesSearch(NearbyServiceProvider provider) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return true;
    return provider.name.toLowerCase().contains(q) ||
        provider.category.toLowerCase().contains(q) ||
        provider.area.toLowerCase().contains(q) ||
        provider.description.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDesktop = context.isDesktop;

    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, locationState) {
        final sorted = sortedProvidersNear(
          locationState.latitude,
          locationState.longitude,
        );
        final filtered = sorted
            .where((p) => _matchesCategory(p) && _matchesSearch(p))
            .toList();

        final mainColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search + GPS quick action row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: AppTypography.bodySmall.copyWith(
                      color: c.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search mechanics, towing, tyres, or town...',
                      prefixIcon: Icon(
                        Icons.search,
                        size: 18,
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                ElevatedButton.icon(
                  onPressed: locationState.isLoading
                      ? null
                      : () => triggerGpsDetection(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.orange500,
                    foregroundColor: AppPalette.navy900,
                    elevation: 0,
                    minimumSize: const Size(0, 48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s16,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.mdAll,
                    ),
                  ),
                  icon: locationState.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppPalette.navy900,
                          ),
                        )
                      : const Icon(Icons.my_location_outlined, size: 18),
                  label: Text(
                    isDesktop ? 'Detect GPS' : 'GPS',
                    style: AppTypography.button.copyWith(
                      color: AppPalette.navy900,
                    ),
                  ),
                ),
              ],
            ),
            if (!isDesktop) ...[
              const SizedBox(height: AppSpacing.s16),
              Wrap(
                spacing: AppSpacing.s8,
                runSpacing: AppSpacing.s8,
                children: [
                  for (final category in _categories)
                    ChoiceChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = category),
                      selectedColor: AppPalette.navy900,
                      backgroundColor: c.surfaceDefault,
                      labelStyle: AppTypography.caption.copyWith(
                        color: _selectedCategory == category
                            ? AppPalette.neutral0
                            : c.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: _selectedCategory == category
                            ? AppPalette.navy900
                            : c.borderDefault,
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.s20),
            Text(
              '${filtered.length} service${filtered.length == 1 ? '' : 's'} sorted nearest to ${locationState.shortAreaName}',
              style: AppTypography.caption.copyWith(
                color: c.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            if (filtered.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.s32),
                decoration: BoxDecoration(
                  color: c.surfaceDefault,
                  borderRadius: AppRadius.lgAll,
                  border: Border.all(color: c.borderDefault),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off_outlined,
                      size: 36,
                      color: c.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    Text(
                      'No matching services found',
                      style: AppTypography.label.copyWith(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    TextButton(
                      onPressed: () => setState(() {
                        _selectedCategory = 'All';
                        _searchQuery = '';
                      }),
                      child: const Text('Reset filters'),
                    ),
                  ],
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 880 ? 2 : 1;
                  if (columns == 1) {
                    return Column(
                      children: [
                        for (var i = 0; i < filtered.length; i++) ...[
                          if (i > 0) const SizedBox(height: AppSpacing.s12),
                          _ServiceDirectoryCard(
                            provider: filtered[i],
                            distanceKm: filtered[i].distanceFrom(
                              locationState.latitude,
                              locationState.longitude,
                            ),
                          ),
                        ],
                      ],
                    );
                  }

                  final rows = (filtered.length / 2).ceil();
                  return Column(
                    children: [
                      for (var r = 0; r < rows; r++) ...[
                        if (r > 0) const SizedBox(height: AppSpacing.s16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _ServiceDirectoryCard(
                                provider: filtered[r * 2],
                                distanceKm: filtered[r * 2].distanceFrom(
                                  locationState.latitude,
                                  locationState.longitude,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s16),
                            Expanded(
                              child: (r * 2 + 1) < filtered.length
                                  ? _ServiceDirectoryCard(
                                      provider: filtered[r * 2 + 1],
                                      distanceKm: filtered[r * 2 + 1]
                                          .distanceFrom(
                                            locationState.latitude,
                                            locationState.longitude,
                                          ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ],
                    ],
                  );
                },
              ),
          ],
        );

        return Scaffold(
          backgroundColor: c.backgroundCanvas,
          appBar: AppBar(
            backgroundColor: AppPalette.navy900,
            foregroundColor: AppPalette.neutral0,
            elevation: 0,
            title: Text(
              'All services',
              style: AppTypography.label.copyWith(
                color: AppPalette.neutral0,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.s16),
                child: Center(
                  child: InitialsAvatar(
                    initials: 'TM',
                    size: 36,
                    onTap: () => context.push(AppRoutes.settingsPath),
                  ),
                ),
              ),
            ],
          ),
          body: isDesktop
              ? ResponsiveCenter(
                  maxContentWidth: 1520,
                  padding: const EdgeInsets.only(
                    left: AppSpacing.s16,
                    right: AppSpacing.s24,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 220,
                        child: SingleChildScrollView(
                          primary: false,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.s24,
                          ),
                          child: _buildLeftExploreNav(context),
                        ),
                      ),
                      const VerticalSectionDivider(),
                      Expanded(
                        child: SingleChildScrollView(
                          primary: false,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.s24,
                          ),
                          child: mainColumn,
                        ),
                      ),
                      const VerticalSectionDivider(),
                      SizedBox(
                        width: 320,
                        child: SingleChildScrollView(
                          primary: false,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.s24,
                          ),
                          child: _buildRightRail(
                            context,
                            locationState,
                            sorted,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: ResponsiveCenter(
                    maxContentWidth: 960,
                    padding: const EdgeInsets.all(AppSpacing.s20),
                    child: mainColumn,
                  ),
                ),
        );
      },
    );
  }

  Widget _buildLeftExploreNav(BuildContext context) {
    const items = [
      ('All', Icons.apps_outlined),
      ('Mechanics', Icons.build_outlined),
      ('Towing', Icons.local_shipping_outlined),
      ('Tyres', Icons.tire_repair_outlined),
    ];

    return SectionRailCard(
      title: 'Explore',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.s8),
            SectionNavButton(
              label: items[i].$1,
              icon: items[i].$2,
              selected: _selectedCategory == items[i].$1,
              onTap: () => setState(() => _selectedCategory = items[i].$1),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRightRail(
    BuildContext context,
    LocationState locationState,
    List<NearbyServiceProvider> sorted,
  ) {
    final c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionRailCard(
          title: 'Your location',
          trailing: TextButton(
            onPressed: () => showLocationPickerSheet(context),
            child: const Text('Change'),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: AppPalette.orange500,
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: Text(
                      locationState.areaLabel,
                      style: AppTypography.bodySmall.copyWith(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s12),
              OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.mapPath),
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text('Open nearby map'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        SectionRailCard(
          title: 'Nearest providers',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < sorted.take(3).length; i++) ...[
                if (i > 0) const Divider(height: AppSpacing.s16),
                Text(
                  sorted[i].name,
                  style: AppTypography.bodySmall.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${sorted[i].category} · '
                  '${sorted[i].distanceFrom(locationState.latitude, locationState.longitude).toStringAsFixed(1)} km',
                  style: AppTypography.caption.copyWith(color: c.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ServiceDirectoryCard extends StatelessWidget {
  final NearbyServiceProvider provider;
  final double distanceKm;

  const _ServiceDirectoryCard({
    required this.provider,
    required this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: c.surfaceDefault,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: c.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppPalette.orange50,
                  borderRadius: AppRadius.mdAll,
                ),
                child: Icon(
                  provider.icon,
                  size: 20,
                  color: AppPalette.navy900,
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      style: AppTypography.label.copyWith(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${provider.category} · ${provider.area}',
                      style: AppTypography.caption.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: c.surfaceRaised,
                  borderRadius: AppRadius.smAll,
                ),
                child: Text(
                  '${distanceKm.toStringAsFixed(1)} km',
                  style: AppTypography.caption.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            provider.description,
            style: AppTypography.bodySmall.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s12),
          Row(
            children: [
              const Icon(
                Icons.star_border,
                size: 16,
                color: AppPalette.orange500,
              ),
              const SizedBox(width: 4),
              Text(
                provider.rating.toStringAsFixed(1),
                style: AppTypography.caption.copyWith(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${provider.reviews} reviews)',
                style: AppTypography.caption.copyWith(
                  color: c.textSecondary,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => context.push(AppRoutes.mapPath),
                icon: const Icon(Icons.map_outlined, size: 15),
                label: const Text('Map'),
              ),
              const SizedBox(width: AppSpacing.s8),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Service request draft opened for ${provider.name}.',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.navy900,
                  foregroundColor: AppPalette.neutral0,
                  elevation: 0,
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s12,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.mdAll,
                  ),
                ),
                child: Text(
                  'Request',
                  style: AppTypography.caption.copyWith(
                    color: AppPalette.neutral0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

