
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SharedPreferences key constants
// ─────────────────────────────────────────────────────────────────────────────

/// Keys used to read/write values in [SharedPreferences].
/// Centralised here so no screen or widget ever uses raw strings.
class _PrefKeys {
  _PrefKeys._();

  /// JSON string of the persisted [UserModel] (set when rememberMe is true
  /// or when a verified session exists).
  static const userJson   = 'aquasense_user';

  /// Whether the user checked "Remember me" on their last sign-in.
  static const rememberMe = 'aquasense_remember_me';

  /// Whether the current session has been OTP-verified.
  static const verified   = 'aquasense_email_verified';
}

// ─────────────────────────────────────────────────────────────────────────────
// Auth status enum
// ─────────────────────────────────────────────────────────────────────────────

enum AuthStatus {
  /// Cold start — SharedPreferences not yet checked.
  initial,

  /// An async operation (sign-in, sign-up, OTP verify) is in progress.
  loading,

  /// Credentials accepted; awaiting OTP verification.
  pendingVerification,

  /// Fully authenticated and email verified.
  authenticated,

  /// Last operation failed — see [AuthProvider.errorMessage].
  error,
}

// ─────────────────────────────────────────────────────────────────────────────
// AuthProvider
// ─────────────────────────────────────────────────────────────────────────────

/// Manages authentication state and persists sessions via [SharedPreferences].
///
/// Flow for new accounts:
///   createAccount() → status = pendingVerification
///   verifyOtp()     → status = authenticated, prefs written
///
/// Flow for returning users:
///   signIn()        → status = pendingVerification (or authenticated if
///                     rememberMe was set and session is still valid)
///   verifyOtp()     → status = authenticated
///
/// Cold-start auto-login:
///   restoreSession() reads prefs on app boot. If a verified user JSON is
///   found and isEmailVerified == true, status jumps to authenticated so
///   [SplashScreen] can route directly to [MainShell].
class AuthProvider extends ChangeNotifier {
  AuthStatus _status       = AuthStatus.initial;
  UserModel? _user;
  String?    _errorMessage;

  /// The 6-character OTP sent to the user's email (mock — shown in console).
  String?    _pendingOtp;

  /// The email address that is awaiting OTP entry.
  String?    _pendingEmail;

  // ── Getters ────────────────────────────────────────────────────────────

  AuthStatus get status       => _status;
  UserModel? get user         => _user;
  String?    get errorMessage => _errorMessage;
  String?    get pendingEmail => _pendingEmail;
  bool get isAuthenticated    => _status == AuthStatus.authenticated;
  bool get isPendingVerification =>
      _status == AuthStatus.pendingVerification;

  // ── Session restore (called from SplashScreen) ─────────────────────────

  /// Checks SharedPreferences on cold start.
  ///
  /// If a verified session is found the status jumps to [AuthStatus.authenticated]
  /// so [SplashScreen] can navigate straight to [MainShell].
  /// If nothing is stored it falls through to onboarding / sign-in.
  Future<bool> restoreSession() async {
    final prefs    = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_PrefKeys.userJson);

    if (userJson == null) return false;

    try {
      final user = UserModel.fromJsonString(userJson);
      if (user.isEmailVerified) {
        _user   = user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
    } catch (_) {
      // Corrupted prefs — clear and start fresh
      // Avoid clearing all SharedPreferences on corrupted auth data.
      await prefs.remove(_PrefKeys.userJson);
      await prefs.remove(_PrefKeys.verified);
      await prefs.remove(_PrefKeys.rememberMe);
    }
    return false;
  }

  // ── Create account ─────────────────────────────────────────────────────

  /// Validates inputs, stores a pending user, and generates a mock OTP.
  ///
  /// On success the status becomes [AuthStatus.pendingVerification] and the
  /// caller should push [AppRoutes.emailVerification].
  Future<bool> createAccount({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      _setError('Please fill in all fields');
      return false;
    }
    if (password.length < 6) {
      _setError('Password must be at least 6 characters');
      return false;
    }

    _status       = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800)); // simulate API

    _pendingEmail = email.trim();
    _pendingOtp   = _generateOtp();

    // In production: call your backend to send the OTP email.
    // Here we log it so the developer can test without a real email server.
    debugPrint('AquaSense OTP for $email: $_pendingOtp');

    // Persist a non-verified session so it survives hot-restart during testing
    final prefs = await SharedPreferences.getInstance();
    final draft = UserModel(email: email.trim(), isEmailVerified: false);
    await prefs.setString(_PrefKeys.userJson, draft.toJsonString());
    await prefs.setBool(_PrefKeys.verified, false);

    _user   = draft;
    _status = AuthStatus.pendingVerification;
    notifyListeners();
    return true;
  }

  // ── Sign in ────────────────────────────────────────────────────────────

  /// Validates credentials and, if rememberMe was previously set, restores
  /// the session without requiring a new OTP (simulating a valid JWT).
  ///
  /// Otherwise transitions to [AuthStatus.pendingVerification] for OTP entry.
  Future<bool> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      _setError('Please fill in all fields');
      return false;
    }

    _status       = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final prefs = await SharedPreferences.getInstance();

    // Check if this user already has a verified session stored
    final storedJson = prefs.getString(_PrefKeys.userJson);
    final wasVerified = prefs.getBool(_PrefKeys.verified) ?? false;

    if (storedJson != null && wasVerified) {
      try {
        final stored = UserModel.fromJsonString(storedJson);
        if (stored.email.toLowerCase() == email.trim().toLowerCase() && stored.isEmailVerified) {          // Session is still valid — skip OTP
          _user   = stored.copyWith(rememberMe: rememberMe);
          _status = AuthStatus.authenticated;

          if (rememberMe) {
            await prefs.setString(_PrefKeys.userJson, _user!.toJsonString());
            await prefs.setBool(_PrefKeys.rememberMe, true);
          }

          notifyListeners();
          return true;
        }
      } catch (_) { /* fall through to OTP */ }
    }

    // New sign-in or expired session — require OTP
    _pendingEmail = email.trim();
    _pendingOtp   = _generateOtp();
    debugPrint('AquaSense OTP for $email: $_pendingOtp');

    await prefs.setString(
      _PrefKeys.userJson,
      UserModel(email: email.trim(), isEmailVerified: false).toJsonString(),
    );
    await prefs.setBool(_PrefKeys.verified, false);
    await prefs.setBool(_PrefKeys.rememberMe, rememberMe);
    _user   = UserModel(email: email.trim(), isEmailVerified: false);
    _status = AuthStatus.pendingVerification;
    notifyListeners();
    return true;
  }

  // ── OTP verification ───────────────────────────────────────────────────

  /// Compares [enteredCode] against the generated OTP.
  ///
  /// On match: marks the user as verified, writes to SharedPreferences,
  /// and transitions to [AuthStatus.authenticated].
  /// On mismatch: sets an error and returns false.
  Future<bool> verifyOtp(String enteredCode) async {
    _status       = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    if (_pendingOtp == null || enteredCode.trim() != _pendingOtp) {
      _setError('Invalid code. Please try again.');
      return false;
    }

    // Mark as verified
    final verified = (_user ?? UserModel(email: _pendingEmail ?? ''))
        .copyWith(isEmailVerified: true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_PrefKeys.userJson, verified.toJsonString());
    await prefs.setBool(_PrefKeys.verified, true);

    _user         = verified;
    _pendingOtp   = null;
    _pendingEmail = null;
    _status       = AuthStatus.authenticated;
    notifyListeners();
    return true;
  }

  // ── Resend OTP ─────────────────────────────────────────────────────────

  /// Generates a new OTP and resets the countdown in the UI.
  /// Call this when the user taps "Resend a new code".
  Future<void> resendOtp() async {
    _pendingOtp = _generateOtp();
    debugPrint('AquaSense new OTP for $_pendingEmail: $_pendingOtp');
    notifyListeners();
  }

  // ── Sign out ───────────────────────────────────────────────────────────

  /// Clears the session from SharedPreferences and resets state.
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_PrefKeys.userJson);
    await prefs.remove(_PrefKeys.verified);
    await prefs.remove(_PrefKeys.rememberMe);

    _user         = null;
    _pendingOtp   = null;
    _pendingEmail = null;
    _status       = AuthStatus.initial;
    notifyListeners();
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status       = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  /// Generates a random 5-digit numeric OTP.
  String _generateOtp() {
    final rng = Random.secure();
    return List.generate(5, (_) => rng.nextInt(10)).join();
  }
}