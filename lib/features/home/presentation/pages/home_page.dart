import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roadlink/app/router/app_router.dart';
import 'package:roadlink/app/theme/app_theme.dart';
import 'package:roadlink/core/utils/responsive.dart';
import 'package:roadlink/features/home/presentation/widgets/home_dashboard_sections.dart';
import 'package:roadlink/features/home/presentation/widgets/home_navigation.dart';
import 'package:roadlink/shared/widgets/section_layout.dart';

/// Roadlink Home Dashboard matching the 5 uploaded Figma exports:
/// - Desktop (`>= 1024px`): Left `HomeDesktopSidebar` + `HomeDesktopTopBar` +
///   `HomeDesktopGreetingRow` + 2-column Services/Near You + 3-column
///   Marketplace finds + 2-column Car Community.
/// - Mobile (`< 1024px`): Top `HomeMobileHeader` (on `AppPalette.navy900` with
///   solid navy status-bar background) + scrollable dashboard body +
///   `HomeMobileBottomNav` (`Home`, `Services`, `Market`, `Community`, `Account`).
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _handleSelectTab(int index) {
    switch (index) {
      case 0:
        setState(() => _selectedIndex = 0);
      case 1:
        context.push(AppRoutes.servicesPath);
      case 2:
        context.push(AppRoutes.marketplacePath);
      case 3:
        context.push(AppRoutes.communityPath);
      case 4:
        context.push(AppRoutes.profilePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDesktop = context.isDesktop;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: c.backgroundCanvas,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HomeDesktopSidebar(
              selectedIndex: _selectedIndex,
              onSelectTab: _handleSelectTab,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const HomeDesktopTopBar(),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            primary: false,
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.s32,
                              AppSpacing.s24,
                              AppSpacing.s24,
                              AppSpacing.s32,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const HomeDesktopGreetingRow(),
                                const SizedBox(height: AppSpacing.s24),
                                const HomeServicesAndNearYouSection(),
                                const SizedBox(height: AppSpacing.s32),
                                const HomeMarketplaceSection(),
                                const SizedBox(height: AppSpacing.s32),
                                const HomeDashboardFooter(),
                              ],
                            ),
                          ),
                        ),
                        const VerticalSectionDivider(),
                        SizedBox(
                          width: 360,
                          child: SingleChildScrollView(
                            primary: false,
                            padding: const EdgeInsets.fromLTRB(
                              0,
                              AppSpacing.s24,
                              AppSpacing.s32,
                              AppSpacing.s32,
                            ),
                            child: const HomeCommunitySection(
                              stackVertically: true,
                            ),
                          ),
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

    return Scaffold(
      backgroundColor: AppPalette.navy900,
      bottomNavigationBar: HomeMobileBottomNav(
        selectedIndex: _selectedIndex,
        onSelectTab: _handleSelectTab,
      ),
      body: SafeArea(
        bottom: false,
        child: ColoredBox(
          color: c.backgroundCanvas,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const HomeMobileHeader(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s20,
                    AppSpacing.s20,
                    AppSpacing.s20,
                    AppSpacing.s24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const HomeServicesAndNearYouSection(),
                      const SizedBox(height: AppSpacing.s24),
                      const HomeMarketplaceSection(),
                      const SizedBox(height: AppSpacing.s24),
                      const HomeCommunitySection(),
                      const SizedBox(height: AppSpacing.s24),
                      const HomeDashboardFooter(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
