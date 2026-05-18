import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/auth_footer_link.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/field_label.dart';
import '../../widgets/auth/google_sign_in_button.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

/// Create Account screen.
///
/// Layout (top → bottom):
///   • [AuthHeader]           — back button, logo, title, subtitle
///   • Email / Password / Confirm Password fields with [FieldLabel]s
///   • Inline validation error messages per field
///   • [_TermsCheckbox]       — "I agree to terms of service and privacy policy"
///   • "Create Account" primary button
///   • [GoogleSignInButton]   — "Sign up with Google"
///   • [AuthFooterLink]       — "Already have an account? Sign in"
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _emailController           = TextEditingController();
  final _passwordController        = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _agreedToTerms = false;

  /// Whether the user has touched each field (used to show errors only after
  /// the user has interacted with a field, not on first render).
  bool _emailTouched           = false;
  bool _passwordTouched        = false;
  bool _confirmPasswordTouched = false;

  // ── Validation helpers ────────────────────────────────────────────────────

  static final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+(?:\.[\w-]+)*\.[a-zA-Z]{2,}$');

  String? get _emailError {
    if (!_emailTouched) return null;
    final v = _emailController.text.trim();
    if (v.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  String? get _passwordError {
    if (!_passwordTouched) return null;
    final v = _passwordController.text;
    if (v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? get _confirmPasswordError {
    if (!_confirmPasswordTouched) return null;
    final v = _confirmPasswordController.text;
    if (v.isEmpty) return 'Please confirm your password';
    if (v != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  bool get _formValid =>
      _emailError == null &&
      _passwordError == null &&
      _confirmPasswordError == null &&
      _emailController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      _confirmPasswordController.text.isNotEmpty;

  /// Primary CTA enabled only when form is valid + terms accepted.
  bool get _canSubmit => _formValid && _agreedToTerms;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _submit(AuthProvider auth) async {
    // Mark all fields as touched to surface any remaining errors
    setState(() {
      _emailTouched           = true;
      _passwordTouched        = true;
      _confirmPasswordTouched = true;
    });

    if (!_canSubmit) return;

    final success = await auth.createAccount(
      email:    _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (success && mounted) {
      Navigator.of(context).pushNamed(AppRoutes.emailVerification);
    }
  }

  /// Placeholder — wire up google_sign_in package when ready.
  void _signUpWithGoogle() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google sign-up coming soon')),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // ── Logo + title block ───────────────────────────────
                  AuthHeader(
                    title: 'Create Account',
                    subtitle: 'Sign up to get started on the platform',
                    onBack: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context)
                            .pushReplacementNamed(AppRoutes.onboarding);
                      }
                    },
                  ),
                  const SizedBox(height: 28),

                  // ── Email ────────────────────────────────────────────
                  const FieldLabel('Email'),
                  const SizedBox(height: 8),
                  AppTextField(
                    hint:         'Enter your email',
                    controller:   _emailController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => setState(() => _emailTouched = true),
                  ),
                  _FieldError(message: _emailError),
                  const SizedBox(height: 18),

                  // ── Password ─────────────────────────────────────────
                  const FieldLabel('Password'),
                  const SizedBox(height: 8),
                  AppTextField(
                    hint:       '••••••••',
                    controller: _passwordController,
                    isPassword: true,
                    onChanged: (_) => setState(() {
                      _passwordTouched = true;
                      // Re-validate confirm field live when password changes
                      // if (_confirmPasswordTouched) {}
                    }),
                  ),
                  _FieldError(message: _passwordError),
                  const SizedBox(height: 18),

                  // ── Confirm Password ─────────────────────────────────
                  const FieldLabel('Confirm Password'),
                  const SizedBox(height: 8),
                  AppTextField(
                    hint:       '••••••••',
                    controller: _confirmPasswordController,
                    isPassword: true,
                    onChanged: (_) =>
                        setState(() => _confirmPasswordTouched = true),
                  ),
                  _FieldError(message: _confirmPasswordError),
                  const SizedBox(height: 16),

                  // ── Terms checkbox ───────────────────────────────────
                  _TermsCheckbox(
                    value:     _agreedToTerms,
                    onChanged: (val) => setState(() => _agreedToTerms = val),
                  ),
                  const SizedBox(height: 24),

                  // ── Provider-level error (e.g. email already in use) ─
                  if (auth.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        auth.errorMessage!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.riskHighFg,
                        ),
                      ),
                    ),

                  // ── Primary CTA ──────────────────────────────────────
                  AppButton(
                    label:     'Create Account',
                    enabled:   _canSubmit,
                    isLoading: auth.status == AuthStatus.loading,
                    onPressed: () => _submit(auth),
                  ),
                  const SizedBox(height: 14),

                  // ── Google sign-up ───────────────────────────────────
                  GoogleSignInButton(
                    label: 'Sign up with Google',
                    onTap: _signUpWithGoogle,
                  ),
                  const SizedBox(height: 24),

                  // ── Sign-in link ─────────────────────────────────────
                  AuthFooterLink(
                    prefixText: 'Already have an account?  ',
                    linkText:   'Sign in',
                    onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.signIn,
                      ModalRoute.withName(AppRoutes.onboarding),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Displays an inline validation error below a field.
/// Renders nothing when [message] is null, so spacing stays consistent.
class _FieldError extends StatelessWidget {
  final String? message;
  const _FieldError({required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24, // Reserve consistent height
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (message != null) ...[
            const Icon(Icons.error_outline, size: 14, color: AppColors.riskHighFg),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                message!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.riskHighFg,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  } 
   }


/// "I agree to the terms of service and privacy policy" checkbox row.
/// Only used on Create Account so kept private to this file.
class _TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _TermsCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Custom teal checkbox
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: value
                  ? AppColors.teal.withValues(alpha: 0.12)
                  : AppColors.white,
              border: Border.all(
                color: value ? AppColors.teal : AppColors.borderColor,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: value
                ? const Icon(Icons.check, size: 12, color: AppColors.teal)
                : null,
          ),
          const SizedBox(width: 10),

          // "I agree to the terms of service and privacy policy"
          Text.rich(
            TextSpan(
              text: 'I agree to the ',
              style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
              children: [
                TextSpan(
                  text: 'terms of service',
                  style: const TextStyle(
                    color:      AppColors.teal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'privacy policy',
                  style: const TextStyle(
                    color:      AppColors.teal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
