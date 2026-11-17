import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:roadlink/app/router/app_router.dart';
import 'package:roadlink/app/theme/app_theme.dart';
import 'package:roadlink/core/utils/responsive.dart';
import 'package:roadlink/features/community/presentation/cubit/community_cubit.dart';
import 'package:roadlink/features/home/presentation/cubit/location_cubit.dart';
import 'package:roadlink/features/home/presentation/widgets/home_navigation.dart';
import 'package:roadlink/features/home/presentation/widgets/my_space_sheets.dart';
import 'package:roadlink/features/services/presentation/cubit/service_request_cubit.dart';
import 'package:roadlink/features/services/presentation/widgets/service_request_sheet.dart';

/// Roadlink user **Profile** page showing account details, location, quick
/// activity counts, garage/requests shortcuts, and provider/seller links.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _fullName = 'Tendai Moyo';
  String _phone = '+263 77 412 8890';
  String _bio = 'Daily commuter & weekend 4x4 enthusiast in Harare.';

  String get _initials {
    final parts = _fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'TM';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _fullName);
    final phoneController = TextEditingController(text: _phone);
    final bioController = TextEditingController(text: _bio);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full name'),
                ),
                const SizedBox(height: AppSpacing.s12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone number'),
                ),
                const SizedBox(height: AppSpacing.s12),
                TextField(
                  controller: bioController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Bio'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (nameController.text.trim().isNotEmpty) {
                    _fullName = nameController.text.trim();
                  }
                  if (phoneController.text.trim().isNotEmpty) {
                    _phone = phoneController.text.trim();
                  }
                  _bio = bioController.text.trim();
                });
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDesktop = context.isDesktop;

    return Scaffold(
      backgroundColor: c.backgroundCanvas,
      bottomNavigationBar:
          !isDesktop ? const HomeMobileBottomNav(selectedIndex: 4) : null,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppPalette.neutral0,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: RoadlinkColors.brandGradientHorizontal,
          ),
        ),
        title: Text(
          'Profile',
          style: AppTypography.label.copyWith(
            color: AppPalette.neutral0,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.settingsPath),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: ResponsiveCenter(
          maxContentWidth: 920,
          padding: EdgeInsets.all(isDesktop ? AppSpacing.s32 : AppSpacing.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Header Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.s20),
                decoration: BoxDecoration(
                  color: c.surfaceDefault,
                  borderRadius: AppRadius.lgAll,
                  border: Border.all(color: c.borderDefault),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InitialsAvatar(initials: _initials, size: 56),
                        const SizedBox(width: AppSpacing.s12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _fullName,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.h2.copyWith(
                                        color: c.textPrimary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.s8),
                                  OutlinedButton.icon(
                                    onPressed: _showEditProfileDialog,
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.s12,
                                        vertical: 6,
                                      ),
                                      minimumSize: const Size(0, 32),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    icon: const Icon(Icons.edit_outlined, size: 14),
                                    label: const Text('Edit', style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 6,
                                runSpacing: 2,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    'Personal account',
                                    style: AppTypography.caption.copyWith(
                                      color: c.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '·',
                                    style: AppTypography.caption.copyWith(
                                      color: c.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    _phone,
                                    style: AppTypography.caption.copyWith(
                                      color: c.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              BlocBuilder<LocationCubit, LocationState>(
                                builder: (context, loc) {
                                  return InkWell(
                                    onTap: () =>
                                        showLocationPickerSheet(context),
                                    borderRadius: AppRadius.smAll,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 15,
                                          color: AppPalette.blue500,
                                        ),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            loc.areaLabel,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTypography.caption.copyWith(
                                              color: AppPalette.blue500,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_bio.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.s16),
                      Text(
                        _bio,
                        style: AppTypography.bodySmall.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s16),

              // Quick Activity Stats
              Row(
                children: [
                  Expanded(
                    child: BlocBuilder<ServiceRequestCubit, ServiceRequestState>(
                      builder: (context, reqState) {
                        return _StatCard(
                          label: 'Service requests',
                          value: '${reqState.requests.length}',
                          icon: Icons.assignment_outlined,
                          onTap: () => showMyRequestsSheet(context),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: BlocBuilder<CommunityCubit, CommunityState>(
                      builder: (context, commState) {
                        final saved = commState.posts
                            .where((p) => p.isSaved)
                            .length;
                        return _StatCard(
                          label: 'Saved posts',
                          value: '$saved',
                          icon: Icons.bookmark_border,
                          onTap: () => context.push(AppRoutes.communityPath),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: _StatCard(
                      label: 'My vehicles',
                      value: '1',
                      icon: Icons.directions_car_outlined,
                      onTap: () => showMyVehiclesSheet(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s24),

              // Account & Business Links
              _ProfileActionGroup(
                title: 'My Roadlink',
                items: [
                  _ProfileAction(
                    icon: Icons.assignment_outlined,
                    title: 'My service requests',
                    subtitle: 'View active requests and provider bids',
                    onTap: () => showMyRequestsSheet(context),
                  ),
                  _ProfileAction(
                    icon: Icons.directions_car_outlined,
                    title: 'My vehicles',
                    subtitle: 'Manage your cars for faster service requests',
                    onTap: () => showMyVehiclesSheet(context),
                  ),
                  _ProfileAction(
                    icon: Icons.favorite_border,
                    title: 'Saved marketplace finds',
                    subtitle: 'View vehicles and parts you bookmarked',
                    onTap: () =>
                        context.push('${AppRoutes.marketplacePath}?saved=true'),
                  ),
                  _ProfileAction(
                    icon: Icons.chat_bubble_outline,
                    title: 'Messages',
                    subtitle: 'Chats with mechanics and marketplace sellers',
                    onTap: () => showMessagesSheet(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s16),
              _ProfileActionGroup(
                title: 'Partner & Admin',
                items: [
                  _ProfileAction(
                    icon: Icons.build_outlined,
                    title: 'Register as a service provider',
                    subtitle: 'Offer mechanic, towing, or tyre services',
                    onTap: () => context.push(AppRoutes.serviceRegisterPath),
                  ),
                  _ProfileAction(
                    icon: Icons.storefront_outlined,
                    title: 'Register as a marketplace seller',
                    subtitle: 'List cars, spare parts, or accessories',
                    onTap: () =>
                        context.push(AppRoutes.marketplaceRegisterPath),
                  ),
                  _ProfileAction(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Admin',
                    subtitle: 'Manage platform users, roles, and verification',
                    onTap: () => context.push(AppRoutes.userManagementPath),
                  ),
                  _ProfileAction(
                    icon: Icons.settings_outlined,
                    title: 'Appearance & settings',
                    subtitle: 'Switch Light/Dark mode and preferences',
                    onTap: () => context.push(AppRoutes.settingsPath),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s16),
              _ProfileActionGroup(
                title: 'Account & Authentication',
                items: [
                  _ProfileAction(
                    icon: Icons.waving_hand_outlined,
                    title: 'Welcome screen',
                    subtitle: 'View the Roadlink onboarding & auth landing page',
                    onTap: () => context.push(AppRoutes.welcomePath),
                  ),
                  _ProfileAction(
                    icon: Icons.login_outlined,
                    title: 'Log in',
                    subtitle: 'Open the sign-in page (email or +263 phone)',
                    onTap: () => context.push(AppRoutes.loginPath),
                  ),
                  _ProfileAction(
                    icon: Icons.person_add_outlined,
                    title: 'Sign up',
                    subtitle: 'Open the new account registration page',
                    onTap: () => context.push(AppRoutes.signupPath),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s24),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged out of Roadlink.')),
                  );
                  context.go(AppRoutes.welcomePath);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: c.dangerForeground,
                  side: BorderSide(color: c.dangerForeground),
                  minimumSize: const Size.fromHeight(48),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.mdAll,
                  ),
                ),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Log out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.lgAll,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s16),
        decoration: BoxDecoration(
          color: c.surfaceDefault,
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: c.borderDefault),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: AppPalette.blue500),
            const SizedBox(height: AppSpacing.s8),
            Text(
              value,
              style: AppTypography.h2.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

class _ProfileActionGroup extends StatelessWidget {
  final String title;
  final List<_ProfileAction> items;

  const _ProfileActionGroup({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: c.surfaceDefault,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: c.borderDefault),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s16,
              AppSpacing.s16,
              AppSpacing.s16,
              AppSpacing.s8,
            ),
            child: Text(
              title,
              style: AppTypography.label.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) Divider(height: 1, color: c.borderDefault),
            Material(
              type: MaterialType.transparency,
              child: ListTile(
                leading: Icon(items[i].icon, color: AppPalette.blue500),
                title: Text(
                  items[i].title,
                  style: AppTypography.bodySmall.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  items[i].subtitle,
                  style: AppTypography.caption.copyWith(color: c.textSecondary),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: c.textSecondary,
                ),
                onTap: items[i].onTap,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
