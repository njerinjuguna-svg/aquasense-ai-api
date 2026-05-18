/// Represents a single onboarding slide.
/// The [isLast] flag signals the special "Get Started" landing page
/// which renders the logo + CTA instead of the illustration.
class OnboardingPage {
  final String title;
  final String description;
  final bool isLast;

  const OnboardingPage({
    required this.title,
    required this.description,
    this.isLast = false,
  });
}

/// The ordered list of onboarding slides shown to new users.
/// Pages 1–3 show the illustration + "Skip" header.
/// Page 4 (isLast = true) shows the AquaSense logo landing view.
final List<OnboardingPage> onboardingPages = [
  const OnboardingPage(
    title: 'Make sense of your\nwastewater data instantly',    description:
        'Transform complex sensor readings into clear insights, risk levels, and recommended actions you can act on immediately.',
  ),
  const OnboardingPage(
    title: 'Detect waste water risks\nbefore they become violations',
    description:
        'Analyse sensor readings in real time and receive early warnings to prevent harmful discharge and compliance issues.',
  ),
  const OnboardingPage(
    title: 'Compliance & Decision-Making\nFocus',
    description:
        'Monitor key parameters, understand compliance status, and get AI-driven guidance to support confident operational decisions.',
  ),
  const OnboardingPage(
    title: 'AquaSense',
    description:
        'Transform your wastewater data into clear insights, risk alerts, and AI recommendations',    isLast: true,
  ),
];