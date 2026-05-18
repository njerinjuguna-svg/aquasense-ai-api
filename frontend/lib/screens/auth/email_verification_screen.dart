import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';

/// Email Verification screen — matches the mockup with:
///   • AquaSense droplet logo (teal circle)
///   • "Email Verification" title + subtitle
///   • Highlighted email address in teal
///   • 5 individual OTP digit boxes
///   • "Verify Email" primary button
///   • "Resend a new code  30s" countdown link
class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  /// One controller per OTP digit box — 5 boxes total.
  final _controllers = List.generate(5, (_) => TextEditingController());

  /// Focus nodes used to advance focus automatically after each digit.
  final _focusNodes = List.generate(5, (_) => FocusNode());

  /// Seconds remaining before "Resend" is allowed again.
  int _secondsLeft = 30;

  /// Whether the resend countdown is still running.
  bool get _canResend => _secondsLeft == 0;

  Timer? _timer;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _startCountdown();
    // Auto-focus the first box when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes)  f.dispose();
    super.dispose();
  }

  // ── Countdown ─────────────────────────────────────────────────────────────

  void _startCountdown() {
    _secondsLeft = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  // ── OTP helpers ───────────────────────────────────────────────────────────

  /// The full 5-digit code assembled from the controllers.
  String get _enteredCode =>
      _controllers.map((c) => c.text).join();

  bool get _isComplete => _enteredCode.length == 5;

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < 4) {
      // Advance to next box
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      // Move back on delete
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _verify() async {
    if (!_isComplete) return;
    final auth    = context.read<AuthProvider>();
    final success = await auth.verifyOtp(_enteredCode);
    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.emailVerified);
    }
  }

  Future<void> _resend() async {
    if (!_canResend) return;
    await context.read<AuthProvider>().resendOtp();
    // Clear boxes and restart countdown
    for (final c in _controllers) c.clear();
    _focusNodes[0].requestFocus();
    setState(() {});
    _startCountdown();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tt   = Theme.of(context).textTheme;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // ── Back button ────────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: _BackButton(onTap: () => Navigator.of(context).pop()),
              ),
              const SizedBox(height: 32),

              // ── AquaSense droplet logo ─────────────────────────────
              const Center(child: _DropletLogo()),
              const SizedBox(height: 28),

              // ── Title ──────────────────────────────────────────────
              Text(
                'Email Verification',
                textAlign: TextAlign.center,
                style:     tt.titleLarge,
              ),
              const SizedBox(height: 10),

              // ── Subtitle ───────────────────────────────────────────
              Text(
                'Please enter the code we sent to your\nemail Address',
                textAlign: TextAlign.center,
                style:     tt.bodyMedium,
              ),
              const SizedBox(height: 14),

              // ── Highlighted email address ──────────────────────────
              Text(
                auth.pendingEmail ?? '',
                textAlign: TextAlign.center,
                style: tt.bodyMedium?.copyWith(
                  color:      AppColors.teal,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),

              // ── OTP boxes ─────────────────────────────────────────
              _OtpRow(
                controllers: _controllers,
                focusNodes:  _focusNodes,
                onChanged:   _onDigitChanged,
              ),
              const SizedBox(height: 10),

              // ── Error message ─────────────────────────────────────
              if (auth.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  child: Text(
                    auth.errorMessage!,
                    textAlign: TextAlign.center,
                    style: tt.bodySmall?.copyWith(color: AppColors.riskHighFg),
                  ),
                ),
              const SizedBox(height: 24),

              // ── Verify Email CTA ──────────────────────────────────
              AppButton(
                label:     'Verify Email',
                enabled:   _isComplete,
                isLoading: auth.status == AuthStatus.loading,
                onPressed: _verify,
              ),
              const SizedBox(height: 24),

              // ── Resend row ────────────────────────────────────────
              _ResendRow(
                secondsLeft: _secondsLeft,
                canResend:   _canResend,
                onResend:    _resend,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Teal circular back button — consistent with the auth flow style.
class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Go back',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40, height: 40,
          decoration: const BoxDecoration(
            color: AppColors.mintLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back,
            color:  AppColors.teal,
            size:   20,
          ),
        ),
      ),
    );  }
}

/// AquaSense teal circle with water-drop icon — mirrors the app logo style.
class _DropletLogo extends StatelessWidget {
  const _DropletLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90, height: 90,
      decoration: const BoxDecoration(
        color: AppColors.teal,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.water_drop_outlined,
        color: AppColors.white,
        size:  40,
      ),
    );
  }
}

/// Row of 5 individual single-digit OTP input boxes.
///
/// Each box:
///   - White background, rounded border
///   - Teal border when focused
///   - Centres one digit
///   - Auto-advances focus to the next box on input
///   - Returns focus to the previous box on backspace
class _OtpRow extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode>             focusNodes;
  final void Function(int index, String value) onChanged;

  const _OtpRow({
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        controllers.length,
        (i) => _OtpBox(
          controller: controllers[i],
          focusNode:  focusNodes[i],
          onChanged:  (v) => onChanged(i, v),
        ),
      ),
    );
  }
}

/// A single OTP digit input box.
class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode             focusNode;
  final ValueChanged<String>  onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  void _onFocusChange() => setState(() {});
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }
  
  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = widget.focusNode.hasFocus;
    final hasText   = widget.controller.text.isNotEmpty;

    return SizedBox(
      width: 56, height: 56,
      child: TextField(
        controller:     widget.controller,
        focusNode:      widget.focusNode,
        textAlign:      TextAlign.center,
        keyboardType:   TextInputType.number,
        maxLength:      1,
        // Suppress the character counter that maxLength shows by default
        buildCounter:   (_, {required currentLength, required isFocused, maxLength}) => null,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: AppColors.textDark,
        ),
        // Restrict to digits only
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          fillColor: AppColors.white,
          filled:    true,
          // Override theme borders for the OTP box specifically
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:   const BorderSide(color: AppColors.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              // Teal border when filled, grey when empty
              color: hasText ? AppColors.teal : AppColors.borderColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:   const BorderSide(color: AppColors.teal, width: 1.5),
          ),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

/// "Resend a new code  30s" row with live countdown.
///
/// When [canResend] is true the countdown is replaced by a teal tappable link.
class _ResendRow extends StatelessWidget {
  final int          secondsLeft;
  final bool         canResend;
  final VoidCallback onResend;

  const _ResendRow({
    required this.secondsLeft,
    required this.canResend,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Resend a new code', style: tt.bodyMedium),
        const SizedBox(width: 6),
        canResend
            ? Semantics(
                button: true,
                label: 'Resend verification code',
                child: GestureDetector(
                  onTap: onResend,
                  child: Text(
                    'Resend',
                    style: tt.bodyMedium?.copyWith(
                      color:      AppColors.teal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )            : Text(
                '${secondsLeft}s',
                style: tt.bodyMedium?.copyWith(
                  color:      AppColors.teal,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ],
    );
  }
}
