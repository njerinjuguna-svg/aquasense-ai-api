

class AppRoutes {
  AppRoutes._(); // non-instantiable
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const createAccount = '/create-account';
  static const signIn = '/sign-in';
  static const forgotPassword = '/forgot-password';
   /// OTP code entry — shown after sign-up or sign-in for new sessions.
  static const emailVerification  = '/email-verification';
  /// Animated success screen — shown after OTP is confirmed.
  static const emailVerified      = '/email-verified';
  static const home = '/home';
  static const sensorDetail   = '/sensor-detail';
  static const aiAdvisory     = '/ai-advisory';   // static advisory (no chat)
  static const aiChat         = '/ai-chat'; 
}
