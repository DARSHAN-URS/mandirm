import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../bookings/screens/bookings_screen.dart';
import '../../common/widgets/mandirm_header.dart';
import '../widgets/sankalp_booking_modal.dart';

class PujaDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? puja;

  const PujaDetailScreen({super.key, this.puja});

  @override
  State<PujaDetailScreen> createState() => _PujaDetailScreenState();
}

class _PujaDetailScreenState extends State<PujaDetailScreen> {
  int _selectedNavTab = 0; // 0: About, 1: Benefits, 2: Process, 3: Packages, 4: FAQs
  final ScrollController _scrollController = ScrollController();

  // Active Countdown Timer
  late Timer _timer;
  int _totalSeconds = (1 * 86400) + (16 * 3600) + (34 * 60) + 35;

  final List<String> _navTabs = ['About', 'Benefits', 'Process', 'Packages', 'FAQs'];

  final List<Map<String, dynamic>> _packages = [
    {
      'title': 'Basic Puja Package\n(Online)',
      'price': '₹ 1,100',
      'numericPrice': 1100,
      'imageAsset': AppConstants.pkgBasicAsset,
      'features': [
        'Priest Sankalp in your Name & Gotra',
        'Private Video Link to watch live Sankalp',
        'Online Aarti & Digital Darshan',
      ],
    },
    {
      'title': 'Special Puja Package\n(Live)',
      'price': '₹ 2,100',
      'numericPrice': 2100,
      'imageAsset': AppConstants.pkgSpecialAsset,
      'features': [
        'Complete 108 Ahuti Vedic Homa',
        'Holy Prasad Box dispatched to your home',
        'Direct 1-on-1 Video Connection with Sanctum',
      ],
    },
    {
      'title': 'Complete Ritual Package\n(Live + Brahmin Bhojan)',
      'price': '₹ 5,100',
      'numericPrice': 5100,
      'imageAsset': AppConstants.pkgCompleteAsset,
      'features': [
        'Complete Homa + Brahmin Bhojan + Cow Grass Seva',
        'Doorstep consecrated Prasad hamper & Gangajal',
        'Energized Yantra & Raksha Sutra blessed at Mandir',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalSeconds > 0 && mounted) {
        setState(() {
          _totalSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _openBookingModal(Map<String, dynamic> package) {
    final pujaData = Map<String, dynamic>.from(widget.puja ?? {
      'title': 'Haridwar Pitru Dosh Shanti Mahapuja, Ganga Aarti and Brahmin Bhojan',
      'mandir': 'Ganga Ghat, Haridwar, Uttarakhand',
      'date': '29 Sep, Tue • 7:00 AM',
      'price': package['price'],
    });

    pujaData['price'] = package['price'];
    pujaData['numericPrice'] = package['numericPrice'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SankalpBookingModal(
        puja: pujaData,
        onSuccess: () {
          Navigator.pop(ctx);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookingsScreen(
                onBrowsePujas: () => Navigator.pop(context),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.puja?['title'] as String? ??
        'Pitru Dosh Shanti Mahapuja,\nGanga Aarti and Brahmin Bhojan';
    final subtitle = widget.puja?['subtitle'] as String? ??
        'Special puja for relief from Pitru Dosh and to receive blessings of ancestors for peace, prosperity and well-being.';
    final date = widget.puja?['date'] as String? ??
        '29 September, Monday\nAshwin Krishna Tritiya';

    // Calculate countdown breakdown
    final days = (_totalSeconds ~/ 86400).toString().padLeft(2, '0');
    final hours = ((_totalSeconds % 86400) ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((_totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (_totalSeconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F2),
      body: Column(
        children: [
          // 1. Unified Fixed Top Mandirm Header
          MandirmHeader(
            showBackButton: true,
            trailing: IconButton(
              icon: const Icon(Icons.search_rounded,
                  color: Color(0xFF2C2420), size: 22),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Search in Puja Details'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),

          // 2. Scrollable Body Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Banner Card
                  _buildHeroBanner(),

                  const SizedBox(height: 16),

                  // Main Puja Title
                  Text(
                    title,
                    style: GoogleFonts.cinzel(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF4A1005),
                      height: 1.25,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Subtitle
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF5A4E46),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Date & Time Box
                  _buildDateTimeBox(date),

                  const SizedBox(height: 14),

                  // Countdown Timer Bar
                  _buildCountdownBar(days, hours, minutes, seconds),

                  const SizedBox(height: 14),

                  // Horizontal Nav Tabs (About, Benefits, Process, Packages, FAQs)
                  _buildNavTabs(),

                  const SizedBox(height: 18),

                  // Tab View Content based on selected tab
                  if (_selectedNavTab == 0 || _selectedNavTab == 1) ...[
                    // About This Puja Section
                    _buildAboutSection(),

                    const SizedBox(height: 20),

                    // Key Benefits Section
                    _buildKeyBenefitsSection(),

                    const SizedBox(height: 20),
                  ],

                  if (_selectedNavTab == 2) ...[
                    // Process Section
                    _buildProcessSection(),
                    const SizedBox(height: 20),
                  ],

                  if (_selectedNavTab == 4) ...[
                    // FAQs Section
                    _buildFaqSection(),
                    const SizedBox(height: 20),
                  ],

                  // Puja Packages Section
                  _buildPackagesSection(),
                ],
              ),
            ),
          ),
        ],
      ),

      // 3. Sticky Bottom Bar: "Select Puja Package →"
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          10,
          16,
          MediaQuery.of(context).padding.bottom > 0
              ? MediaQuery.of(context).padding.bottom + 6
              : 14,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFEFE6D6), width: 1.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              // Open default package (Special Package)
              _openBookingModal(_packages[1]);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_month_outlined,
                    color: Colors.white, size: 19),
                const SizedBox(width: 8),
                Text(
                  'Select Puja Package',
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 17),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Hero Banner Card at the top of the details page
  Widget _buildHeroBanner() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE4D4), width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // High resolution banner visual
            Image.asset(
              AppConstants.pujaDetailBannerAsset,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) => Image.asset(
                AppConstants.pujaHeroBgAsset,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),

            // Tap overlay on "Book Now →" button area
            Positioned(
              left: 14,
              bottom: 12,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  _openBookingModal(_packages[0]);
                },
                child: Container(
                  width: 140,
                  height: 38,
                  color: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Date & Time Box with side-by-side columns
  Widget _buildDateTimeBox(String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEFE4D2), width: 1.1),
      ),
      child: Row(
        children: [
          // Left: Calendar Date
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.calendar_month_outlined,
                    color: Color(0xFF8B1E1E), size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '29 September, Monday',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF231E1B),
                        ),
                      ),
                      Text(
                        'Ashwin Krishna Tritiya',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF6B6560),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            height: 34,
            width: 1,
            color: const Color(0xFFE5DDD0),
            margin: const EdgeInsets.symmetric(horizontal: 10),
          ),

          // Right: Clock Time & Duration
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.access_time_rounded,
                    color: Color(0xFF8B1E1E), size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '7:00 AM onwards',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF231E1B),
                        ),
                      ),
                      Text(
                        '(Duration 2-3 Hours)',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF6B6560),
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
    );
  }

  /// Live Countdown Timer Bar
  Widget _buildCountdownBar(
      String days, String hours, String minutes, String seconds) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFB91C1C), Color(0xFF7A0C16)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33B91C1C),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Booking closes in',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          // 4 Countdown Units (Days, Hrs, Min, Sec)
          Row(
            children: [
              _buildCountdownUnit(days, 'Days'),
              const SizedBox(width: 6),
              _buildCountdownUnit(hours, 'Hrs'),
              const SizedBox(width: 6),
              _buildCountdownUnit(minutes, 'Min'),
              const SizedBox(width: 6),
              _buildCountdownUnit(seconds, 'Sec'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownUnit(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF8B1E1E),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  /// Horizontal Tab Pills: About, Benefits, Process, Packages, FAQs
  Widget _buildNavTabs() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _navTabs.length,
        itemBuilder: (context, i) {
          final tab = _navTabs[i];
          final isSelected = _selectedNavTab == i;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                setState(() => _selectedNavTab = i);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF8B1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF8B1E1E)
                        : const Color(0xFFE5DDD0),
                    width: 1.1,
                  ),
                ),
                child: Text(
                  tab,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF4A3E38),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Section: About This Puja
  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About This Puja',
          style: GoogleFonts.cinzel(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4A1005),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                'This special puja is performed for the peace of ancestors, relief from Pitru Dosh and to bring happiness, prosperity and harmony in family life. It includes mantra chanting, tarpan, havan, pind daan and Brahmin bhojan.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF5A4E46),
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                AppConstants.pujaAboutThumbAsset,
                width: 90,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 90,
                  height: 70,
                  color: const Color(0xFFFBEBC7),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Section: Key Benefits (4 Cards in a row)
  Widget _buildKeyBenefitsSection() {
    final benefits = [
      {'icon': Icons.people_rounded, 'title': 'Relief from\nPitru Dosh'},
      {'icon': Icons.favorite_rounded, 'title': 'Peace &\nProsperity in Family'},
      {'icon': Icons.account_balance_wallet_rounded, 'title': 'Financial\nStability'},
      {'icon': Icons.trending_up_rounded, 'title': 'Success in\nAll Endeavors'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Benefits',
          style: GoogleFonts.cinzel(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4A1005),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: benefits.map((b) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEFE4D2), width: 1.1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(b['icon'] as IconData,
                        color: const Color(0xFF8B1E1E), size: 22),
                    const SizedBox(height: 6),
                    Text(
                      b['title'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF332D29),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Section: Vedic Process (Shown on Process tab)
  Widget _buildProcessSection() {
    final steps = [
      '1. Devotee Sankalp: Tirtha priest recites your name, Gotra & wishes.',
      '2. Holy Tarpan & Pind Daan: Ritual performed on the banks of holy river.',
      '3. Sacred Homa & Ahutis: Auspicious Vedic mantras chanted by 3 priests.',
      '4. Consecrated Prasad Dispatch: Holy Gangajal & dry fruits sent to your home.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Puja Process & Rituals',
          style: GoogleFonts.cinzel(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4A1005),
          ),
        ),
        const SizedBox(height: 8),
        ...steps.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF8B1E1E), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s,
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: const Color(0xFF4A3E38)),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  /// Section: FAQs (Shown on FAQs tab)
  Widget _buildFaqSection() {
    final faqs = [
      {
        'q': 'Do I need to be physically present at the temple?',
        'a': 'No, verified pandits will conduct the ritual with your personalized Sankalp. You can join via live video link.'
      },
      {
        'q': 'How will I receive the sacred prasad?',
        'a': 'Consecrated prasad (Ganga Jal, dry fruits, Bhasma) will be shipped directly to your address within 3-5 working days.'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: GoogleFonts.cinzel(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4A1005),
          ),
        ),
        const SizedBox(height: 8),
        ...faqs.map((f) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEFE4D2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(f['q']!,
                      style: GoogleFonts.poppins(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(f['a']!,
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: const Color(0xFF6B6560))),
                ],
              ),
            )),
      ],
    );
  }

  /// Section: Puja Packages (3 cards side-by-side)
  Widget _buildPackagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Puja Packages',
              style: GoogleFonts.cinzel(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4A1005),
              ),
            ),
            GestureDetector(
              onTap: () {
                _openBookingModal(_packages[1]);
              },
              child: Row(
                children: [
                  Text(
                    'View All Packages',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF8B1E1E),
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(Icons.arrow_forward_rounded,
                      color: Color(0xFF8B1E1E), size: 13),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Horizontal Row of 3 Packages
        Row(
          children: _packages.map((pkg) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: const Color(0xFFEFE4D2), width: 1.1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0C000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Package Image Thumbnail
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.asset(
                        pkg['imageAsset'] as String,
                        height: 68,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 68,
                          color: const Color(0xFFFBEBC7),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          SizedBox(
                            height: 34,
                            child: Text(
                              pkg['title'] as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF231E1B),
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Price
                          Text(
                            pkg['price'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF4A1005),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // "Book Now →" Button
                          SizedBox(
                            width: double.infinity,
                            height: 28,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B1E1E),
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () => _openBookingModal(pkg),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Book Now',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  const Icon(Icons.arrow_forward_rounded,
                                      size: 11, color: Colors.white),
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
          }).toList(),
        ),
      ],
    );
  }
}
