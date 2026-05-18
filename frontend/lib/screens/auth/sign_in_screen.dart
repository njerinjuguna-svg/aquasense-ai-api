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

/// Sign In screen.
///
/// Wires the "Remember me" checkbox to [AuthProvider.signIn] so the flag
/// is written to SharedPreferences and honoured on the next cold start.
/// After successful credential validation the provider transitions to
/// [AuthStatus.pendingVerification] and this screen pushes [AppRoutes.emailVerification].
/// If a verified session already exists for this email the provider skips OTP
/// and transitions straight to [AuthStatus.authenticated].
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  /// Whether the user has touched each field (errors shown only after interaction).
  bool _emailTouched    = false;
  bool _passwordTouched = false;

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
    if (_passwordController.text.isEmpty) return 'Password is required';
    return null;
  }

  bool get _formValid =>
      _emailError == null &&
      _passwordError == null &&
      _emailController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty;

  bool get _canSubmit => _formValid;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _submit(AuthProvider auth) async {
    // Mark all fields as touched to surface any remaining errors
    setState(() {
      _emailTouched    = true;
      _passwordTouched = true;
    });

    if (!_canSubmit) return;

    final success = await auth.signIn(
      email:      _emailController.text.trim(),
      password:   _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (!success || !mounted) return;

    if (auth.isPendingVerification) {
      // First time (or expired session) — OTP required
      Navigator.of(context).pushNamed(AppRoutes.emailVerification);
    } else if (auth.isAuthenticated) {
      // Existing verified session — go straight home
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  void _goToForgotPassword() =>
      Navigator.of(context).pushNamed(AppRoutes.forgotPassword);

  void _signInWithGoogle() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google sign-in coming soon')),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

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

                  // ── Logo + title ─────────────────────────────────────
                  AuthHeader(
                    title:    'Welcome back',
                    subtitle: 'Log in to get started on the platform',
                    onBack:   () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 28),

                  // ── Email ─────────────────────────────────────────────
                  const FieldLabel('Email'),
                  const SizedBox(height: 8),
                  AppTextField(
                    hint:         'Enter your email',
                    controller:   _emailController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged:    (_) { if (!_emailTouched) setState(() => _emailTouched = true); },
                  ),
                  _FieldError(message: _emailError),
                  const SizedBox(height: 18),

                  // ── Password ──────────────────────────────────────────
                  const FieldLabel('Password'),
                  const SizedBox(height: 8),
                  AppTextField(
                    hint:       '••••••••',
                    controller: _passwordController,
                    isPassword: true,
                    onChanged:  (_) => setState(() => _passwordTouched = true),
                  ),
                  _FieldError(message: _passwordError),
                  const SizedBox(height: 14),

                  // ── Remember me + Forgot Password ─────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _RememberMeCheckbox(
                        value:     _rememberMe,
                        onChanged: (v) => setState(() => _rememberMe = v),
                      ),
                      GestureDetector(
                        onTap: _goToForgotPassword,
                        child: Text(
                          'Forgot Password?',
                          style: tt.bodySmall?.copyWith(
                            color:      AppColors.teal,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Provider-level error (e.g. wrong credentials) ─────
                  if (auth.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        auth.errorMessage!,
                        textAlign: TextAlign.center,
                        style: tt.bodySmall?.copyWith(
                          color: AppColors.riskHighFg,
                        ),
                      ),
                    ),

                  // ── Login CTA ─────────────────────────────────────────
                  AppButton(
                    label:     'Login',
                    enabled:   _canSubmit,
                    isLoading: auth.status == AuthStatus.loading,
                    onPressed: () => _submit(auth),
                  ),
                  const SizedBox(height: 14),

                  // ── Google sign-in ─────────────────────────────────────
                  GoogleSignInButton(
                    label: 'Sign in with Google',
                    onTap: _signInWithGoogle,
                  ),
                  const SizedBox(height: 24),

                  // ── Create account link ────────────────────────────────
                  AuthFooterLink(
                    prefixText: "Don't have an account?  ",
                    linkText:   'Create One',
                    onTap: () => Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.createAccount),
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
/// Renders a small spacer when [message] is null so layout stays stable.
class _FieldError extends StatelessWidget {
  final String? message;
  const _FieldError({required this.message});

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox(height: 20);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
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
      ),
    );
  }
}
/// "Remember me" checkbox row — local to SignInScreen.
class _RememberMeCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _RememberMeCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Container(
            width: 18, height: 18,
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
          const SizedBox(width: 8),
          Text('Remember me', style: tt.bodySmall),
        ],
      ),
    );
  }
}
