import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/devotee_data_service.dart';
import '../../common/widgets/mandirm_header.dart';
import '../../consultations/screens/consultations_screen.dart';
import '../widgets/astrologer_consultation_modals.dart';

class AstrologerDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? astrologer;

  const AstrologerDetailScreen({super.key, this.astrologer});

  @override
  State<AstrologerDetailScreen> createState() => _AstrologerDetailScreenState();
}

class _AstrologerDetailScreenState extends State<AstrologerDetailScreen> {
  int _selectedTabIndex = 0; // 0: About, 1: Expertise, 2: Reviews, 3: Availability, 4: Gallery
  bool _isFollowing = false;
  bool _isBioExpanded = false;
  bool _isReplyExpanded = false;

  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _tabs = [
    {'label': 'About', 'icon': Icons.person_rounded},
    {'label': 'Expertise', 'icon': Icons.stars_rounded},
    {'label': 'Reviews', 'icon': Icons.chat_bubble_outline_rounded},
    {'label': 'Availability', 'icon': Icons.calendar_month_outlined},
    {'label': 'Gallery', 'icon': Icons.photo_library_outlined},
  ];

  Map<String, dynamic> get _astro {
    return widget.astrologer ?? {
      'id': 'ast_rajesh',
      'name': 'Pandit Acharya Rajesh Sharma',
      'badge': 'Top Rated',
      'badgeIcon': Icons.emoji_events_rounded,
      'isVerified': true,
      'specialties': 'Vedic Astrology • Kundli Analysis • Marriage • Career',
      'rating': '4.9',
      'reviews': '(12,350+ reviews)',
      'sessions': '1180 sessions',
      'experience': '15+ Years Experience',
      'languages': 'Hindi, English',
      'isOnline': true,
      'price': '₹ 5/Min',
      'priceNumeric': 5,
      'originalPrice': '₹ 36/Min',
      'imageAsset': AppConstants.astroRajeshAsset,
    };
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onConsultationCompleted({required bool isVideo}) {
    final consultationId = 'CNS-${DateTime.now().millisecondsSinceEpoch % 10000}';
    final consultation = {
      'id': consultationId,
      'astrologerName': _astro['name'] ?? 'Vedic Astrologer',
      'specialty': _astro['specialty'] ?? 'Vedic • Kundali',
      'date': 'Today, Just Now',
      'duration': '15 mins',
      'amount': _astro['price'] ?? '₹300',
      'remedy': 'Chant Om Namah Shivaya 108 times daily; donate yellow fruits or sweets on Thursdays.',
      'rating': 5.0,
    };

    DevoteeDataService().addConsultation(consultation);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ConsultationsScreen()),
    );
  }

  void _openCallDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => LiveConsultationCallDialog(
        astrologer: _astro,
        isVideo: false,
        onFinished: () {
          _onConsultationCompleted(isVideo: false);
        },
      ),
    );
  }

  void _openChatModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => LiveChatModal(
        astrologer: _astro,
        onFinished: () {
          _onConsultationCompleted(isVideo: false);
        },
      ),
    );
  }

  void _openGiftDialog() {
    showDialog(
      context: context,
      builder: (ctx) => GiftOfferingDialog(astrologer: _astro),
    );
  }

  @override
  Widget build(BuildContext context) {
    final astro = _astro;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F2),
      body: Column(
        children: [
          // 1. Unified Top Mandirm Header
          MandirmHeader(
            showBackButton: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Share Button
                IconButton(
                  icon: const Icon(Icons.share_outlined,
                      color: Color(0xFF2C2420), size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Sharing profile of ${astro['name']}...'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),

                // More Menu ⋮
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded,
                      color: Color(0xFF2C2420), size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onSelected: (val) {
                    if (val == 'history') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ConsultationsScreen()),
                      );
                    } else if (val == 'help') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mandirm Astrologer Support: support@mandirm.in'),
                          backgroundColor: Color(0xFF7A0C16),
                        ),
                      );
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'history',
                      child: Row(
                        children: [
                          Icon(Icons.history_rounded, size: 18, color: Color(0xFF7A0C16)),
                          SizedBox(width: 8),
                          Text('Past Consultations'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'help',
                      child: Row(
                        children: [
                          Icon(Icons.help_outline_rounded, size: 18, color: Color(0xFF7A0C16)),
                          SizedBox(width: 8),
                          Text('Help & Support'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Scrollable Profile Body
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Astrologer Header Profile Card
                  _buildProfileHeader(astro),

                  const SizedBox(height: 12),

                  // High Satisfaction Callout Banner ("67% users rated 4.5★ or above")
                  _buildSatisfactionBanner(),

                  const SizedBox(height: 14),

                  // Pricing & Gift Bar ("Trial Offer: ₹ 5/Min", "Gift 🎁")
                  _buildPricingAndGiftBar(astro),

                  const SizedBox(height: 14),

                  // Horizontal Nav Tabs (About, Expertise, Reviews, Availability, Gallery)
                  _buildNavTabs(),

                  const SizedBox(height: 16),

                  // Section: About Me
                  _buildAboutMeSection(astro),

                  const SizedBox(height: 16),

                  // Section: Expertise
                  _buildExpertiseSection(),

                  const SizedBox(height: 16),

                  // Section: Rating & Reviews
                  _buildRatingAndReviewsSection(astro),
                ],
              ),
            ),
          ),
        ],
      ),

      // 3. Sticky Bottom Action Bar: "CHAT" (Green) & "CALL" (Crimson)
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
        child: Row(
          children: [
            // Left Button: CHAT (Outlined Green with WhatsApp/Chat icon)
            Expanded(
              child: SizedBox(
                height: 46,
                child: OutlinedButton(
                  onPressed: _openChatModal,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF16A34A), width: 1.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chat_bubble_rounded,
                          color: Color(0xFF16A34A), size: 19),
                      const SizedBox(width: 8),
                      Text(
                        'CHAT',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF16A34A),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Right Button: CALL (Filled Crimson with Phone icon)
            Expanded(
              child: SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: _openCallDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B1E1E),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.phone_rounded,
                          color: Colors.white, size: 19),
                      const SizedBox(width: 8),
                      Text(
                        'CALL',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Profile Header Row: Avatar, Name, Ratings, Experience, "+ Follow", "Available Now"
  Widget _buildProfileHeader(Map<String, dynamic> astro) {
    final imageAsset = astro['imageAsset']?.toString() ?? AppConstants.astroRajeshAsset;
    final avatarUrl = astro['avatarUrl']?.toString() ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Circular Avatar with Green Ring & Online Dot
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF16A34A), width: 2.2),
              ),
              child: ClipOval(
                child: (avatarUrl.isNotEmpty && (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')))
                    ? Image.network(
                        avatarUrl,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          imageAsset,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 72,
                            height: 72,
                            color: const Color(0xFFFBEBC7),
                            child: const Center(
                              child: Text('🧘‍♂️', style: TextStyle(fontSize: 34)),
                            ),
                          ),
                        ),
                      )
                    : Image.asset(
                        imageAsset,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 72,
                          height: 72,
                          color: const Color(0xFFFBEBC7),
                          child: const Center(
                            child: Text('🧘‍♂️', style: TextStyle(fontSize: 34)),
                          ),
                        ),
                      ),
              ),
            ),

            // Green Online Dot at bottom-right of avatar
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.2),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(width: 12),

        // Astrologer Information & Actions
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name + Verified Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      astro['name']?.toString() ?? 'Astrologer',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF231E1B),
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.verified_rounded,
                    color: Color(0xFF2563EB),
                    size: 17,
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Languages Row
              Row(
                children: [
                  const Text('A/अ',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6B6560))),
                  const SizedBox(width: 6),
                  Text(
                    astro['languages'] as String? ?? 'Hindi, English',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: const Color(0xFF5A4E46),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 3),

              // Rating Row
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFEAB308), size: 15),
                  const SizedBox(width: 4),
                  Text(
                    '${astro['rating'] ?? '4.9'} Rating ${astro['reviews'] ?? '(12,350+ reviews)'}',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF332D29),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 3),

              // Experience Row
              Row(
                children: [
                  const Icon(Icons.calendar_month_outlined,
                      size: 13, color: Color(0xFF6B6560)),
                  const SizedBox(width: 5),
                  Text(
                    astro['experience'] as String? ?? '15+ Years Experience',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: const Color(0xFF5A4E46),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Right side: "+ Follow" button & "Available Now"
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                setState(() => _isFollowing = !_isFollowing);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isFollowing
                        ? 'Now following ${astro['name']}'
                        : 'Unfollowed ${astro['name']}'),
                    duration: const Duration(seconds: 1),
                    backgroundColor: const Color(0xFF8B1E1E),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _isFollowing ? const Color(0xFF8B1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF8B1E1E), width: 1.1),
                ),
                child: Text(
                  _isFollowing ? '✓ Following' : '+ Follow',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _isFollowing ? Colors.white : const Color(0xFF8B1E1E),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // "🟢 Available Now"
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF16A34A),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Available Now',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// High Satisfaction Callout Banner: "❤️ 67% users rated 4.5★ or above"
  Widget _buildSatisfactionBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('❤️ ', style: TextStyle(fontSize: 13)),
          Text(
            '67% users rated 4.5★ or above',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF78350F),
            ),
          ),
        ],
      ),
    );
  }

  /// Pricing & Gift Bar: "Trial Offer: ₹ 5/Min  ₹ 36/Min", "Gift 🎁"
  Widget _buildPricingAndGiftBar(Map<String, dynamic> astro) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: Pricing
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trial Offer',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF16A34A),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '₹ 5/Min',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF231E1B),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '₹ 36/Min',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF9CA3AF),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Right: "Gift 🎁" Button
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _openGiftDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFED7AA), width: 1.1),
            ),
            child: Row(
              children: [
                const Icon(Icons.card_giftcard_rounded,
                    color: Color(0xFFB91C1C), size: 18),
                const SizedBox(width: 6),
                Text(
                  'Gift',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFB91C1C),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Horizontal Nav Tabs: About, Expertise, Reviews, Availability, Gallery
  Widget _buildNavTabs() {
    return Column(
      children: [
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _tabs.length,
            itemBuilder: (context, i) {
              final tab = _tabs[i];
              final isSelected = _selectedTabIndex == i;

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    setState(() => _selectedTabIndex = i);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF8B1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF8B1E1E)
                            : const Color(0xFFEDE4D4),
                        width: 1.1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab['icon'] as IconData,
                          size: 15,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF8B1E1E),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          tab['label'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF3E332E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 6),

        // Underline Indicator for Active Tab
        Row(
          children: [
            Container(
              width: 80,
              height: 3,
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF8B1E1E),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Section: About Me Card
  Widget _buildAboutMeSection(Map<String, dynamic> astro) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE4D4), width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Me',
            style: GoogleFonts.cinzel(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4A1005),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${astro['name']} is a Vedic astrologer with over 15 years of experience in Kundli analysis, marriage, career, health and life guidance. He has guided thousands of clients with accurate predictions and practical solutions.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF5A4E46),
              height: 1.45,
            ),
          ),
          if (_isBioExpanded) ...[
            const SizedBox(height: 6),
            Text(
              'Acharya Ji was educated under traditional Gurukula traditions in Varanasi and has deep mastery in Prashna Kundali, Nakshatra Dosh remedies, and gemstone recommendations. He believes in empowering devotees through satvik guidance and simple daily practices.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF5A4E46),
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                setState(() => _isBioExpanded = !_isBioExpanded);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isBioExpanded ? 'Read Less ∧' : 'Read More ∨',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Section: Expertise Badges Card
  Widget _buildExpertiseSection() {
    final row1 = [
      {'label': 'Vedic Astrology', 'icon': Icons.spa_rounded},
      {'label': 'Kundli Analysis', 'icon': Icons.auto_stories_rounded},
      {'label': 'Marriage', 'icon': Icons.favorite_border_rounded},
    ];

    final row2 = [
      {'label': 'Career', 'icon': Icons.work_outline_rounded},
      {'label': 'Health', 'icon': Icons.local_hospital_outlined},
      {'label': 'Wealth & Prosperity', 'icon': Icons.account_balance_wallet_outlined},
      {'label': 'Gemstones', 'icon': Icons.diamond_outlined},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE4D4), width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expertise',
            style: GoogleFonts.cinzel(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4A1005),
            ),
          ),
          const SizedBox(height: 12),

          // Row 1 Badges
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...row1.map((e) => _buildExpertiseChip(e)),
              ...row2.map((e) => _buildExpertiseChip(e)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpertiseChip(Map<String, dynamic> e) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(e['icon'] as IconData, size: 14, color: const Color(0xFF8B1E1E)),
          const SizedBox(width: 5),
          Text(
            e['label'] as String,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF4A3830),
            ),
          ),
        ],
      ),
    );
  }

  /// Section: Rating & Reviews with verified feedback & astrologer reply
  Widget _buildRatingAndReviewsSection(Map<String, dynamic> astro) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE4D4), width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header: "Rating & Reviews" + "4.9 (12,350+ reviews) >"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rating & Reviews',
                    style: GoogleFonts.cinzel(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF4A1005),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          size: 13, color: Color(0xFF16A34A)),
                      const SizedBox(width: 4),
                      Text(
                        'By verified consultees only',
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          color: const Color(0xFF716860),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFEAB308), size: 16),
                  const SizedBox(width: 3),
                  Text(
                    '4.9 (12,350+ reviews)',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF332D29),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right_rounded,
                      size: 16, color: Color(0xFF7A6E65)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // User Review Item
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar: Pink circle with "A"
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFFCE7F3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'A',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF9D174D),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Reviewer details + rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'A C... 🇮🇳',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF231E1B),
                          ),
                        ),

                        // Stars & Menu
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (i) => const Icon(Icons.star_rounded,
                                  color: Color(0xFFEAB308), size: 14),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.more_vert_rounded,
                                size: 16, color: Color(0xFF9CA3AF)),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      'Via Call • 29 Sep, 2026',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Review text
          Text(
            'It was really nice talking to you. I genuinely enjoyed our conversation. I\'ll get in touch with you again soon. ❤️',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF4A3E38),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 10),

          // Astrologer Replied Box (Expandable)
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              setState(() => _isReplyExpanded = !_isReplyExpanded);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Color(0xFF6B7280),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person,
                            size: 11, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Astrologer replied',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF374151),
                          ),
                        ),
                      ),
                      Icon(
                        _isReplyExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.chevron_right_rounded,
                        size: 16,
                        color: const Color(0xFF6B7280),
                      ),
                    ],
                  ),
                  if (_isReplyExpanded) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Blessed soul, thank you for your kind words! May Lord Shiva bless you and your family with health, harmony, and inner peace. 🙏',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF4B5563),
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
