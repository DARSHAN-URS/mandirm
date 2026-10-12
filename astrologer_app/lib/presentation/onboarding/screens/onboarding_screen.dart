import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/auth/auth_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../common/widgets/app_image.dart';
import '../../home/screens/main_hub_screen.dart';

class AstrologerOnboardingScreen extends StatefulWidget {
  final bool isTourMode;

  const AstrologerOnboardingScreen({
    super.key,
    this.isTourMode = false,
  });

  @override
  State<AstrologerOnboardingScreen> createState() => _AstrologerOnboardingScreenState();
}

class _AstrologerOnboardingScreenState extends State<AstrologerOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlideData> _slides = [
    OnboardingSlideData(
      badge: '॥ मार्गदर्शन व सेवा ॥',
      title: 'Connect with Devotees Across Bharat & Worldwide',
      subtitle: 'Provide authentic Vedic Kundli readings, birth chart matching, and sacred remedies to seekers looking for wisdom and spiritual peace.',
      icon: Icons.auto_awesome,
      cardColor: const Color(0xFF6B1D2F),
      highlights: [
        'Instant consultation alerts for Kundli & Horoscopes',
        'Automatic Janam Kundli & Guna Milan calculations',
        'Birth details & problem topic preview prior to calls',
      ],
      artAsset: AppConstants.astroHeroBannerAsset,
    ),
    OnboardingSlideData(
      badge: '॥ वैदिक संवाद ॥',
      title: 'High-Definition Audio, Video & Secure Chat',
      subtitle: 'Conduct private, 1-on-1 consultations directly from your phone. Built-in per-minute call timer ensures crystal-clear Dakshina accounting.',
      icon: Icons.videocam_rounded,
      cardColor: const Color(0xFF4A154B),
      highlights: [
        'Ultra low-latency video & crystal-clear voice calls',
        'Real-time per-minute Dakshina meter during the session',
        'Prescribe sacred Vedic remedies, Pujas & Gemstones',
      ],
      artAsset: AppConstants.astroBannerArt,
    ),
    OnboardingSlideData(
      badge: '॥ स्वायत्तता व सम्मान ॥',
      title: 'Instant Payouts & Total Schedule Autonomy',
      subtitle: 'Set your own consultation rates per minute. Withdraw your earned Dakshina straight into your verified bank account or UPI with zero delays.',
      icon: Icons.account_balance_wallet_rounded,
      cardColor: const Color(0xFF1E3A2F),
      highlights: [
        'Instant same-day settlements to Bank Account or UPI',
        'Toggle duty anytime: Online, Busy, or Offline',
        '100% verified devotee reviews & certified Acharya badge',
      ],
      artAsset: AppConstants.astroFeatureGraphic,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onFinishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyHasSeenOnboarding, true);

    if (!mounted) return;

    if (widget.isTourMode) {
      Navigator.pop(context);
    } else {
      if (AuthService().isAuthenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AstrologerMainHubScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AstrologerLoginScreen()),
        );
      }
    }
  }

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _onFinishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar with Branding & Skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.warmCream,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.marigoldGold.withOpacity(0.5)),
                    ),
                    child: Image.asset(
                      AppConstants.flameLogoAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.brightness_7,
                        color: AppColors.primaryMaroon,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MANDIRM',
                        style: TextStyle(fontFamily: 'Headway', 
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                          color: AppColors.primaryMaroon,
                        ),
                      ),
                      Text(
                        'Acharya Onboarding Guide',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _onFinishOnboarding,
                    child: Text(
                      widget.isTourMode ? 'Close' : 'Skip',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryMaroon,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page View with Slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return _buildSlideCard(slide);
                },
              ),
            ),

            // Bottom Navigation & Controls
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                children: [
                  // Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (i) {
                      final isActive = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primaryMaroon : AppColors.lightBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 18),

                  // Action Buttons
                  Row(
                    children: [
                      if (_currentPage > 0) ...[
                        OutlinedButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.lightBorder),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryMaroon,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentPage == _slides.length - 1
                                    ? (widget.isTourMode ? 'Return to Profile' : 'Enter Acharya Portal')
                                    : 'Continue',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentPage == _slides.length - 1
                                    ? Icons.check_circle_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideCard(OnboardingSlideData slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.lightBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Hero Image Card with Vedic Gradient Overlay
            Container(
              height: 180,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppImage.network(
                      AppConstants.cdnUrl(slide.artAsset),
                      fallbackAsset: AppConstants.splashBackgroundAsset,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            slide.cardColor.withOpacity(0.35),
                            slide.cardColor.withOpacity(0.85),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 14,
                      left: 16,
                      right: 16,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.marigoldGold, width: 1.5),
                            ),
                            child: Icon(slide.icon, color: const Color(0xFFFFD54F), size: 22),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  slide.badge,
                                  style: TextStyle(fontFamily: 'Headway', 
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFFFD54F),
                                  ),
                                ),
                                Text(
                                  'Mandirm Acharya Platform',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slide.title,
                      style: TextStyle(fontFamily: 'Headway', 
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      slide.subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: AppColors.lightBorder, height: 1),
                    const SizedBox(height: 12),

                    // Feature Highlight Bullets
                    ...slide.highlights.map((h) => Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: AppColors.warmCream,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  size: 13,
                                  color: AppColors.primaryMaroon,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  h,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingSlideData {
  final String badge;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color cardColor;
  final List<String> highlights;
  final String artAsset;

  OnboardingSlideData({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.cardColor,
    required this.highlights,
    required this.artAsset,
  });
}
