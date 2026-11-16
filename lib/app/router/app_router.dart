import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roadlink/features/auth/presentation/pages/auth_welcome_page.dart';
import 'package:roadlink/features/auth/presentation/pages/login_page.dart';
import 'package:roadlink/features/auth/presentation/pages/signup_page.dart';
import 'package:roadlink/features/community/presentation/pages/community_page.dart';
import 'package:roadlink/features/home/presentation/pages/home_page.dart';
import 'package:roadlink/features/home/presentation/pages/nearby_map_page.dart';
import 'package:roadlink/features/marketplace/presentation/pages/marketplace_page.dart';
import 'package:roadlink/features/marketplace/presentation/pages/marketplace_registration_page.dart';
import 'package:roadlink/features/profile/presentation/pages/profile_page.dart';
import 'package:roadlink/features/services/presentation/pages/service_registration_page.dart';
import 'package:roadlink/features/services/presentation/pages/services_page.dart';
import 'package:roadlink/features/settings/presentation/pages/settings_page.dart';
import 'package:roadlink/features/splash/presentation/pages/splash_page.dart';
import 'package:roadlink/features/users/presentation/pages/user_management_page.dart';

/// Centralised route names and paths for Roadlink.
class AppRoutes {
  AppRoutes._();

  static const String splashName = 'splash';
  static const String splashPath = '/splash';

  static const String homeName = 'home';
  static const String homePath = '/';

  static const String welcomeName = 'welcome';
  static const String welcomePath = '/welcome';

  static const String loginName = 'login';
  static const String loginPath = '/login';

  static const String signupName = 'signup';
  static const String signupPath = '/signup';

  static const String settingsName = 'settings';
  static const String settingsPath = '/settings';

  static const String mapName = 'map';
  static const String mapPath = '/map';

  static const String servicesName = 'services';
  static const String servicesPath = '/services';

  static const String serviceRegisterName = 'serviceRegister';
  static const String serviceRegisterPath = '/services/register';

  static const String marketplaceName = 'marketplace';
  static const String marketplacePath = '/marketplace';

  static const String marketplaceRegisterName = 'marketplaceRegister';
  static const String marketplaceRegisterPath = '/marketplace/register';

  static const String communityName = 'community';
  static const String communityPath = '/community';

  static const String userManagementName = 'userManagement';
  static const String userManagementPath = '/users';

  static const String profileName = 'profile';
  static const String profilePath = '/profile';
}

/// Centralised application router configuration using [GoRouter].
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = createRouter();

  /// Creates a router. [initialLocation] is configurable so tests can skip
  /// the splash screen.
  static GoRouter createRouter({
    String initialLocation = AppRoutes.splashPath,
    GlobalKey<NavigatorState>? navigatorKey,
  }) {
    return GoRouter(
      navigatorKey: navigatorKey ?? rootNavigatorKey,
      initialLocation: initialLocation,
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.splashPath,
          name: AppRoutes.splashName,
          builder: (BuildContext context, GoRouterState state) {
            return const SplashPage();
          },
        ),
        GoRoute(
          path: AppRoutes.homePath,
          name: AppRoutes.homeName,
          builder: (BuildContext context, GoRouterState state) {
            return const HomePage();
          },
        ),
        GoRoute(
          path: AppRoutes.welcomePath,
          name: AppRoutes.welcomeName,
          builder: (BuildContext context, GoRouterState state) {
            return const AuthWelcomePage();
          },
        ),
        GoRoute(
          path: AppRoutes.loginPath,
          name: AppRoutes.loginName,
          builder: (BuildContext context, GoRouterState state) {
            return const LoginPage();
          },
        ),
        GoRoute(
          path: AppRoutes.signupPath,
          name: AppRoutes.signupName,
          builder: (BuildContext context, GoRouterState state) {
            return const SignupPage();
          },
        ),
        GoRoute(
          path: AppRoutes.mapPath,
          name: AppRoutes.mapName,
          builder: (BuildContext context, GoRouterState state) {
            return const NearbyMapPage();
          },
        ),
        GoRoute(
          path: AppRoutes.servicesPath,
          name: AppRoutes.servicesName,
          builder: (BuildContext context, GoRouterState state) {
            final category = state.uri.queryParameters['category'];
            return ServicesPage(initialCategory: category);
          },
        ),
        GoRoute(
          path: AppRoutes.serviceRegisterPath,
          name: AppRoutes.serviceRegisterName,
          builder: (BuildContext context, GoRouterState state) {
            return const ServiceRegistrationPage();
          },
        ),
        GoRoute(
          path: AppRoutes.marketplacePath,
          name: AppRoutes.marketplaceName,
          builder: (BuildContext context, GoRouterState state) {
            final category = state.uri.queryParameters['category'];
            final saved = state.uri.queryParameters['saved'] == 'true';
            return MarketplacePage(
              initialCategory: category,
              initialSavedOnly: saved,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.marketplaceRegisterPath,
          name: AppRoutes.marketplaceRegisterName,
          builder: (BuildContext context, GoRouterState state) {
            return const MarketplaceRegistrationPage();
          },
        ),
        GoRoute(
          path: AppRoutes.communityPath,
          name: AppRoutes.communityName,
          builder: (BuildContext context, GoRouterState state) {
            return const CommunityPage();
          },
        ),
        GoRoute(
          path: AppRoutes.userManagementPath,
          name: AppRoutes.userManagementName,
          builder: (BuildContext context, GoRouterState state) {
            return const UserManagementPage();
          },
        ),
        GoRoute(
          path: AppRoutes.profilePath,
          name: AppRoutes.profileName,
          builder: (BuildContext context, GoRouterState state) {
            return const ProfilePage();
          },
        ),
        GoRoute(
          path: AppRoutes.settingsPath,
          name: AppRoutes.settingsName,
          builder: (BuildContext context, GoRouterState state) {
            return Scaffold(
              appBar: AppBar(title: const Text('Settings')),
              body: const SettingsPage(),
            );
          },
        ),
      ],
    );
  }
}
