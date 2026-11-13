import 'package:flutter/material.dart';
import 'package:roadlink/app/theme/app_theme.dart';

/// Button variants defined in Figma Board 04 ("01 Action recipes").
enum RoadlinkButtonVariant {
  /// Primary action: `action/primary` + `action/on-primary`
  /// (Light: navy/900 + white; Dark: orange/500 + navy/900).
  primary,

  /// Secondary action: `surface/default` + `text/primary` + 1 px `border/default`.
  secondary,

  /// Accent action: `action/accent` (orange/500) + `action/on-accent` (navy/900).
  accent,

  /// Inline link action: `link/default` (Light: orange/700; Dark: orange/300).
  link,
}

/// Reusable button implementing Figma Board 04 ("01 Action recipes"):
/// 48 px high Â· radius/md 12 Â· horizontal padding 20 Â· Button 16/24 Bold,
/// with explicit disabled tokens and a 3 px outer focus ring on keyboard focus.
class RoadlinkButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final RoadlinkButtonVariant variant;
  final IconData? trailingIcon;
  final IconData? leadingIcon;
  final bool isLoading;
  final bool expand;

  const RoadlinkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = RoadlinkButtonVariant.primary,
    this.trailingIcon,
    this.leadingIcon,
    this.isLoading = false,
    this.expand = false,
  });

  @override
  State<RoadlinkButton> createState() => _RoadlinkButtonState();
}

class _RoadlinkButtonState extends State<RoadlinkButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = widget.onPressed != null && !widget.isLoading;

    if (widget.variant == RoadlinkButtonVariant.link) {
      final fg = enabled ? c.linkDefault : c.disabledText;
      return TextButton(
        onPressed: enabled ? widget.onPressed : null,
        child: _buildContent(fg),
      );
    }

    final Widget button = switch (widget.variant) {
      RoadlinkButtonVariant.primary => FilledButton(
          onFocusChange: (f) => setState(() => _isFocused = f),
          onPressed: enabled ? widget.onPressed : null,
          child: _buildContent(
            enabled ? c.actionOnPrimary : c.disabledText,
          ),
        ),
      RoadlinkButtonVariant.secondary => OutlinedButton(
          onFocusChange: (f) => setState(() => _isFocused = f),
          onPressed: enabled ? widget.onPressed : null,
          child: _buildContent(
            enabled ? c.textPrimary : c.disabledText,
          ),
        ),
      RoadlinkButtonVariant.accent => ElevatedButton(
          onFocusChange: (f) => setState(() => _isFocused = f),
          onPressed: enabled ? widget.onPressed : null,
          child: _buildContent(
            enabled ? c.actionOnAccent : c.disabledText,
          ),
        ),
      RoadlinkButtonVariant.link => const SizedBox.shrink(),
    };

    final decorated = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          AppRadius.md + AppSizes.focusRingWidth,
        ),
        border: Border.all(
          color: _isFocused ? c.focusRing : Colors.transparent,
          width: AppSizes.focusRingWidth,
        ),
      ),
      child: button,
    );

    if (widget.expand) {
      return SizedBox(width: double.infinity, child: decorated);
    }
    return decorated;
  }

  Widget _buildContent(Color foreground) {
    if (widget.isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(foreground),
        ),
      );
    }

    return Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.leadingIcon != null) ...[
          Icon(widget.leadingIcon, size: 18, color: foreground),
          const SizedBox(width: AppSpacing.s8),
        ],
        Text(
          widget.label,
          style: AppTypography.button.copyWith(color: foreground),
        ),
        if (widget.trailingIcon != null) ...[
          const SizedBox(width: AppSpacing.s8),
          Icon(widget.trailingIcon, size: 18, color: foreground),
        ],
      ],
    );
  }
}

