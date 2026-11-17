import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:roadlink/app/router/app_router.dart';
import 'package:roadlink/app/theme/app_theme.dart';
import 'package:roadlink/core/services/location_service.dart';
import 'package:roadlink/features/home/presentation/cubit/location_cubit.dart';
import 'package:roadlink/features/home/presentation/widgets/my_space_sheets.dart';
import 'package:roadlink/features/services/presentation/widgets/service_request_sheet.dart';
import 'package:roadlink/shared/widgets/roadlink_logo.dart';

/// Triggers a one-time foreground GPS lookup via `geolocator` and shows
/// feedback to the user.
Future<void> triggerGpsDetection(BuildContext context) async {
  final cubit = context.read<LocationCubit>();
  final messenger = ScaffoldMessenger.of(context);
  final ok = await cubit.detectGpsLocation();
  if (!context.mounted) return;
  final state = cubit.state;
  if (ok) {
    messenger.showSnackBar(
      SnackBar(
        content: Text('GPS location updated: ${state.areaLabel}'),
      ),
    );
  } else if (state.errorMessage != null) {
    showLocationPickerSheet(context);
  }
}

/// Opens a modal bottom sheet allowing the user to detect their live GPS
/// location via `geolocator` or search/select any Zimbabwe street, suburb,
/// landmark, or town (live autocomplete like inDrive).
Future<void> showLocationPickerSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surfaceDefault,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (sheetContext) {
      var searchQuery = '';
      var isSearching = false;
      List<ZimbabwePlace>? liveResults;
      Timer? debounce;

      return StatefulBuilder(
        builder: (context, setSheetState) {
          return BlocBuilder<LocationCubit, LocationState>(
            builder: (context, state) {
              final c = context.colors;
              final localPlaces = LocationService.knownPlaces.where((p) {
                if (searchQuery.trim().isEmpty) return true;
                return p.name.toLowerCase().contains(
                      searchQuery.trim().toLowerCase(),
                    );
              }).toList();
              final displayPlaces =
                  (searchQuery.trim().length >= 2 && liveResults != null)
                      ? liveResults!
                      : localPlaces;

              return SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.s24,
                    AppSpacing.s20,
                    AppSpacing.s24,
                    AppSpacing.s24 +
                        MediaQuery.of(sheetContext).viewInsets.bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your location',
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
                      const SizedBox(height: AppSpacing.s8),
                      ElevatedButton(
                        onPressed: state.isLoading
                            ? null
                            : () async {
                                final cubit = context.read<LocationCubit>();
                                final messenger = ScaffoldMessenger.of(context);
                                final ok = await cubit.detectGpsLocation();
                                if (ok && sheetContext.mounted) {
                                  Navigator.of(sheetContext).pop();
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'GPS location updated: ${cubit.state.areaLabel}',
                                      ),
                                    ),
                                  );
                                }
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (state.isLoading)
                              const SizedBox(
                                width: 16,
                                height: 16,
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
                            const SizedBox(width: AppSpacing.s8),
                            Text(
                              state.isLoading
                                  ? 'Detecting GPS location...'
                                  : 'Use current GPS location',
                              style: AppTypography.button.copyWith(
                                color: AppPalette.navy900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (state.errorMessage != null) ...[
                        const SizedBox(height: AppSpacing.s12),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.s12),
                          decoration: BoxDecoration(
                            color: c.warningBackground,
                            borderRadius: AppRadius.mdAll,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: c.warningForeground,
                              ),
                              const SizedBox(width: AppSpacing.s8),
                              Expanded(
                                child: Text(
                                  state.errorMessage!,
                                  style: AppTypography.caption.copyWith(
                                    color: c.warningForeground,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.s16),
                      Text(
                        'OR CHOOSE AN AREA IN ZIMBABWE',
                        style: AppTypography.caption.copyWith(
                          color: c.textSecondary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      TextField(
                        onChanged: (value) {
                          setSheetState(() => searchQuery = value);
                          debounce?.cancel();
                          if (value.trim().length < 2) {
                            setSheetState(() {
                              isSearching = false;
                              liveResults = null;
                            });
                            return;
                          }
                          setSheetState(() => isSearching = true);
                          debounce = Timer(
                            const Duration(milliseconds: 350),
                            () async {
                              final results = await context
                                  .read<LocationCubit>()
                                  .searchPlaces(value);
                              if (!sheetContext.mounted) return;
                              setSheetState(() {
                                liveResults = results;
                                isSearching = false;
                              });
                            },
                          );
                        },
                        style: AppTypography.bodySmall.copyWith(
                          color: c.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Search street, suburb, landmark, or town...',
                          prefixIcon: Icon(
                            Icons.search,
                            size: 18,
                            color: c.textSecondary,
                          ),
                          suffixIcon: isSearching
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : null,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s12,
                            vertical: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 260),
                        child: displayPlaces.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.s20,
                                ),
                                child: Center(
                                  child: Text(
                                    isSearching
                                        ? 'Searching Zimbabwe places...'
                                        : 'No matching places found',
                                    style: AppTypography.caption.copyWith(
                                      color: c.textSecondary,
                                    ),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                itemCount: displayPlaces.length,
                                separatorBuilder: (_, _) =>
                                    Divider(height: 1, color: c.borderDefault),
                                itemBuilder: (context, index) {
                                  final place = displayPlaces[index];
                                  final isSelected =
                                      state.areaLabel == place.name;

                                  return ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(
                                      Icons.location_on_outlined,
                                      size: 18,
                                      color: isSelected
                                          ? AppPalette.blue500
                                          : c.textSecondary,
                                    ),
                                    title: Text(
                                      place.name,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: c.textPrimary,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                    ),
                                    trailing: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            size: 18,
                                            color: AppPalette.blue500,
                                          )
                                        : null,
                                    onTap: () {
                                      debounce?.cancel();
                                      context
                                          .read<LocationCubit>()
                                          .selectPlace(place);
                                      Navigator.of(sheetContext).pop();
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}

/// Circular user initials badge (`TM`, `TK`, `NM`) used across headers,
/// sidebar, and community cards.
class InitialsAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final VoidCallback? onTap;

  const InitialsAvatar({
    super.key,
    required this.initials,
    this.size = 36,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppPalette.blue50,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTypography.caption.copyWith(
          color: AppPalette.navy900,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.34,
        ),
      ),
    );

    if (onTap == null) return badge;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: badge,
    );
  }
}

/// Desktop left navigation sidebar (`256 px` wide, `AppPalette.navy900`)
/// matching `media_1794316982483_3e07ffbc.png`.
class HomeDesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelectTab;

  const HomeDesktopSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelectTab,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      width: 256,
      decoration: BoxDecoration(
        color: c.surfaceDefault,
        border: Border(right: BorderSide(color: c.borderDefault)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.s24,
                AppSpacing.s20,
                AppSpacing.s16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.s4),
                    child: RoadlinkLogo(
                      iconBoxSize: 36,
                      wordmarkFontSize: 20,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s24),
                  const _SectionLabel('YOUR ROADLINK'),
                  const SizedBox(height: AppSpacing.s8),
                  _SidebarItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    selected: selectedIndex == 0,
                    onTap: () => onSelectTab(0),
                  ),
                  _SidebarItem(
                    icon: Icons.build_outlined,
                    label: 'Services',
                    selected: selectedIndex == 1,
                    onTap: () => onSelectTab(1),
                  ),
                  _SidebarItem(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Marketplace',
                    selected: selectedIndex == 2,
                    onTap: () => onSelectTab(2),
                  ),
                  _SidebarItem(
                    icon: Icons.forum_outlined,
                    label: 'Community',
                    selected: selectedIndex == 3,
                    onTap: () => onSelectTab(3),
                  ),
                  const SizedBox(height: AppSpacing.s20),
                  const _SectionLabel('MY SPACE'),
                  const SizedBox(height: AppSpacing.s8),
                  _SidebarItem(
                    icon: Icons.assignment_outlined,
                    label: 'My requests',
                    onTap: () => showMyRequestsSheet(context),
                  ),
                  _SidebarItem(
                    icon: Icons.chat_bubble_outline,
                    label: 'Messages',
                    onTap: () => showMessagesSheet(context),
                  ),
                  _SidebarItem(
                    icon: Icons.favorite_border,
                    label: 'Saved finds',
                    onTap: () =>
                        context.push('${AppRoutes.marketplacePath}?saved=true'),
                  ),
                  _SidebarItem(
                    icon: Icons.directions_car_outlined,
                    label: 'My vehicles',
                    onTap: () => showMyVehiclesSheet(context),
                  ),
                  _SidebarItem(
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'Admin',
                    onTap: () => context.push(AppRoutes.userManagementPath),
                  ),
                  const SizedBox(height: AppSpacing.s20),
                  _SidebarItem(
                    icon: Icons.help_outline,
                    label: 'Help & support',
                    onTap: () => showHelpSupportSheet(context),
                  ),
                  _SidebarItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () => context.push(AppRoutes.settingsPath),
                  ),
                ],
              ),
            ),
          ),
          // Bottom account strip
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s20,
              vertical: AppSpacing.s16,
            ),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.borderDefault)),
            ),
            child: InkWell(
              onTap: () => context.push(AppRoutes.profilePath),
              borderRadius: AppRadius.mdAll,
              child: Row(
                children: [
                  const InitialsAvatar(initials: 'TM', size: 36),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Tendai Moyo',
                          style: AppTypography.label.copyWith(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Personal account',
                          style: AppTypography.caption.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Logged out of Roadlink.')),
                      );
                      context.go(AppRoutes.welcomePath);
                    },
                    icon: Icon(
                      Icons.logout,
                      size: 18,
                      color: c.textSecondary,
                    ),
                    tooltip: 'Log out',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: c.textSecondary,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppPalette.blue500.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: AppRadius.mdAll,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: selected ? AppPalette.blue500 : c.textSecondary,
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: selected ? AppPalette.blue500 : c.textPrimary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              if (selected)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppPalette.blue500,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Desktop top utility bar (`Search services, cars, parts and conversations`,
/// `GPS LOCATION Avondale, Harare`, notification bell, `TM` avatar).
class HomeDesktopTopBar extends StatelessWidget {
  const HomeDesktopTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s32,
        vertical: AppSpacing.s16,
      ),
      decoration: BoxDecoration(
        color: c.surfaceDefault,
        border: Border(bottom: BorderSide(color: c.borderDefault)),
      ),
      child: Row(
        children: [
          // Search box
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
              decoration: BoxDecoration(
                color: c.surfaceInput,
                borderRadius: AppRadius.mdAll,
                border: Border.all(color: c.borderDefault),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 18, color: c.textSecondary),
                  const SizedBox(width: AppSpacing.s8),
                  Expanded(
                    child: Text(
                      'Search services, cars, parts and conversations',
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Text(
                    '⌘ K',
                    style: AppTypography.caption.copyWith(
                      color: c.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // GPS Location selector wired to LocationCubit
          BlocBuilder<LocationCubit, LocationState>(
            builder: (context, locationState) {
              return InkWell(
                onTap: () => showLocationPickerSheet(context),
                borderRadius: AppRadius.smAll,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s8,
                    vertical: AppSpacing.s4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (locationState.isLoading)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: c.textPrimary,
                        ),
                      const SizedBox(width: AppSpacing.s8),
                      Text(
                        locationState.areaLabel,
                        style: AppTypography.caption.copyWith(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: c.textSecondary,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: AppSpacing.s16),
          Container(width: 1, height: 22, color: c.borderDefault),
          const SizedBox(width: AppSpacing.s12),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications_none_outlined,
              size: 20,
              color: c.textPrimary,
            ),
            tooltip: 'Notifications',
          ),
          const SizedBox(width: AppSpacing.s8),
          InitialsAvatar(
            initials: 'TM',
            size: 36,
            onTap: () => context.push(AppRoutes.profilePath),
          ),
        ],
      ),
    );
  }
}

/// Mobile top navy header matching `media_1794316982485_517b0b97.png`:
/// - Solid `AppPalette.navy900` background
/// - Top row: `RoadlinkLogo` + notification bell + `TM` avatar
/// - Greeting: `Morning, Tendai.`
/// - Location: orange pin + `Avondale, Harare` + chevron + `· GPS location`
/// - Search input bar: `Services, cars, parts & conversations`
class HomeMobileHeader extends StatelessWidget {
  const HomeMobileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      decoration: const BoxDecoration(
        gradient: RoadlinkColors.brandGradientHorizontal,
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s20,
        topInset > 0 ? topInset + AppSpacing.s12 : AppSpacing.s16,
        AppSpacing.s20,
        AppSpacing.s20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const RoadlinkLogo(
                iconBoxSize: 36,
                wordmarkFontSize: 20,
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_outlined,
                  color: AppPalette.neutral0,
                  size: 22,
                ),
                tooltip: 'Notifications',
              ),
              const SizedBox(width: AppSpacing.s4),
              InitialsAvatar(
                initials: 'TM',
                size: 36,
                onTap: () => context.push(AppRoutes.profilePath),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          Text(
            'Morning, Tendai.',
            style: AppTypography.h1.copyWith(
              color: AppPalette.neutral0,
              fontSize: 26,
              height: 32 / 26,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          BlocBuilder<LocationCubit, LocationState>(
            builder: (context, locationState) {
              return InkWell(
                onTap: () => showLocationPickerSheet(context),
                borderRadius: AppRadius.smAll,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (locationState.isLoading)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppPalette.blue500,
                        ),
                      )
                    else
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppPalette.blue500,
                      ),
                    const SizedBox(width: 6),
                    Text(
                      locationState.areaLabel,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppPalette.neutral300,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: AppPalette.neutral300,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.s16),
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            decoration: BoxDecoration(
              color: c.surfaceDefault,
              borderRadius: AppRadius.mdAll,
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 18, color: c.textSecondary),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Text(
                    'Services, cars, parts & conversations',
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: c.textSecondary,
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

/// Mobile 5-item bottom navigation bar matching
/// `media_1794316982485_68a38131.png` (`Home`, `Services`, `Market`,
/// `Community`, `Account`).
class HomeMobileBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onSelectTab;

  const HomeMobileBottomNav({
    super.key,
    required this.selectedIndex,
    this.onSelectTab,
  });

  void _defaultNavigate(BuildContext context, int index) {
    if (index == selectedIndex) return;
    switch (index) {
      case 0:
        context.go(AppRoutes.homePath);
      case 1:
        context.go(AppRoutes.servicesPath);
      case 2:
        context.go(AppRoutes.marketplacePath);
      case 3:
        context.go(AppRoutes.communityPath);
      case 4:
        context.go(AppRoutes.profilePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    const items = [
      (Icons.home_outlined, 'Home'),
      (Icons.build_outlined, 'Services'),
      (Icons.shopping_bag_outlined, 'Market'),
      (Icons.forum_outlined, 'Community'),
      (Icons.person_outline, 'Account'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: c.surfaceDefault,
        border: Border(top: BorderSide(color: c.borderDefault)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onSelectTab != null
                        ? onSelectTab!(i)
                        : _defaultNavigate(context, i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          items[i].$1,
                          size: 22,
                          color: selectedIndex == i
                              ? AppPalette.blue500
                              : c.textSecondary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          items[i].$2,
                          style: AppTypography.caption.copyWith(
                            color: selectedIndex == i
                                ? c.textPrimary
                                : c.textSecondary,
                            fontWeight: selectedIndex == i
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

