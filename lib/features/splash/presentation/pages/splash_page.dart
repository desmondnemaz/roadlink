import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roadlink/app/router/app_router.dart';
import 'package:roadlink/app/theme/app_theme.dart';
import 'package:roadlink/shared/widgets/roadlink_logo.dart';

/// Roadlink splash screen (Figma "Roadlink Mobile Splash").
///
/// The splash is a fixed brand surface (navy/900) in both Light and Dark
/// themes, as shown in the design.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key, this.delay = const Duration(milliseconds: 1500)});

  final Duration delay;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () {
      if (mounted) context.goNamed(AppRoutes.homeName);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.navy900,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppLayout.mobilePageInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const RoadlinkLogo.splash(),
              const SizedBox(height: AppSpacing.s32),
              Text(
                'Roadlink',
                textAlign: TextAlign.center,
                style: AppTypography.h1.copyWith(color: AppPalette.neutral0),
              ),
              const SizedBox(height: AppSpacing.s12),
              Text(
                'Your car world, all connected.',
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: AppPalette.neutral300),
              ),
              const SizedBox(height: AppSpacing.s24),
              Container(
                width: 32,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppPalette.orange500,
                  borderRadius: AppRadius.pillAll,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
