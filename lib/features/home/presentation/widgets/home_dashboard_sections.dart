import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:roadlink/app/router/app_router.dart';
import 'package:roadlink/app/theme/app_theme.dart';
import 'package:roadlink/core/utils/responsive.dart';
import 'package:roadlink/features/community/data/community_catalog.dart';
import 'package:roadlink/features/community/presentation/pages/community_page.dart';
import 'package:roadlink/features/home/presentation/cubit/location_cubit.dart';
import 'package:roadlink/features/home/presentation/widgets/home_navigation.dart';
import 'package:roadlink/features/marketplace/data/marketplace_catalog.dart';
import 'package:roadlink/features/services/presentation/cubit/service_request_cubit.dart';
import 'package:roadlink/features/services/presentation/widgets/service_request_sheet.dart';

/// Desktop Greeting Row (`Morning, Tendai.`, subtitle, and `Find nearby help`
/// orange button with trailing GPS icon) matching `media_1794316982499_d7fffc3f.png`.
class HomeDesktopGreetingRow extends StatelessWidget {
  const HomeDesktopGreetingRow({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Morning, Tendai.',
                style: AppTypography.displayOf(context).copyWith(
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'A little help, a new find, a good conversation. Make it your day.',
                style: AppTypography.bodyOf(context).copyWith(
                  color: c.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.s16),
        BlocBuilder<LocationCubit, LocationState>(
          builder: (context, locationState) {
            return ElevatedButton(
              onPressed: locationState.isLoading
                  ? null
                  : () => triggerGpsDetection(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.buttonBlue,
                foregroundColor: AppPalette.navy900,
                elevation: 0,
                minimumSize: const Size(168, 44),
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.mdAll,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    locationState.isLoading
                        ? 'Locating...'
                        : 'Find nearby help',
                    style: AppTypography.button.copyWith(
                      color: AppPalette.navy900,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  if (locationState.isLoading)
                    const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppPalette.navy900,
                      ),
                    )
                  else
                    const Icon(
                      Icons.my_location_outlined,
                      size: 16,
                      color: AppPalette.navy900,
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Top dashboard section exposing Roadlink's primary **Service Finding**
/// objective alongside quick **What does your car need?** category shortcuts.
class HomeServicesAndNearYouSection extends StatelessWidget {
  const HomeServicesAndNearYouSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HomeEmergencyRoadsideBanner(),
        const SizedBox(height: AppSpacing.s16),
        _ServiceFinderHeroCard(isDesktop: isDesktop),
        const SizedBox(height: AppSpacing.s16),
        const _ActiveServiceRequestCard(),
        SizedBox(height: isDesktop ? AppSpacing.s24 : AppSpacing.s20),
        _ServicesNeedSection(isDesktop: isDesktop),
      ],
    );
  }
}

/// Amber/Orange accent banner for Emergency Roadside Alerts on the Home Dashboard.
class HomeEmergencyRoadsideBanner extends StatelessWidget {
  const HomeEmergencyRoadsideBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      decoration: BoxDecoration(
        color: AppPalette.orange50,
        borderRadius: AppRadius.mdAll,
        border: Border.all(
          color: AppPalette.orange500.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppPalette.orange500.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppPalette.orange600,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Emergency Roadside Help',
                  style: AppTypography.label.copyWith(
                    color: AppPalette.navy900,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '24/7 towing & breakdown assistance',
                  style: AppTypography.caption.copyWith(
                    color: AppPalette.neutral500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          ElevatedButton.icon(
            onPressed: () => showServiceRequestSheet(
              context,
              initialServiceType: 'Towing',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.orange500,
              foregroundColor: AppPalette.neutral0,
              elevation: 0,
              minimumSize: const Size(0, 38),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s12,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.mdAll,
              ),
            ),
            icon: const Icon(Icons.sos_outlined, size: 16, color: AppPalette.neutral0),
            label: Text(
              'Get Help',
              style: AppTypography.caption.copyWith(
                color: AppPalette.neutral0,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceFinderHeroCard extends StatelessWidget {
  final bool isDesktop;

  const _ServiceFinderHeroCard({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, locationState) {
        return Container(
          padding: EdgeInsets.all(isDesktop ? AppSpacing.s24 : AppSpacing.s20),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppPalette.blue500.withValues(alpha: 0.14),
                      borderRadius: AppRadius.pillAll,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.build_circle_outlined,
                          size: 14,
                          color: AppPalette.blue500,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'SERVICE FINDER · ${locationState.shortAreaName.toUpperCase()}',
                          style: AppTypography.caption.copyWith(
                            color: AppPalette.blue500,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s12),
              Text(
                'Find trusted automotive help near you',
                style: AppTypography.h2.copyWith(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Connect with verified mechanics, towing operators, and tyre '
                'centres around ${locationState.areaLabel}.',
                style: AppTypography.bodySmall.copyWith(
                  color: c.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              Wrap(
                spacing: AppSpacing.s12,
                runSpacing: AppSpacing.s8,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => showServiceRequestSheet(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.blue500,
                      foregroundColor: AppPalette.neutral0,
                      elevation: 0,
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s16,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.mdAll,
                      ),
                    ),
                    icon: const Icon(Icons.add_circle_outline, size: 18, color: AppPalette.neutral0),
                    label: Text(
                      'Request a service',
                      style: AppTypography.button.copyWith(
                        color: AppPalette.neutral0,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.push(AppRoutes.mapPath),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: c.textPrimary,
                      backgroundColor: c.surfaceDefault,
                      side: BorderSide(color: c.borderDefault),
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s16,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.mdAll,
                      ),
                    ),
                    icon: Icon(Icons.map_outlined, size: 18, color: c.textPrimary),
                    label: Text(
                      'View nearby map',
                      style: AppTypography.button.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActiveServiceRequestCard extends StatelessWidget {
  const _ActiveServiceRequestCard();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return BlocBuilder<ServiceRequestCubit, ServiceRequestState>(
      builder: (context, state) {
        final request = state.latestRequest;
        if (request == null) return const SizedBox.shrink();

        final lowest = request.lowestBidUsd;
        final accepted = request.acceptedBidId != null;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            color: c.surfaceDefault,
            borderRadius: AppRadius.lgAll,
            border: Border.all(color: c.borderDefault),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSpacing.s8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'YOUR SERVICE REQUEST',
                          style: AppTypography.caption.copyWith(
                            color: c.textSecondary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppPalette.blue500.withValues(alpha: 0.14),
                            borderRadius: AppRadius.pillAll,
                          ),
                          child: Text(
                            accepted
                                ? 'Bid accepted'
                                : '${request.bids.length} bids to review',
                            style: AppTypography.caption.copyWith(
                              color: AppPalette.blue500,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      request.details.isNotEmpty
                          ? '${request.serviceType} · ${request.details}'
                          : '${request.serviceType} request',
                      style: AppTypography.label.copyWith(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${request.locationLabel} · ${request.createdAtLabel}'
                      '${lowest != null ? ' · From US\$$lowest' : ''}',
                      style: AppTypography.caption.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              ElevatedButton(
                onPressed: accepted
                    ? () => context.push(AppRoutes.mapPath)
                    : () => showServiceBidsSheet(context, request.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.blue500,
                  foregroundColor: AppPalette.neutral0,
                  elevation: 0,
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.mdAll,
                  ),
                ),
                child: Text(
                  accepted ? 'Track live →' : 'View bids →',
                  style: AppTypography.caption.copyWith(
                    color: AppPalette.neutral0,
                    fontWeight: FontWeight.w700,
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

class _ServicesNeedSection extends StatelessWidget {
  final bool isDesktop;

  const _ServicesNeedSection({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeaderRow(
          title: 'What does your car need?',
          actionLabel: isDesktop ? 'All services' : 'Services',
          onTap: () => context.push(AppRoutes.servicesPath),
        ),
        const SizedBox(height: AppSpacing.s12),
        Row(
          children: [
            Expanded(
              child: _ServiceCategoryTile(
                icon: Icons.build_outlined,
                label: 'Mechanics',
                isDesktop: isDesktop,
                onTap: () => showServiceRequestSheet(
                  context,
                  initialServiceType: 'Mechanics',
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: _ServiceCategoryTile(
                icon: Icons.local_shipping_outlined,
                label: 'Towing',
                isDesktop: isDesktop,
                onTap: () => showServiceRequestSheet(
                  context,
                  initialServiceType: 'Towing',
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: _ServiceCategoryTile(
                icon: Icons.album_outlined,
                label: 'Tyres',
                isDesktop: isDesktop,
                onTap: () => showServiceRequestSheet(
                  context,
                  initialServiceType: 'Tyres',
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: _ServiceCategoryTile(
                icon: Icons.grid_view_outlined,
                label: 'More',
                isDesktop: isDesktop,
                onTap: () => context.push(AppRoutes.servicesPath),
              ),
            ),
          ],
        ),
        if (!isDesktop) ...[
          const SizedBox(height: AppSpacing.s16),
          BlocBuilder<LocationCubit, LocationState>(
            builder: (context, locationState) {
              return InkWell(
                onTap: locationState.isLoading
                    ? null
                    : () => triggerGpsDetection(context),
                borderRadius: AppRadius.mdAll,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: AppPalette.blue50,
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: Row(
                    children: [
                      if (locationState.isLoading)
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppPalette.navy900,
                          ),
                        )
                      else
                        const Icon(
                          Icons.my_location_outlined,
                          size: 18,
                          color: AppPalette.navy900,
                        ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Text(
                          locationState.isLoading
                              ? 'Detecting your GPS location...'
                              : 'Find nearby help with GPS',
                          style: AppTypography.label.copyWith(
                            color: AppPalette.navy900,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: AppPalette.navy900,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _ServiceCategoryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDesktop;
  final VoidCallback onTap;

  const _ServiceCategoryTile({
    required this.icon,
    required this.label,
    required this.isDesktop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (isDesktop) {
      return InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
          decoration: BoxDecoration(
            color: c.surfaceDefault,
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: c.borderDefault),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: c.textPrimary),
              const SizedBox(width: AppSpacing.s12),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdAll,
      child: Column(
        children: [
          Container(
            height: 54,
            width: double.infinity,
            decoration: BoxDecoration(
              color: c.surfaceDefault,
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: c.borderDefault),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 22, color: c.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// **Marketplace finds** section with interactive filter pills (`For you`,
/// `Cars`, `Parts & tyres`, `Accessories`) and listing cards with top-right
/// favorite heart button.
class HomeMarketplaceSection extends StatefulWidget {
  const HomeMarketplaceSection({super.key});

  @override
  State<HomeMarketplaceSection> createState() => _HomeMarketplaceSectionState();
}

class _HomeMarketplaceSectionState extends State<HomeMarketplaceSection> {
  String _selectedFilter = 'For you';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDesktop = context.isDesktop;

    final filtered = (_selectedFilter == 'For you'
            ? kMarketplaceItems.take(3)
            : kMarketplaceItems.where((i) => i.category == _selectedFilter))
        .take(3)
        .toList();

    final displayItems = (!isDesktop && _selectedFilter == 'For you')
        ? filtered.take(2).toList()
        : filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeaderRow(
          title: 'Marketplace finds',
          actionLabel: isDesktop ? 'Browse marketplace' : 'Browse',
          onTap: () => context.push(AppRoutes.marketplacePath),
        ),
        if (!isDesktop) ...[
          const SizedBox(height: 2),
          Text(
            'Cars, parts and a little inspiration.',
            style: AppTypography.bodySmall.copyWith(color: c.textSecondary),
          ),
        ],
        const SizedBox(height: AppSpacing.s12),
        Wrap(
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: [
            for (final filter in const [
              'For you',
              'Cars',
              'Parts & tyres',
              'Accessories',
            ])
              _FilterChipPill(
                label: filter,
                selected: _selectedFilter == filter,
                onTap: () => setState(() => _selectedFilter = filter),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.s16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < displayItems.length; i++) ...[
              if (i > 0)
                SizedBox(
                  width: isDesktop ? AppSpacing.s16 : AppSpacing.s12,
                ),
              Expanded(child: _MarketCard(item: displayItems[i])),
            ],
          ],
        ),
      ],
    );
  }
}

class _FilterChipPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.pillAll,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppPalette.blue500 : c.surfaceDefault,
          borderRadius: AppRadius.pillAll,
          border: Border.all(
            color: selected ? AppPalette.blue500 : c.borderDefault,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: selected ? AppPalette.neutral0 : c.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _MarketCard extends StatelessWidget {
  final MarketplaceItem item;

  const _MarketCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  item.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: c.surfaceRaised);
                  },
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppPalette.neutral0,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      size: 15,
                      color: AppPalette.navy900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.category,
                  style: AppTypography.caption.copyWith(
                    color: c.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.price,
                  style: AppTypography.title.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: AppTypography.caption.copyWith(
                    color: c.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// **From your car community** / **Your car community** section matching
/// `media_1794316982499_d7fffc3f.png` (Desktop) and
/// `media_1794316982471_a7e0a687.png` (Mobile).
class HomeCommunitySection extends StatelessWidget {
  final bool stackVertically;

  const HomeCommunitySection({super.key, this.stackVertically = false});

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeaderRow(
          title: isDesktop ? null : 'Your car community',
          actionLabel: isDesktop ? 'Explore community' : 'Explore',
          onTap: () => context.push(AppRoutes.communityPath),
        ),
        const SizedBox(height: AppSpacing.s12),
        if (isDesktop && !stackVertically)
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _ComposerCard(isDesktop: true),
                    SizedBox(height: AppSpacing.s16),
                    _HomeCommunityPostCard(
                      authorInitials: 'TK',
                      authorName: 'Tinashe K.',
                      topic: 'Maintenance talk',
                      timeAgo: '1h ago',
                      title: 'What’s on your pre-road-trip checklist?',
                      body:
                          'Planning a Harare–Bulawayo drive. Tyres, fluids, '
                          'brakes... what else do you always check before '
                          'heading out?',
                      likes: '18',
                      commentsLabel: '12 replies',
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.s16),
              Expanded(
                child: _HomeCommunityPostCard(
                  authorInitials: 'NM',
                  authorName: 'Nyasha M.',
                  topic: 'Harare car lovers',
                  timeAgo: '2h ago',
                  title: 'Good cars. Even better company.',
                  body:
                      'A few favourites from our weekend catch-up. What are '
                      'you driving these days?',
                  imageAsset: 'assets/images/community_meetup.png',
                  likes: '32',
                  commentsLabel: '8 comments',
                ),
              ),
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ComposerCard(isDesktop: isDesktop),
              const SizedBox(height: AppSpacing.s12),
              const _HomeCommunityPostCard(
                authorInitials: 'TK',
                authorName: 'Tinashe K.',
                topic: 'Maintenance talk',
                timeAgo: '1h ago',
                title: 'What’s on your pre-road-trip checklist?',
                body:
                    'Planning a Harare–Bulawayo drive. Tyres, fluids, brakes... '
                    'what else do you always check before heading out?',
                likes: '18',
                commentsLabel: '12 replies',
              ),
              const SizedBox(height: AppSpacing.s12),
              const _HomeCommunityPostCard(
                authorInitials: 'NM',
                authorName: 'Nyasha M.',
                topic: 'Harare car lovers',
                timeAgo: '2h ago',
                title: 'Good cars. Even better company.',
                body:
                    'A few favourites from our weekend catch-up. What are you '
                    'driving these days?',
                imageAsset: 'assets/images/community_meetup.png',
                likes: '32',
                commentsLabel: '8 comments',
              ),
              if (!isDesktop) ...[
                const SizedBox(height: AppSpacing.s16),
                const _MobileBecomeProviderCard(),
              ],
            ],
          ),
      ],
    );
  }
}

class _ComposerCard extends StatelessWidget {
  final bool isDesktop;

  const _ComposerCard({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: c.surfaceDefault,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: c.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => showNewPostSheet(context),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s12),
              child: Row(
                children: [
                  const InitialsAvatar(initials: 'TM', size: 36),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: c.surfaceInput,
                        borderRadius: AppRadius.pillAll,
                        border: Border.all(color: c.borderDefault),
                      ),
                      child: Text(
                        'What’s happening in your car world?',
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: c.borderDefault),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s8,
              vertical: 4,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ComposerQuickAction(
                    icon: Icons.image_outlined,
                    label: 'Photo',
                    onTap: () => showNewPostSheet(
                      context,
                      initialMediaType: CommunityMediaType.image,
                    ),
                  ),
                ),
                Expanded(
                  child: _ComposerQuickAction(
                    icon: Icons.videocam_outlined,
                    label: 'Video',
                    onTap: () => showNewPostSheet(
                      context,
                      initialMediaType: CommunityMediaType.video,
                    ),
                  ),
                ),
                Expanded(
                  child: _ComposerQuickAction(
                    icon: Icons.movie_creation_outlined,
                    label: 'Reel',
                    onTap: () => showNewPostSheet(
                      context,
                      initialMediaType: CommunityMediaType.reel,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComposerQuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ComposerQuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppPalette.blue500),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCommunityPostCard extends StatelessWidget {
  final String authorInitials;
  final String authorName;
  final String topic;
  final String timeAgo;
  final String title;
  final String body;
  final String? imageAsset;
  final String likes;
  final String commentsLabel;

  const _HomeCommunityPostCard({
    required this.authorInitials,
    required this.authorName,
    required this.topic,
    required this.timeAgo,
    required this.title,
    required this.body,
    this.imageAsset,
    required this.likes,
    required this.commentsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.surfaceDefault,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: c.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s16,
              AppSpacing.s16,
              AppSpacing.s16,
              AppSpacing.s12,
            ),
            child: Row(
              children: [
                InitialsAvatar(initials: authorInitials, size: 36),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authorName,
                        style: AppTypography.label.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: AppTypography.caption.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: c.surfaceRaised,
                    borderRadius: AppRadius.pillAll,
                    border: Border.all(color: c.borderDefault),
                  ),
                  child: Text(
                    topic,
                    style: AppTypography.caption.copyWith(
                      color: c.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s16,
              0,
              AppSpacing.s16,
              AppSpacing.s12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.label.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: AppTypography.bodySmall.copyWith(
                    color: c.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          if (imageAsset != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                imageAsset!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: c.surfaceRaised);
                },
              ),
            ),
          Divider(height: 1, color: c.borderDefault),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: 10,
            ),
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppPalette.blue500,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.thumb_up,
                    size: 10,
                    color: AppPalette.neutral0,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  likes,
                  style: AppTypography.caption.copyWith(color: c.textSecondary),
                ),
                const SizedBox(width: AppSpacing.s12),
                Icon(
                  Icons.chat_bubble_outline,
                  size: 14,
                  color: c.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  commentsLabel,
                  style: AppTypography.caption.copyWith(color: c.textSecondary),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => context.push(AppRoutes.communityPath),
                  borderRadius: AppRadius.smAll,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Join in',
                        style: AppTypography.caption.copyWith(
                          color: AppPalette.blue500,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward,
                        size: 13,
                        color: AppPalette.blue500,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileBecomeProviderCard extends StatelessWidget {
  const _MobileBecomeProviderCard();

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
      child: Row(
        children: [
          Icon(Icons.work_outline, size: 20, color: c.textPrimary),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Become a provider',
                  style: AppTypography.label.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Have automotive skills? Apply from your account.',
                  style: AppTypography.caption.copyWith(
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.north_east, size: 16, color: c.textPrimary),
        ],
      ),
    );
  }
}

/// Bottom footnote on the Home Dashboard.
class HomeDashboardFooter extends StatelessWidget {
  const HomeDashboardFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDesktop = context.isDesktop;

    if (isDesktop) {
      return Align(
        alignment: Alignment.centerRight,
        child: Text(
          'Roadlink · Zimbabwe',
          style: AppTypography.caption.copyWith(color: c.textSecondary),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _SectionHeaderRow extends StatelessWidget {
  final String? title;
  final String actionLabel;
  final VoidCallback onTap;

  const _SectionHeaderRow({
    this.title,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Row(
      mainAxisAlignment: title != null
          ? MainAxisAlignment.spaceBetween
          : MainAxisAlignment.end,
      children: [
        if (title != null)
          Expanded(
            child: Text(
              title!,
              style: AppTypography.h3.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        InkWell(
          onTap: onTap,
          borderRadius: AppRadius.smAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionLabel,
                  style: AppTypography.caption.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 13, color: c.textPrimary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

