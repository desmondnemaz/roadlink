import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roadlink/app/router/app_router.dart';
import 'package:roadlink/app/theme/app_theme.dart';
import 'package:roadlink/core/utils/responsive.dart';
import 'package:roadlink/features/auth/presentation/widgets/auth_brand_shell.dart';
import 'package:roadlink/shared/widgets/roadlink_button.dart';
import 'package:roadlink/shared/widgets/roadlink_text_field.dart';

/// Roadlink Log In screen matching Figma screens 1 (Mobile) and 4 (Desktop):
/// - Desktop: 50/50 split with [DesktopBrandGradientPanel] on the left and
///   `â† Back to Roadlink`, `Welcome back`, `Log in to continue your Roadlink journey.`,
///   `Email or phone number`, `Password`, `Log in`, and `New to Roadlink? Sign up`
///   on the right.
/// - Mobile: [AuthMobileSheetShell] with `â† Back`, `RoadlinkLogo`,
///   `"Your car world,\nall connected."`, `"Your Roadlink journey continues here."`
///   above a rounded white sheet containing the form fields.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _identifierError;
  String? _passwordError;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    setState(() {
      _identifierError = null;
      _passwordError = null;
    });
    context.go(AppRoutes.homePath);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    if (isDesktop) {
      final c = context.colors;
      return AuthDesktopSplitShell(
        maxFormWidth: 420,
        rightChild: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => context.go(AppRoutes.homePath),
                borderRadius: AppRadius.smAll,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.s4,
                    horizontal: AppSpacing.s4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        size: 14,
                        color: c.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Text(
                        'Back to Roadlink',
                        style: AppTypography.caption.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              'Welcome back',
              style: AppTypography.h1Of(context).copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'Log in to continue your Roadlink journey.',
              style: AppTypography.bodySmall.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: AppSpacing.s24),
            _buildFormFields(),
          ],
        ),
      );
    }

    return AuthMobileSheetShell(
      showBackButton: true,
      title: 'Your car world,\nall connected.',
      subtitle: 'Your Roadlink journey continues here.',
      sheetChild: _buildFormFields(),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        RoadlinkTextField(
          label: 'Email or phone number',
          hintText: 'Email or +263 mobile number',
          helperText: 'Use the email or phone number you signed up with.',
          errorText: _identifierError,
          controller: _identifierController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: (_) {
            if (_identifierError != null) {
              setState(() => _identifierError = null);
            }
          },
        ),
        const SizedBox(height: AppSpacing.s16),
        RoadlinkTextField(
          label: 'Password',
          hintText: 'â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢',
          errorText: _passwordError,
          controller: _passwordController,
          obscureText: true,
          textInputAction: TextInputAction.done,
          onChanged: (_) {
            if (_passwordError != null) {
              setState(() => _passwordError = null);
            }
          },
        ),
        const SizedBox(height: AppSpacing.s24),
        RoadlinkButton(
          label: 'Log in',
          variant: RoadlinkButtonVariant.primary,
          expand: true,
          onPressed: _handleSubmit,
        ),
        const SizedBox(height: AppSpacing.s20),
        AuthSwitchPrompt(
          promptText: 'New to Roadlink?',
          actionText: 'Sign up',
          onActionTap: () => context.go(AppRoutes.signupPath),
        ),
      ],
    );
  }
}
