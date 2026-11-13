import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roadlink/app/router/app_router.dart';
import 'package:roadlink/app/theme/app_theme.dart';
import 'package:roadlink/core/utils/responsive.dart';
import 'package:roadlink/features/auth/presentation/widgets/auth_brand_shell.dart';
import 'package:roadlink/shared/widgets/roadlink_logo.dart';

/// Auth Welcome screen matching Figma screens 3 (Mobile) and 5 (Desktop):
/// - Desktop: 50/50 split with [DesktopBrandGradientPanel] on the left and the
///   centered `Sign up` (with person-outline icon) + `Already have an account? Log in`
///   CTA block on the right.
/// - Mobile: Full-screen [RoadlinkColors.brandGradient] with centered
///   [RoadlinkLogo], [AuthLocationPinCircle], `"Your car world, all connected."`,
///   white `Sign up` button, and `Already have an account? Log in`.
class AuthWelcomePage extends StatelessWidget {
  const AuthWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop) {
      return const AuthDesktopSplitShell(
        maxFormWidth: 420,
        rightChild: _DesktopWelcomeActions(),
      );
    }
    return const _MobileWelcomeView();
  }
}

class _DesktopWelcomeActions extends StatelessWidget {
  const _DesktopWelcomeActions();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: AppSizes.buttonHeight,
          child: ElevatedButton(
            onPressed: () => context.go(AppRoutes.signupPath),
            style: ElevatedButton.styleFrom(
              backgroundColor: c.actionPrimary,
              foregroundColor: c.actionOnPrimary,
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.mdAll,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 18,
                  color: c.actionOnPrimary,
                ),
                const SizedBox(width: AppSpacing.s8),
                Text(
                  'Sign up',
                  style: AppTypography.button.copyWith(
                    color: c.actionOnPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s16),
        AuthSwitchPrompt(
          promptText: 'Already have an account?',
          actionText: 'Log in',
          onActionTap: () => context.go(AppRoutes.loginPath),
        ),
      ],
    );
  }
}

class _MobileWelcomeView extends StatelessWidget {
  const _MobileWelcomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.navy900,
      body: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RoadlinkColors.brandGradient,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s24,
              vertical: AppSpacing.s32,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.sizeOf(context).height - 96,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => context.go(AppRoutes.homePath),
                    borderRadius: AppRadius.smAll,
                    child: const RoadlinkLogo(
                      iconBoxSize: 40,
                      wordmarkFontSize: 22,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s32),
                  Column(
                    children: [
                      const AuthLocationPinCircle(size: 220),
                      const SizedBox(height: AppSpacing.s32),
                      Text(
                        'Your car world,\nall connected.',
                        textAlign: TextAlign.center,
                        style: AppTypography.displayOf(context).copyWith(
                          color: AppPalette.neutral0,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 340),
                        child: Text(
                          'Find services, explore the marketplace, and '
                          'connect with car lovers across Zimbabwe.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyOf(context).copyWith(
                            color: AppPalette.neutral0.withValues(alpha: 0.92),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s32),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => context.go(AppRoutes.signupPath),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPalette.neutral0,
                            foregroundColor: AppPalette.navy900,
                            elevation: 0,
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppRadius.mdAll,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 19,
                                color: AppPalette.navy900,
                              ),
                              const SizedBox(width: AppSpacing.s8),
                              Text(
                                'Sign up',
                                style: AppTypography.button.copyWith(
                                  color: AppPalette.navy900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      AuthSwitchPrompt(
                        promptText: 'Already have an account?',
                        actionText: 'Log in',
                        promptColor: AppPalette.neutral0.withValues(alpha: 0.9),
                        actionColor: AppPalette.neutral0,
                        onActionTap: () => context.go(AppRoutes.loginPath),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

