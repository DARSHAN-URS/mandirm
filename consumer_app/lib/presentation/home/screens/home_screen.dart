import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/l10n/locale_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/supabase_service.dart';
import '../../astrologers/screens/astrologers_screen.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../bookings/screens/bookings_screen.dart';
import '../../chadhawa/screens/chadhawa_screen.dart';
import '../../consultations/screens/consultations_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../puja/screens/pujas_screen.dart';
import '../../shop/screens/store_screen.dart';
import '../../temples/screens/temples_screen.dart';
import '../widgets/global_search_dialog.dart';
import '../../common/widgets/mandirm_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;
  String? _selectedMandirFilter;

  void _openGlobalSearch() {
    showDialog(
      context: context,
      builder: (ctx) => GlobalSearchDialog(
        onSelect: (tabIndex, filter) {
          setState(() {
            _currentTabIndex = tabIndex;
            _selectedMandirFilter = filter;
          });
        },
      ),
    );
  }

  void _openBookings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingsScreen(
          onBrowsePujas: () {
            Navigator.pop(context);
            setState(() => _currentTabIndex = 1);
          },
        ),
      ),
    );
  }

  void _openConsultations() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConsultationsScreen(
          onBrowseAstrologers: () {
            Navigator.pop(context);
            setState(() => _currentTabIndex = 2);
          },
        ),
      ),
    );
  }

  void _openProfileScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }


  void _openQrScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildQrScannerSheet(ctx),
    );
  }

  Widget _buildQrScannerSheet(BuildContext ctx) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1B0B0E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(60),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('📸', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    'Sanctum QR Scanner',
                    style: GoogleFonts.cinzel(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFFF6E5),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Point at official Mandirm QR code placed at temple garbhagriha or select a temple below to enter live darshan instantly.',
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              color: Colors.white.withAlpha(180),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Scanner viewfinder frame
          Container(
            width: 220,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(120),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Corner guides
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xFFF59E0B), width: 3),
                        left: BorderSide(color: Color(0xFFF59E0B), width: 3),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xFFF59E0B), width: 3),
                        right: BorderSide(color: Color(0xFFF59E0B), width: 3),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFF59E0B), width: 3),
                        left: BorderSide(color: Color(0xFFF59E0B), width: 3),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFF59E0B), width: 3),
                        right: BorderSide(color: Color(0xFFF59E0B), width: 3),
                      ),
                    ),
                  ),
                ),
                // Center scanning animation visual
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Color(0xFFF59E0B),
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7A0C16).withAlpha(200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Align Temple QR in Box',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFFF6E5),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Instant Sanctum Simulation Chips
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Or Tap to Connect to Sanctum:',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFF59E0B),
              ),
            ),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQrSanctumChip(
                ctx,
                '🔱 Kashi Vishwanath',
                'Kashi Vishwanath Mandir',
              ),
              _buildQrSanctumChip(
                ctx,
                '🕉️ Mahakaleshwar Ujjain',
                'Mahakaleshwar Jyotirlinga',
              ),
              _buildQrSanctumChip(
                ctx,
                '🪷 Tirupati Balaji',
                'Tirupati Balaji Mandir',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQrSanctumChip(BuildContext ctx, String label, String mandirName) {
    return InkWell(
      onTap: () {
        Navigator.pop(ctx);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TemplesScreen(
              onBookPuja: (mandir) {
                Navigator.pop(context);
                setState(() {
                  _selectedMandirFilter = mandir;
                  _currentTabIndex = 1;
                });
              },
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(22),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD4AF37).withAlpha(120)),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFFFF6E5),
          ),
        ),
      ),
    );
  }

  void _openPanchangDetails() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Today\'s Vedic Panchang ✨',
              style: GoogleFonts.cinzel(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _buildPanchangRow('Tithi', 'Shukla Navami (ends 06:45 PM)'),
            _buildPanchangRow(
                'Nakshatra', 'Pushya Nakshatra (Supreme Auspicious)'),
            _buildPanchangRow('Yoga', 'Siddhi Yoga'),
            _buildPanchangRow(
                'Abhijit Muhurat', '11:45 AM - 12:35 PM (Best for Pujas)'),
            _buildPanchangRow(
                'Rahu Kaal', '04:30 PM - 06:00 PM (Inauspicious)'),
            _buildPanchangRow('Sunrise / Sunset', '06:12 AM / 06:28 PM'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7A0C16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() => _currentTabIndex = 1);
                },
                child: const Text('Book Puja in Auspicious Muhurat',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanchangRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: Colors.grey.shade700)),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go('/login');
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFFBF9F5),
          body: IndexedStack(
            index: _currentTabIndex,
            children: [
              // Tab 0: Home Tab matching design
              _buildHomeTab(),

              // Tab 1: Vedic Pujas
              PujasScreen(
                initialMandirFilter: _selectedMandirFilter,
                onBookingSuccess: () {
                  _openBookings();
                },
              ),

              // Tab 2: Certified Astrologers
              AstrologersScreen(
                onConsultationFinished: () {
                  _openConsultations();
                },
              ),

              // Tab 3: Sacred Chadhawa & Offerings
              ChadhawaScreen(
                onBrowsePujas: () {
                  setState(() => _currentTabIndex = 1);
                },
              ),

              // Tab 4: Mandirm Divine Store
              StoreScreen(
                onBrowsePujas: () {
                  setState(() => _currentTabIndex = 1);
                },
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentTabIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentTabIndex = index;
                if (index != 1) _selectedMandirFilter = null;
              });
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home_rounded, color: AppColors.saffronPrimary),
                label: AppStrings.t('home'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.spa_outlined),
                selectedIcon: const Icon(Icons.spa_rounded, color: AppColors.saffronPrimary),
                label: AppStrings.t('pujas'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.brightness_7_outlined),
                selectedIcon: const Icon(Icons.brightness_7_rounded, color: AppColors.sacredCrimson),
                label: AppStrings.t('astrology'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.volunteer_activism_outlined),
                selectedIcon: const Icon(Icons.volunteer_activism_rounded, color: AppColors.sacredCrimson),
                label: AppStrings.t('chadhawa'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.shopping_cart_outlined),
                selectedIcon: const Icon(Icons.shopping_cart_rounded, color: AppColors.saffronPrimary),
                label: AppStrings.t('puja_store'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Main Devotional Home Tab View
  Widget _buildHomeTab() {
    final user = SupabaseService().currentUser;
    final userName = user?.userMetadata?['full_name'] as String? ??
        user?.userMetadata?['name'] as String?;
    final userAvatar = user?.userMetadata?['avatar_url'] as String? ??
        user?.userMetadata?['picture'] as String?;
    final isLoggedIn = user != null;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Unified Mandirm Header (same header across entire app)
          MandirmHeader(
            trailing: _buildQrButton(),
          ),

          // 2. Devotional Greeting & Profile Banner
          _buildGreetingBanner(isLoggedIn, userName, userAvatar),

          const SizedBox(height: 12),

          // 3. Floating Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSearchBar(),
          ),

          const SizedBox(height: 16),

          // 3. Featured Card 1: Pooja Booking (पूजा बुकिंग)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildPoojaBookingCard(),
          ),

          const SizedBox(height: 16),

          // 4. Featured Card 2: Talk to Astrologer (ज्योतिषी से बात करें)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildAstrologerCard(),
          ),

          const SizedBox(height: 20),

          // 5. Panchang Banner
          GestureDetector(
            onTap: _openPanchangDetails,
            child: _buildPanchangCard(),
          ),

          const SizedBox(height: 24),

          // 6. Sacred Mandirs Section
          _buildSectionHeader(AppStrings.t('sacred_mandirs'), AppStrings.t('view_all_108'), () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TemplesScreen(
                  onBookPuja: (mandir) {
                    Navigator.pop(context);
                    setState(() {
                      _selectedMandirFilter = mandir;
                      _currentTabIndex = 1;
                    });
                  },
                ),
              ),
            );
          }),
          _buildMandirsHorizontalList(),

          const SizedBox(height: 24),

          // 7. Upcoming Special Pujas
          _buildSectionHeader(AppStrings.t('live_special_pujas'), AppStrings.t('explore'), () {
            setState(() => _currentTabIndex = 1);
          }),
          _buildPujaCards(),
        ],
      ),
    );
  }

  /// QR Code Scanner Action Button for Header
  Widget _buildQrButton() {
    return InkWell(
      onTap: _openQrScanner,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFDECDB4),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.qr_code_scanner_rounded,
            color: Color(0xFF7A0C16),
            size: 19,
          ),
        ),
      ),
    );
  }

  /// Devotional Greeting & Profile Banner
  Widget _buildGreetingBanner(bool isLoggedIn, String? userName, String? userAvatar) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      height: 82,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Temple background artwork
            Image.asset(
              AppConstants.homeHeaderAsset,
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFEAA031), Color(0xFF8B2510)],
                  ),
                ),
              ),
            ),

            // Soft warm gradient overlay for crisp text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFFFFF9ED).withValues(alpha: 0.94),
                    const Color(0xFFFFF9ED).withValues(alpha: 0.80),
                    const Color(0xFFFFF9ED).withValues(alpha: 0.20),
                  ],
                  stops: const [0.0, 0.65, 1.0],
                ),
              ),
            ),

            // Greeting row content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (isLoggedIn) {
                        _openProfileScreen();
                      } else {
                        context.push('/login');
                      }
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0xFFD4AF37),
                              width: 1.5,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1A000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: (isLoggedIn && userAvatar != null && userAvatar.isNotEmpty)
                                ? Image.network(
                                    userAvatar,
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(
                                        Icons.person_rounded,
                                        color: Color(0xFF6B1118),
                                        size: 24,
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Icon(
                                      isLoggedIn
                                          ? Icons.person_rounded
                                          : Icons.person_outline_rounded,
                                      color: const Color(0xFF6B1118),
                                      size: 24,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.t('namaste'),
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF231E1B),
                              ),
                            ),
                            Text(
                              isLoggedIn
                                  ? (userName != null && userName.isNotEmpty
                                      ? '$userName 🙏'
                                      : AppStrings.t('devotee'))
                                  : '${AppStrings.t('sign_in_to_continue')} 🙏',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF4A3E38),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Profile / Sign In Pill
                  GestureDetector(
                    onTap: () {
                      if (isLoggedIn) {
                        _openProfileScreen();
                      } else {
                        context.push('/login');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13, vertical: 6.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7A0C16),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            isLoggedIn ? AppStrings.t('profile') : AppStrings.t('sign_in'),
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 13,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Floating Search Bar with Mic Icon
  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: _openGlobalSearch,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFE2D6C0),
            width: 1.1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              color: Color(0xFF334155),
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppStrings.t('search_placeholder'),
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                _openGlobalSearch();
              },
              child: const Icon(
                Icons.mic_none_rounded,
                color: Color(0xFF475569),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Featured Card 1: Pooja Booking (वैदिक पूजा बुकिंग)
  Widget _buildPoojaBookingCard() {
    final isHindi = LocaleService().isHindi;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Background Artwork
            Positioned.fill(
              child: Image.asset(
                AppConstants.pujaHeroBgAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6B1118), Color(0xFFC75B12)],
                    ),
                  ),
                ),
              ),
            ),

            // Warm Devotional Vignette Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF2C0B05).withAlpha(160),
                      const Color(0xFF5A1408).withAlpha(220),
                      const Color(0xFF260502).withAlpha(240),
                    ],
                  ),
                ),
              ),
            ),

            // Card Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Gold pill badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDCB06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isHindi ? 'विशेष सनातन सेवा' : 'SPECIAL SANATAN SEVA',
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF5A1408),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Title
                  Text(
                    AppStrings.t('pooja_booking_title'),
                    style: GoogleFonts.cinzel(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Subtitle
                  Text(
                    AppStrings.t('pooja_booking_desc'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFFDE68A),
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 4 Category Quick Chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildPujaCardChip(AppStrings.t('temple_puja'), () {
                        setState(() {
                          _selectedMandirFilter = null;
                          _currentTabIndex = 1;
                        });
                      }),
                      _buildPujaCardChip(AppStrings.t('havan_ritual'), () {
                        setState(() {
                          _selectedMandirFilter = 'Havan';
                          _currentTabIndex = 1;
                        });
                      }),
                      _buildPujaCardChip(AppStrings.t('home_puja'), () {
                        setState(() {
                          _selectedMandirFilter = 'Griha';
                          _currentTabIndex = 1;
                        });
                      }),
                      _buildPujaCardChip(AppStrings.t('special_puja'), () {
                        setState(() {
                          _selectedMandirFilter = 'Special';
                          _currentTabIndex = 1;
                        });
                      }),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // CTA Button
                  SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _currentTabIndex = 1);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFDCB06),
                        foregroundColor: const Color(0xFF5A1408),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        elevation: 2,
                      ),
                      child: Text(
                        AppStrings.t('book_puja_btn'),
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPujaCardChip(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(26),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withAlpha(50),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Featured Card 2: Talk to Astrologer (ज्योतिषी से बात करें)
  Widget _buildAstrologerCard() {
    final isHindi = LocaleService().isHindi;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Celestial Background Artwork
            Positioned.fill(
              child: Image.asset(
                AppConstants.astroHeroBannerAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF3B0764), Color(0xFF1E1B4B)],
                    ),
                  ),
                ),
              ),
            ),

            // Deep Celestial Vignette Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF1A0A2A).withAlpha(160),
                      const Color(0xFF2E0854).withAlpha(220),
                      const Color(0xFF140326).withAlpha(240),
                    ],
                  ),
                ),
              ),
            ),

            // Card Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Gold pill badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isHindi ? 'प्रमाणित वैदिक ज्योतिष' : 'VERIFIED VEDIC ASTROLOGY',
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Title
                  Text(
                    AppStrings.t('talk_astrologer_title'),
                    style: GoogleFonts.cinzel(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Subtitle
                  Text(
                    AppStrings.t('talk_astrologer_desc'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFFDE68A),
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 4 Speciality Quick Chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildPujaCardChip(isHindi ? 'कुंडली' : 'Kundli', () {
                        setState(() => _currentTabIndex = 2);
                      }),
                      _buildPujaCardChip(isHindi ? 'करियर' : 'Career', () {
                        setState(() => _currentTabIndex = 2);
                      }),
                      _buildPujaCardChip(isHindi ? 'विवाह' : 'Marriage', () {
                        setState(() => _currentTabIndex = 2);
                      }),
                      _buildPujaCardChip(isHindi ? 'वास्तु' : 'Vastu', () {
                        setState(() => _currentTabIndex = 2);
                      }),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // CTA Button
                  SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _currentTabIndex = 2);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        elevation: 2,
                      ),
                      child: Text(
                        AppStrings.t('talk_now'),
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanchangCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6B1D0E),
            Color(0xFFB91C1C),
            Color(0xFFFF6B35),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.saffronPrimary.withAlpha(50),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withAlpha(100)),
                ),
                child: Row(
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      AppStrings.t('panchang_today'),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.amber.shade200,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    AppStrings.t('details'),
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.amber.shade200,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios,
                      size: 10, color: Colors.white70),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.t('panchang_tithi_default'),
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.t('panchang_muhurat_default'),
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFFFDE68A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      String title, String actionText, VoidCallback onAction) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.cinzel(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionText,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.saffronPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMandirsHorizontalList() {
    final mandirs = [
      {
        'name': 'Kashi Vishwanath Mandir',
        'city': 'Varanasi, UP',
        'deity': 'Lord Shiva',
        'status': 'Live Darshan Open',
      },
      {
        'name': 'Mahakaleshwar Jyotirlinga',
        'city': 'Ujjain, MP',
        'deity': 'Mahakal',
        'status': 'Bhasma Aarti Available',
      },
      {
        'name': 'Tirupati Balaji Mandir',
        'city': 'Tirumala, AP',
        'deity': 'Lord Venkateswara',
        'status': 'Seva Booking Open',
      },
    ];

    return SizedBox(
      height: 160,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: mandirs.length,
        itemBuilder: (context, i) {
          final m = mandirs[i];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedMandirFilter = m['name'];
                _currentTabIndex = 1;
              });
            },
            child: Container(
              width: 240,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(6),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.warmCream,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          m['deity']!,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.deepAmber,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 14, color: AppColors.saffronPrimary),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    m['name']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '📍 ${m['city']!}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        LocaleService().isHindi ? 'लाइव दर्शन उपलब्ध' : m['status']!,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPujaCards() {
    final pujas = [
      {
        'title': 'Maha Rudrabhishek with 108 Bilva Patra',
        'mandir': 'Kashi Vishwanath, Varanasi',
        'date': 'Tomorrow, 08:00 AM',
        'price': '₹ 1,100',
      },
      {
        'title': 'Navchandi Shatru & Graha Shanti Homa',
        'mandir': 'Kamakhya Devi, Guwahati',
        'date': 'Coming Sunday',
        'price': '₹ 2,501',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: pujas.map((p) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('🔥', style: TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p['title']!,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${p['mandir']} • ${p['date']}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p['price']!,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.saffronDark,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedMandirFilter = p['title'];
                      _currentTabIndex = 1;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A0C16),
                    minimumSize: const Size(64, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: Text(AppStrings.t('book'),
                      style: const TextStyle(fontSize: 12, color: Colors.white)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
