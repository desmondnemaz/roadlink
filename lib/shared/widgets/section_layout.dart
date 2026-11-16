import 'package:flutter/material.dart';
import 'package:roadlink/app/theme/app_theme.dart';

/// Modern `1px` vertical gradient hairline used between independently scrolling
/// desktop columns.
class VerticalSectionDivider extends StatelessWidget {
  const VerticalSectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s24,
        vertical: AppSpacing.s24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            c.borderDefault.withValues(alpha: 0),
            c.borderDefault,
            c.borderDefault,
            c.borderDefault.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.08, 0.92, 1.0],
        ),
      ),
    );
  }
}

/// Surface-bordered card container used inside left and right desktop rails.
class SectionRailCard extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;

  const SectionRailCard({
    super.key,
    required this.title,
    this.trailing,
    required this.child,
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.label.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          child,
        ],
      ),
    );
  }
}

/// Vertical or horizontal section selector button used in Explore rails.
class SectionNavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final bool centered;
  final VoidCallback onTap;

  const SectionNavButton({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    this.centered = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdAll,
      child: Container(
        height: 44,
        padding: centered
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
        decoration: BoxDecoration(
          color: selected ? AppPalette.navy900 : c.surfaceDefault,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: selected ? AppPalette.navy900 : c.borderDefault,
          ),
        ),
        child: Row(
          mainAxisAlignment:
              centered ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? AppPalette.blue500 : c.textSecondary,
            ),
            const SizedBox(width: AppSpacing.s8),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label.copyWith(
                  color: selected ? AppPalette.neutral0 : c.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

