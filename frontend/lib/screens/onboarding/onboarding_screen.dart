import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/constants/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../models/onboarding_model.dart';
import '../../providers/onboarding_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/common/app_skip_button.dart';
import '../../widgets/common/onboarding_illustration.dart';

/// The multi-page onboarding flow.
///
/// Pages 1–3: illustration header + "Skip" button + text + next arrow.
/// Page 4   : full-screen AquaSense logo landing with "Get Started" CTA.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  late final OnboardingProvider _onboardingProvider;

  @override
  void initState() {
    super.initState();
    // Created once here so rebuilds of this widget never reset the page state.
    _onboardingProvider = OnboardingProvider(totalPages: onboardingPages.length);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _onboardingProvider.dispose();
    super.dispose();
  }

  // ── Navigation helpers ──────────────────────────────────────────────────

  /// Jump straight to Create Account, bypassing remaining pages.
  void _handleSkip() {
    Navigator.of(context).pushNamed(AppRoutes.createAccount);
  }

  /// Advance to the next page, or navigate to Create Account on the last page.
  void _next() {
    if (_onboardingProvider.canGoNext()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      // Last page → enter the app
      _handleSkip();
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _onboardingProvider,
      child: Consumer<OnboardingProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: AppColors.white,
            // Swipe to change page; last page shows the logo landing
            body: PageView.builder(
              controller: _pageController,
              onPageChanged: provider.setPage,
              itemCount: onboardingPages.length,
              itemBuilder: (context, index) {
                final page = onboardingPages[index];
                return page.isLast
                    ? _LogoLandingPage(onGetStarted: _handleSkip)
                    : _IllustrationPage(
                        page: page,
                        pageController: _pageController,
                        onSkip: _handleSkip,
                        onNext: _next,
                      );
              },
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page variants
// ─────────────────────────────────────────────────────────────────────────────

/// Pages 1–3: illustration in the upper half, text + nav in the lower half.
class _IllustrationPage extends StatelessWidget {
  final OnboardingPage page;
  final PageController pageController;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  const _IllustrationPage({
    required this.page,
    required this.pageController,
    required this.onSkip,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── "Skip" link (top-right) ────────────────────────────────────
          SkipButton(onTap: onSkip),

          // ── Illustration (upper ~55% of remaining space) ───────────────
          const Expanded(
            flex: 12,
            child: OnboardingIllustration(),
          ),

          // ── Slide text ─────────────────────────────────────────────────
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    page.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    page.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom navigation: dot indicator + next arrow ──────────────
          _BottomNav(
            pageController: pageController,
            totalPages: onboardingPages.length,
            onNext: onNext,
          ),
        ],
      ),
    );
  }
}

/// Page 4 (isLast): centred logo, app name, tagline, "Get Started" button.
/// Matches the final design screen exactly — no illustration, no skip button.
class _LogoLandingPage extends StatelessWidget {
  final VoidCallback onGetStarted;

  const _LogoLandingPage({required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // ── Background blobs (matching the colour scheme) ────────────
          Positioned(
            left: -30,
            top: MediaQuery.of(context).size.height * 0.3,
            child: _LandingBlob(
              size: 90,
              color:  AppColors.mint,
            ),
          ),
          Positioned(
            right: -20,
            bottom: 60,
            child: _LandingBlob(
              size: 80,
              color: const Color(0xFFFCE7F3),
            ),
          ),

          // ── Small scatter dots ───────────────────────────────────────
          const Positioned(
            left: 60,
            top: 220,
            child: _SmallDot(color: Color(0xFF10B981)),
          ),
          const Positioned(
            right: 100,
            top: 260,
            child: _SmallDot(color: Color(0xFF7F1D1D), size: 8),
          ),

          // ── Main content (centred) ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Brand logo circle
                const AppLogo(size: 130),
                const SizedBox(height: 28),

                // App name
                const Text(
                  'AquaSense',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 16),

                // Tagline
                const Text(
                  'Transfer your wastewater data into clear insights, risk alerts, and Ai recommendation',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 40),

                // Primary CTA
                AppButton(
                  label: 'Get Started',
                  onPressed: onGetStarted,
                ),
                const SizedBox(height: 20),

                // Sign-in link
                _SignInLink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Navigation bar (dots + teal arrow)
// ─────────────────────────────────────────────────────────────────────────────

/// Bottom row shown on illustration pages.
/// Left: smooth page indicator dots. Right: teal circular next button.
class _BottomNav extends StatelessWidget {
  final PageController pageController;
  final int totalPages;
  final VoidCallback onNext;

  const _BottomNav({
    required this.pageController,
    required this.totalPages,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Dot indicator ──────────────────────────────────────────
          SmoothPageIndicator(
            controller: pageController,
            // Exclude the last (logo) page from dot count
            count: totalPages - 1,
            effect: ExpandingDotsEffect(
              activeDotColor: AppColors.teal,
              dotColor: AppColors.borderColor,
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 3,
            ),
          ),

          // ── Next arrow button ───────────────────────────────────────
          GestureDetector(
            onTap: onNext,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                // Teal — matches the design (not cyan)
                color: AppColors.teal,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right,
                color: AppColors.white,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small private helpers for the logo landing page
// ─────────────────────────────────────────────────────────────────────────────

/// Circular background blob used on the logo landing page.
class _LandingBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _LandingBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Tiny filled circle scatter dot.
class _SmallDot extends StatelessWidget {
  final Color color;
  final double size;

  const _SmallDot({required this.color, this.size = 10});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// "Already have an account? Sign in" row used on the logo landing page.
class _SignInLink extends StatelessWidget {
  const _SignInLink();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account? ',
          style: TextStyle(color: AppColors.textGrey, fontSize: 14),
        ),
        GestureDetector(
          onTap: () =>
              Navigator.of(context).pushNamed(AppRoutes.signIn),
          child: const Text(
            'Sign in',
            style: TextStyle(
              color: AppColors.teal,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}