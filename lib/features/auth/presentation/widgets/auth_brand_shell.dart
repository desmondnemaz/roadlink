import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roadlink/app/router/app_router.dart';
import 'package:roadlink/app/theme/app_theme.dart';
import 'package:roadlink/shared/widgets/roadlink_logo.dart';

/// Desktop 50/50 split shell used by the Roadlink Auth screens (`Welcome`,
/// `Log in`, and `Sign up` on Desktop/Web).
///
/// Left 50%: [DesktopBrandGradientPanel] (`#0B1F3B -> #FF8C00` brand gradient,
/// centered `RoadlinkLogo`, large white circle with thin-stroke orange location
/// pin, `"Your car world, all connected."`, and subtitle).
/// Right 50%: `surfaceDefault` panel with [rightChild] centered vertically and
/// horizontally.
class AuthDesktopSplitShell extends StatelessWidget {
  final Widget rightChild;
  final double maxFormWidth;

  const AuthDesktopSplitShell({
    super.key,
    required this.rightChild,
    this.maxFormWidth = 420,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.surfaceDefault,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Expanded(
            child: DesktopBrandGradientPanel(),
          ),
          Expanded(
            child: ColoredBox(
              color: c.surfaceDefault,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s40,
                    vertical: AppSpacing.s32,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxFormWidth),
                    child: rightChild,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Left brand panel on Desktop Auth screens matching the Figma export.
class DesktopBrandGradientPanel extends StatelessWidget {
  const DesktopBrandGradientPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RoadlinkColors.brandGradient,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s48,
        vertical: AppSpacing.s40,
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => context.go(AppRoutes.homePath),
                borderRadius: AppRadius.smAll,
                child: const RoadlinkLogo(),
              ),
              const SizedBox(height: AppSpacing.s32),
              const AuthLocationPinCircle(size: 250),
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
                constraints: const BoxConstraints(maxWidth: 400),
                child: Text(
                  'Find services, explore the marketplace, and connect '
                  'with car lovers across Zimbabwe.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyOf(context).copyWith(
                    color: AppPalette.neutral0.withValues(alpha: 0.92),
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

/// Mobile Auth layout with the top brand gradient header and bottom rounded
/// white sheet (`radius/panel = 32 px`), matching Mobile Log In and Mobile
/// Sign Up screens.
class AuthMobileSheetShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showBackButton;
  final Widget sheetChild;

  const AuthMobileSheetShell({
    super.key,
    required this.title,
    required this.subtitle,
    this.showBackButton = false,
    required this.sheetChild,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: AppPalette.navy900,
      body: SafeArea(
        bottom: false,
        child: Container(
          decoration: const BoxDecoration(
            gradient: RoadlinkColors.brandGradient,
          ),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s24,
                    AppSpacing.s16,
                    AppSpacing.s24,
                    AppSpacing.s24,
                  ),
                  child: Column(
                    children: [
                      if (showBackButton) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            onTap: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go(AppRoutes.homePath);
                              }
                            },
                            borderRadius: AppRadius.smAll,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.s4,
                                horizontal: AppSpacing.s4,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.arrow_back,
                                    size: 16,
                                    color: AppPalette.neutral0,
                                  ),
                                  const SizedBox(width: AppSpacing.s8),
                                  Text(
                                    'Back',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppPalette.neutral0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s16),
                      ] else
                        const SizedBox(height: AppSpacing.s8),
                      InkWell(
                        onTap: () => context.go(AppRoutes.homePath),
                        borderRadius: AppRadius.smAll,
                        child: const RoadlinkLogo(
                          iconBoxSize: 40,
                          wordmarkFontSize: 22,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s20),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: AppTypography.h1Of(context).copyWith(
                          color: AppPalette.neutral0,
                          fontSize: 30,
                          height: 36 / 30,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppPalette.neutral0.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: c.surfaceDefault,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.panel),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.s24,
                    AppSpacing.s32,
                    AppSpacing.s24,
                    AppSpacing.s32,
                  ),
                  child: sheetChild,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Large white circle containing the thin-stroke orange location pin from the
/// Figma Auth screens.
class AuthLocationPinCircle extends StatelessWidget {
  final double size;

  const AuthLocationPinCircle({
    super.key,
    this.size = 240,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppPalette.neutral0,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: CustomPaint(
        size: Size(size * 0.56, size * 0.56),
        painter: _ThinLocationPinPainter(),
      ),
    );
  }
}

class _ThinLocationPinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppPalette.blue500
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final topY = h * 0.08;
    final bottomY = h * 0.92;
    final radius = w * 0.34;
    final circleCenterY = topY + radius;

    // Outer teardrop pin path
    final pinPath = Path()
      ..moveTo(cx, bottomY)
      ..cubicTo(
        cx - radius * 0.55,
        bottomY - radius * 0.55,
        cx - radius,
        circleCenterY + radius * 0.55,
        cx - radius,
        circleCenterY,
      )
      ..arcToPoint(
        Offset(cx + radius, circleCenterY),
        radius: Radius.circular(radius),
        clockwise: true,
      )
      ..cubicTo(
        cx + radius,
        circleCenterY + radius * 0.55,
        cx + radius * 0.55,
        bottomY - radius * 0.55,
        cx,
        bottomY,
      )
      ..close();

    canvas.drawPath(pinPath, paint);

    // Inner circle
    canvas.drawCircle(
      Offset(cx, circleCenterY),
      radius * 0.36,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Leading `+263 |` prefix widget inside the Sign Up `Phone number` field.
class ZimbabwePhonePrefix extends StatelessWidget {
  const ZimbabwePhonePrefix({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.s16, right: AppSpacing.s12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '+263',
            style: AppTypography.label.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Container(
            width: 1,
            height: 20,
            color: c.borderDefault,
          ),
        ],
      ),
    );
  }
}

/// Inline prompt row at the bottom of Auth forms (`New to Roadlink? Sign up`
/// or `Already have an account? Log in`).
class AuthSwitchPrompt extends StatelessWidget {
  final String promptText;
  final String actionText;
  final VoidCallback onActionTap;
  final Color? promptColor;
  final Color? actionColor;

  const AuthSwitchPrompt({
    super.key,
    required this.promptText,
    required this.actionText,
    required this.onActionTap,
    this.promptColor,
    this.actionColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$promptText ',
          style: AppTypography.bodySmall.copyWith(
            color: promptColor ?? c.textSecondary,
          ),
        ),
        InkWell(
          onTap: onActionTap,
          borderRadius: AppRadius.smAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s4,
              vertical: 2,
            ),
            child: Text(
              actionText,
              style: AppTypography.bodySmall.copyWith(
                color: actionColor ?? c.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
