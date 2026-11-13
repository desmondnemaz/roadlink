import 'package:flutter/material.dart';
import 'package:roadlink/app/theme/app_theme.dart';

/// Labeled input field implementing Figma Board 04 ("02 Labeled input fields"):
/// - Keep labels visible (`14/20 Semi Bold`, `8 px` above the field).
/// - Inputs use `Body 16/24`; readable hints use `text/secondary`; helper and
///   error messages use `Body Small 14/20`.
/// - Focus renders a `3 px` outer `focus/ring` while keeping the `1 px` input
///   boundary.
/// - Errors use `status/danger/foreground` (`1 px` border + trailing warning
///   icon + specific error message so errors are never communicated by color
///   alone).
class RoadlinkTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool showPasswordToggle;
  final bool enabled;
  final Widget? prefixIcon;
  final BoxConstraints? prefixIconConstraints;

  const RoadlinkTextField({
    super.key,
    required this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.showPasswordToggle = false,
    this.enabled = true,
    this.prefixIcon,
    this.prefixIconConstraints,
  });

  @override
  State<RoadlinkTextField> createState() => _RoadlinkTextFieldState();
}

class _RoadlinkTextFieldState extends State<RoadlinkTextField> {
  final FocusNode _focusNode = FocusNode();
  late bool _obscured = widget.obscureText;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasError =
        widget.errorText != null && widget.errorText!.trim().isNotEmpty;
    final borderColor = hasError ? c.dangerForeground : c.borderDefault;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: AppTypography.label.copyWith(color: c.textPrimary),
        ),
        const SizedBox(height: AppLayout.labelToInput),
        AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppRadius.md + AppSizes.focusRingWidth,
            ),
            border: Border.all(
              color: _isFocused && !hasError
                  ? c.focusRing
                  : Colors.transparent,
              width: AppSizes.focusRingWidth,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            obscureText: _obscured,
            enabled: widget.enabled,
            style: AppTypography.body.copyWith(color: c.textPrimary),
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: widget.prefixIcon,
              prefixIconConstraints: widget.prefixIconConstraints,
              suffixIcon: _buildSuffixIcon(c, hasError),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.mdAll,
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.mdAll,
                borderSide: BorderSide(color: borderColor),
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.s8),
          Text(
            widget.errorText!,
            style: AppTypography.bodySmall.copyWith(color: c.dangerForeground),
          ),
        ] else if (widget.helperText != null) ...[
          const SizedBox(height: AppSpacing.s8),
          Text(
            widget.helperText!,
            style: AppTypography.bodySmall.copyWith(color: c.textSecondary),
          ),
        ],
      ],
    );
  }

  Widget? _buildSuffixIcon(RoadlinkColors c, bool hasError) {
    if (widget.obscureText && widget.showPasswordToggle) {
      return IconButton(
        tooltip: _obscured ? 'Show password' : 'Hide password',
        onPressed: () => setState(() => _obscured = !_obscured),
        icon: Icon(
          _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
          color: hasError ? c.dangerForeground : c.textSecondary,
        ),
      );
    }
    if (hasError) {
      return Icon(
        Icons.error_outline,
        size: 20,
        color: c.dangerForeground,
      );
    }
    return null;
  }
}
