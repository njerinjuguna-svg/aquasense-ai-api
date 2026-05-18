import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

/// Splash screen shown for ~2s on cold start.
///
/// During the animation [AuthProvider.restoreSession] runs.
/// • If a verified session is found in SharedPreferences → go to [AppRoutes.home]
/// • Otherwise → go to [AppRoutes.onboarding] (first run) or [AppRoutes.signIn]
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double>   _fadeAnim;
  late final Animation<double>   _scaleAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();

    _init();
  }

  /// Restore session while the splash animation plays, then navigate.
  Future<void> _init() async {
    // Run session check and minimum display duration in parallel
    final results = await Future.wait([
      context.read<AuthProvider>().restoreSession(),
      Future.delayed(const Duration(milliseconds: 2000)),
    ]);

    if (!mounted) return;

    final hasSession = results[0] as bool;
    Navigator.of(context).pushReplacementNamed(
      hasSession ? AppRoutes.home : AppRoutes.onboarding,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.teal,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo circle
                Container(
                  width: 90, height: 90,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.water_drop_outlined,
                    color: AppColors.teal,
                    size:  40,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'AquaSense',
                  style: TextStyle(
                    color:       AppColors.white,
                    fontSize:    28,
                    fontWeight:  FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
