import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'providers/alert_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/sensor_provider.dart';
import 'repositories/sensor_repository.dart';
import 'screens/ai_chat/ai_chat_screen.dart';
import 'screens/auth/create_account_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/auth/email_verified_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/home/main_shell.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/sensors/ai_advisory_screen.dart';
import 'screens/sensors/sensor_detail_screen.dart';
import 'screens/splash/splash_screen.dart';

void main() => runApp(const AquaSenseApp());

class AquaSenseApp extends StatelessWidget {
  const AquaSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => SensorProvider(MockSensorRepository()),
        ),
        ChangeNotifierProvider(create: (_) => AlertProvider()),
      ],
      child: MaterialApp(
        title:                      'AquaSense',
        debugShowCheckedModeBanner: false,
        theme:                      AppTheme.theme,
        initialRoute:               AppRoutes.splash,
        routes: {
          AppRoutes.splash:            (_) => const SplashScreen(),
          AppRoutes.onboarding:        (_) => const OnboardingScreen(),
          AppRoutes.createAccount:     (_) => const CreateAccountScreen(),
          AppRoutes.signIn:            (_) => const SignInScreen(),
          AppRoutes.forgotPassword:    (_) => const ForgotPasswordScreen(),
          // OTP entry — pushed after createAccount / signIn
          AppRoutes.emailVerification: (_) => const EmailVerificationScreen(),
          // Animated success screen — pushed after OTP is confirmed
          AppRoutes.emailVerified:     (_) => const EmailVerifiedScreen(),
          AppRoutes.home:              (_) => const MainShell(),
          AppRoutes.sensorDetail:      (_) => const SensorDetailScreen(),
          AppRoutes.aiAdvisory:        (_) => const AiAdvisoryScreen(),
          AppRoutes.aiChat:            (_) => const AiChatScreen(),
        },
      ),
    );
  }
}
