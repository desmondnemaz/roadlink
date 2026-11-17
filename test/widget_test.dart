import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadlink/app/app.dart';
import 'package:roadlink/app/router/app_router.dart';
import 'package:roadlink/app/theme/app_theme.dart';

void main() {
  testWidgets(
    'Splash leads to Home dashboard, Auth screens render, and Settings switches between Roadlink Light and Dark tokens',
    (WidgetTester tester) async {
      await tester.pumpWidget(const RoadlinkApp());

      // Splash screen renders first on navy/900 with the Roadlink tagline.
      expect(find.text('Your car world, all connected.'), findsOneWidget);
      final splashScaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(splashScaffold.backgroundColor, AppPalette.navy900);

      // Advance past the 1.5s splash timer to reach Auth Welcome, then Home Dashboard.
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pumpAndSettle();
      expect(find.text('Sign up'), findsOneWidget);

      AppRouter.router.go(AppRoutes.homePath);
      await tester.pumpAndSettle();

      // Verify the Home Dashboard greeting and core sections are displayed.
      expect(find.text('Morning, Tendai.'), findsOneWidget);
      expect(find.text('Avondale, Harare'), findsWidgets);
      expect(find.text('What does your car need?'), findsOneWidget);
      expect(find.text('Marketplace finds'), findsOneWidget);

      // Tap the location selector in the header to open the Location Picker sheet
      // and switch to Borrowdale, Harare.
      await tester.tap(find.text('Avondale, Harare').first);
      await tester.pumpAndSettle();
      expect(find.text('Your location'), findsOneWidget);
      expect(find.text('Use current GPS location'), findsOneWidget);
      await tester.tap(find.text('Borrowdale, Harare'));
      await tester.pumpAndSettle();
      expect(find.text('Borrowdale, Harare'), findsWidgets);

      // Light mode semantic tokens are active by default.
      BuildContext ctx = tester.element(
        find.text('What does your car need?'),
      );
      expect(ctx.colors.backgroundCanvas, RoadlinkColors.light.backgroundCanvas);
      expect(ctx.colors.actionPrimary, AppPalette.blue500);

      // Navigate to /settings and toggle Dark Theme.
      AppRouter.router.go(AppRoutes.settingsPath);
      await tester.pumpAndSettle();

      expect(find.text('Dark Theme'), findsOneWidget);
      expect(find.text('Light mode is currently active'), findsOneWidget);
      expect(find.text('Brake inspection'), findsOneWidget);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(find.text('Dark mode is currently active'), findsOneWidget);

      // Dark mode semantic tokens are now active: canvas is navy/950 and
      // primary action flips to orange/500 per Figma board 02.
      ctx = tester.element(find.text('Brake inspection'));
      expect(ctx.colors.backgroundCanvas, AppPalette.navy950);
      expect(ctx.colors.surfaceDefault, AppPalette.navy900);
      expect(ctx.colors.actionPrimary, AppPalette.buttonBlue);

      // Verify Auth Welcome (/welcome), Sign Up (/signup), and Log In (/login)
      // screens render with their Figma labels and fields.
      AppRouter.router.go(AppRoutes.welcomePath);
      await tester.pumpAndSettle();
      expect(find.text('Your car world,\nall connected.'), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);

      AppRouter.router.go(AppRoutes.signupPath);
      await tester.pumpAndSettle();
      expect(find.text('Create your account'), findsWidgets);
      expect(find.text('First name'), findsOneWidget);
      expect(find.text('Last name'), findsOneWidget);
      expect(find.text('+263'), findsOneWidget);
      expect(find.text('Confirm password'), findsOneWidget);

      AppRouter.router.go(AppRoutes.loginPath);
      await tester.pumpAndSettle();
      expect(find.text('Email or phone number'), findsOneWidget);
      expect(
        find.text('Use the email or phone number you signed up with.'),
        findsOneWidget,
      );

      // Verify All Services (/services) and Marketplace (/marketplace) pages render.
      AppRouter.router.go(AppRoutes.servicesPath);
      await tester.pumpAndSettle();
      expect(find.text('All services'), findsOneWidget);
      expect(find.text('Tawanda’s Auto Care'), findsOneWidget);

      AppRouter.router.go(AppRoutes.marketplacePath);
      await tester.pumpAndSettle();
      expect(find.text('Marketplace'), findsOneWidget);
      expect(find.text('Silver compact hatchback'), findsOneWidget);

      AppRouter.router.go(AppRoutes.communityPath);
      await tester.pumpAndSettle();
      expect(find.text('Community'), findsWidgets);
      expect(
        find.text('What’s on your pre-road-trip checklist?'),
        findsOneWidget,
      );

      AppRouter.router.go(AppRoutes.serviceRegisterPath);
      await tester.pumpAndSettle();
      expect(find.text('Register your automotive service'), findsOneWidget);

      AppRouter.router.go(AppRoutes.marketplaceRegisterPath);
      await tester.pumpAndSettle();
      expect(find.text('Sell on Roadlink Marketplace'), findsOneWidget);

      AppRouter.router.go(AppRoutes.userManagementPath);
      await tester.pumpAndSettle();
      expect(find.text('Admin'), findsWidgets);
      expect(find.text('Tendai Moyo'), findsOneWidget);

      AppRouter.router.go(AppRoutes.profilePath);
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Tendai Moyo'), findsOneWidget);
    },
  );
}
