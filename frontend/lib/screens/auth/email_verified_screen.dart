import 'package:flutter/material.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/app_back_button.dart';
import '../../widgets/common/app_button.dart';

class EmailVerifiedScreen extends StatefulWidget {
  const EmailVerifiedScreen({super.key});

  @override
  State<EmailVerifiedScreen> createState() => _EmailVerifiedScreenState();
}

class _EmailVerifiedScreenState extends State<EmailVerifiedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const AppBackButton(),
              Expanded(
                child: Center(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const _SuccessIcon(),
                          const SizedBox(height: 28),
                          const Text(
                            'Successful',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Your email verification is successful',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textGrey,
                            ),
                          ),
                          const SizedBox(height: 40),
                          AppButton(
                            label: 'Continue',
                            onPressed: () => Navigator.of(context)
                                .pushReplacementNamed(AppRoutes.home),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessIcon extends StatelessWidget {
  const _SuccessIcon();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.mint.withValues(alpha: .3),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: AppColors.teal,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: AppColors.white,
            size: 36,
          ),
        ),
      ),
    );
  }
}