import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/auth_footer_link.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/field_label.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

/// Forgot Password screen.
///
/// Layout (top → bottom):
///   • [AuthHeader]       — back button, logo, title, subtitle
///   • Email field
///   • "Reset Password" primary button
///   • [AuthFooterLink]   — "Remember your password? Log in"
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  /// Button enabled only when the email field has content.
  bool get _canSubmit => _emailController.text.isNotEmpty;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _isLoading = true);

    // Simulate API call — replace with real reset logic
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() { _isLoading = false; _sent = true; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password reset link sent to ${_emailController.text.trim()}',
          ),
          backgroundColor: AppColors.teal,
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // ── Logo + title block ─────────────────────────────────
              const AuthHeader(
                title: 'Forgot Password',
                subtitle:
                    'Enter your Email address to retrieve your password',
              ),
              const SizedBox(height: 36),

              // ── Email field (no label in this design) ──────────────
              AppTextField(
                hint: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 28),

              // ── Reset Password CTA ─────────────────────────────────
              AppButton(
                label: 'Reset Password',
                enabled: _canSubmit,
                isLoading: _isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 24),

              // ── Back-to-login link ─────────────────────────────────
              AuthFooterLink(
                prefixText: 'Remember your password?  ',
                linkText: 'Log in',
                onTap: () => Navigator.of(context)
                    .pushReplacementNamed(AppRoutes.signIn),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}