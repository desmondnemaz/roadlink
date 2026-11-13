import 'package:flutter/material.dart';
import 'package:roadlink/app/theme/app_theme.dart';

/// Semantic status families from Figma Board 01 & Board 02.
enum RoadlinkStatus {
  success,
  warning,
  danger,
  info,
}

/// Theme-aware status badge where foreground + soft background travel together
/// with a mandatory text label (Figma Board 01: "03 Status pairs" & Board 02:
/// "02 Theme-aware feedback").
class RoadlinkStatusBadge extends StatelessWidget {
  final String label;
  final RoadlinkStatus status;
  final IconData? icon;

  const RoadlinkStatusBadge({
    super.key,
    required this.label,
    this.status = RoadlinkStatus.success,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (Color fg, Color bg) = switch (status) {
      RoadlinkStatus.success => (c.successForeground, c.successBackground),
      RoadlinkStatus.warning => (c.warningForeground, c.warningBackground),
      RoadlinkStatus.danger => (c.dangerForeground, c.dangerBackground),
      RoadlinkStatus.info => (c.infoForeground, c.infoBackground),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: AppSpacing.s4),
          ],
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

