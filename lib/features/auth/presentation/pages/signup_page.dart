import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roadlink/app/router/app_router.dart';
import 'package:roadlink/app/theme/app_theme.dart';
import 'package:roadlink/core/utils/responsive.dart';
import 'package:roadlink/features/auth/presentation/widgets/auth_brand_shell.dart';
import 'package:roadlink/shared/widgets/roadlink_button.dart';
import 'package:roadlink/shared/widgets/roadlink_text_field.dart';

/// Roadlink Sign Up screen matching Figma screens 2 (Mobile) and 6 (Desktop):
/// - Desktop: 50/50 split with [DesktopBrandGradientPanel] on the left and
///   `Create your account`, `Join for car services, marketplace finds, and community.`,
///   2-column `First name` / `Last name`, full-width `Email`, 2-column
///   `Password` / `Confirm password`, full-width `Phone number` (`+263 | 7X XXX XXXX`),
///   primary `Sign up` button, and `Already have an account? Log in`.
/// - Mobile: [AuthMobileSheetShell] with `RoadlinkLogo`, `Create your account`,
///   `Car services, shopping, and community.` above a rounded white sheet
///   stacking `First name`, `Last name`, `Email`, `Phone number`, `Password`,
///   `Confirm password`, `Sign up`, and `Already have an account? Log in`.
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _firstNameError = firstName.isEmpty ? 'Enter your first name.' : null;
      _lastNameError = lastName.isEmpty ? 'Enter your last name.' : null;
      _emailError = (!email.contains('@') || !email.contains('.'))
          ? 'Enter a valid email address.'
          : null;
      _phoneError =
          phone.length < 7 ? 'Enter a valid Zimbabwe mobile number.' : null;
      _passwordError =
          password.length < 8 ? 'Use at least 8 characters.' : null;
      _confirmPasswordError =
          confirmPassword != password ? 'Passwords do not match.' : null;
    });

    if (_firstNameError == null &&
        _lastNameError == null &&
        _emailError == null &&
        _phoneError == null &&
        _passwordError == null &&
        _confirmPasswordError == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created! Welcome to Roadlink.'),
        ),
      );
      context.go(AppRoutes.homePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    if (isDesktop) {
      final c = context.colors;
      return AuthDesktopSplitShell(
        maxFormWidth: 460,
        rightChild: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create your account',
              style: AppTypography.h1Of(context).copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'Join for car services, marketplace finds, and community.',
              style: AppTypography.bodySmall.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: AppSpacing.s24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildFirstNameField()),
                const SizedBox(width: AppSpacing.s16),
                Expanded(child: _buildLastNameField()),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),
            _buildEmailField(),
            const SizedBox(height: AppSpacing.s16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildPasswordField(hint: 'â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢')),
                const SizedBox(width: AppSpacing.s16),
                Expanded(child: _buildConfirmPasswordField(hint: 'â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢')),
              ],
            ),
            const SizedBox(height: AppSpacing.s16),
            _buildPhoneField(),
            const SizedBox(height: AppSpacing.s24),
            _buildSubmitAndSwitch(),
          ],
        ),
      );
    }

    return AuthMobileSheetShell(
      title: 'Create your account',
      subtitle: 'Car services, shopping, and community.',
      sheetChild: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFirstNameField(),
          const SizedBox(height: AppSpacing.s16),
          _buildLastNameField(),
          const SizedBox(height: AppSpacing.s16),
          _buildEmailField(),
          const SizedBox(height: AppSpacing.s16),
          _buildPhoneField(),
          const SizedBox(height: AppSpacing.s16),
          _buildPasswordField(hint: 'â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢'),
          const SizedBox(height: AppSpacing.s16),
          _buildConfirmPasswordField(hint: 'â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢'),
          const SizedBox(height: AppSpacing.s24),
          _buildSubmitAndSwitch(),
        ],
      ),
    );
  }

  Widget _buildFirstNameField() {
    return RoadlinkTextField(
      label: 'First name',
      hintText: 'Enter your first name',
      errorText: _firstNameError,
      controller: _firstNameController,
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      onChanged: (_) {
        if (_firstNameError != null) {
          setState(() => _firstNameError = null);
        }
      },
    );
  }

  Widget _buildLastNameField() {
    return RoadlinkTextField(
      label: 'Last name',
      hintText: 'Enter your last name',
      errorText: _lastNameError,
      controller: _lastNameController,
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      onChanged: (_) {
        if (_lastNameError != null) {
          setState(() => _lastNameError = null);
        }
      },
    );
  }

  Widget _buildEmailField() {
    return RoadlinkTextField(
      label: 'Email',
      hintText: 'name@example.com',
      errorText: _emailError,
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onChanged: (_) {
        if (_emailError != null) {
          setState(() => _emailError = null);
        }
      },
    );
  }

  Widget _buildPhoneField() {
    return RoadlinkTextField(
      label: 'Phone number',
      hintText: '7X XXX XXXX',
      helperText: 'Use your Zimbabwe mobile number.',
      errorText: _phoneError,
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      prefixIcon: const ZimbabwePhonePrefix(),
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      onChanged: (_) {
        if (_phoneError != null) {
          setState(() => _phoneError = null);
        }
      },
    );
  }

  Widget _buildPasswordField({required String hint}) {
    return RoadlinkTextField(
      label: 'Password',
      hintText: hint,
      errorText: _passwordError,
      controller: _passwordController,
      obscureText: true,
      textInputAction: TextInputAction.next,
      onChanged: (_) {
        if (_passwordError != null) {
          setState(() => _passwordError = null);
        }
      },
    );
  }

  Widget _buildConfirmPasswordField({required String hint}) {
    return RoadlinkTextField(
      label: 'Confirm password',
      hintText: hint,
      errorText: _confirmPasswordError,
      controller: _confirmPasswordController,
      obscureText: true,
      textInputAction: TextInputAction.done,
      onChanged: (_) {
        if (_confirmPasswordError != null) {
          setState(() => _confirmPasswordError = null);
        }
      },
    );
  }

  Widget _buildSubmitAndSwitch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RoadlinkButton(
          label: 'Sign up',
          variant: RoadlinkButtonVariant.primary,
          expand: true,
          onPressed: _handleSubmit,
        ),
        const SizedBox(height: AppSpacing.s20),
        AuthSwitchPrompt(
          promptText: 'Already have an account?',
          actionText: 'Log in',
          onActionTap: () => context.go(AppRoutes.loginPath),
        ),
      ],
    );
  }
}
