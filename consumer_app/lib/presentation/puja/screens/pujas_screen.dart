import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/api_service.dart';
import '../../../core/l10n/locale_service.dart';
import 'puja_detail_screen.dart';
import '../../common/widgets/mandirm_header.dart';
import '../../common/widgets/app_image.dart';
import '../../common/widgets/faq_section.dart';

class PujasScreen extends StatefulWidget {
  final String? initialMandirFilter;
  final VoidCallback? onBookingSuccess;

  const PujasScreen({
    super.key,
    this.initialMandirFilter,
    this.onBookingSuccess,
  });

  @override
  State<PujasScreen> createState() => _PujasScreenState();
}

class _PujasScreenState extends State<PujasScreen> {
  String _selectedCategoryId = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> get _filterChips {
    final isHi = LocaleService().isHindi;
    return [
      {'id': 'all', 'label': isHi ? 'सभी पूजा' : 'All Pujas', 'icon': Icons.grid_view_rounded},
      {'id': 'Rudra & Health', 'label': isHi ? 'रुद्र व स्वास्थ्य' : 'Rudra & Health', 'icon': Icons.favorite_border_rounded},
      {'id': 'Vighnaharta Puja', 'label': isHi ? 'विघ्नहर्ता पूजा' : 'Vighnaharta Puja', 'icon': Icons.spa_rounded},
      {'id': 'Wealth & Family', 'label': isHi ? 'समृद्धि व परिवार' : 'Wealth & Family', 'icon': Icons.account_balance_wallet_outlined},
      {'id': 'Dosha Nivaran', 'label': isHi ? 'दोष निवारण' : 'Dosha Nivaran', 'icon': Icons.people_outline_rounded},
      {'id': 'Planetary Balance', 'label': isHi ? 'ग्रह शांति' : 'Planetary Balance', 'icon': Icons.auto_awesome_rounded},
    ];
  }

  // Only real pujas from database
  final List<Map<String, dynamic>> _allPujas = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialMandirFilter != null) {
      _searchQuery = widget.initialMandirFilter!;
      _searchController.text = widget.initialMandirFilter!;
    }
    _loadBackendPujas();
  }

  Future<void> _loadBackendPujas() async {
    try {
      final backendPujas = await ApiService().getPujas();
      if (backendPujas.isNotEmpty && mounted) {
        setState(() {
          _allPujas.clear();
          for (final bp in backendPujas) {
            final id = bp['id']?.toString() ?? 'pj_${bp.hashCode}';
            final inclusionsRaw = bp['samagri_included'];
            List<String> inclusions = [];
            if (inclusionsRaw is List) {
              inclusions = inclusionsRaw.map((e) => e.toString()).toList();
            } else if (inclusionsRaw is String && inclusionsRaw.isNotEmpty) {
              inclusions = inclusionsRaw.split(',').map((e) => e.trim()).toList();
            }
            if (inclusions.isEmpty) {
              inclusions = [
                'Personalized Sankalp in devotee Gotra',
                'Live Darshan Link & Consecrated Prasad Delivery',
              ];
            }

            _allPujas.add({
              'id': id,
              'title': bp['title'] ?? bp['name'] ?? 'Vedic Puja Ritual',
              'title_hi': bp['title_hi'] ?? bp['title'] ?? 'वैदिक पूजा अनुष्ठान',
              'subtitle': bp['description'] ?? bp['subtitle'] ?? 'Holy ceremony conducted by certified temple priests',
              'subtitle_hi': bp['subtitle_hi'] ?? bp['description'] ?? 'पवित्र तीर्थ पुरोहितों द्वारा संपन्न वैदिक विधि',
              'badge': bp['is_popular'] == true ? 'Most Popular' : 'Special Seva',
              'badge_hi': bp['is_popular'] == true ? 'सर्वाधिक लोकप्रिय' : 'विशेष सेवा',
              'badgeColor': const Color(0xFFFDE68A),
              'badgeTextColor': const Color(0xFF78350F),
              'badgeIcon': Icons.spa_rounded,
              'mandir': bp['temple_name'] ?? bp['mandir'] ?? 'Sacred Temple Sanctum',
              'mandir_hi': bp['mandir_hi'] ?? bp['temple_name'] ?? 'पवित्र तीर्थ धाम',
              'date': bp['date'] ?? 'Upcoming Auspicious Muhurat',
              'date_hi': bp['date_hi'] ?? 'आगामी शुभ मुहूर्त',
              'category': bp['category'] ?? 'All Pujas',
              'price': '₹${(bp['price'] as num?)?.toInt() ?? 1100}',
              'numericPrice': (bp['price'] as num?)?.toInt() ?? 1100,
              'imageAsset': (bp['image_url'] != null && bp['image_url'].toString().isNotEmpty)
                  ? bp['image_url']
                  : AppConstants.pujaGangaDiyaAsset,
              'pandits': bp['pandits'] ?? '3 Vedic Purohits',
              'duration': '${bp['duration_minutes'] ?? 60} mins',
              'benefits': bp['benefits'] ?? 'Spiritual peace, obstacle removal, divine blessings.',
              'inclusions': inclusions,
            });
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredPujas {
    return _allPujas.where((p) {
      final matchesCategory = _selectedCategoryId == 'all' ||
          p['category'] == _selectedCategoryId;
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          (p['title'] as String).toLowerCase().contains(q) ||
          (p['mandir'] as String).toLowerCase().contains(q) ||
          (p['subtitle'] as String).toLowerCase().contains(q);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _openBookingSheet(Map<String, dynamic> puja) {
    _openPujaDetail(puja);
  }

  void _openPujaDetail(Map<String, dynamic> puja) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PujaDetailScreen(puja: puja),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pujas = _filteredPujas;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F2),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Unified Mandirm Header (same header across entire app)
          SliverToBoxAdapter(
            child: MandirmHeader(
              trailing: GestureDetector(
                onTap: _showSearchModal,
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
                      Icons.search_rounded,
                      color: Color(0xFF7A0C16),
                      size: 19,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Title & Subtitle ("Online Puja")
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleService().isHindi ? 'ऑनलाइन पूजा' : 'Online Puja',
                    style: TextStyle(fontFamily: 'Headway', 
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF4A1005),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    LocaleService().isHindi
                        ? 'सत्यापित वैदिक पंडितों द्वारा प्रामाणिक पूजा संपन्न कराएं'
                        : 'Book authentic pujas performed by verified pandits',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF5A4E46),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Category Filter Chips (All Pujas, Pitr Dosha, Health, Wealth, Career)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filterChips.length,
                itemBuilder: (context, i) {
                  final chip = _filterChips[i];
                  final isSelected = _selectedCategoryId == chip['id'];

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = chip['id'] as String;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF8B1E1E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF8B1E1E)
                                : const Color(0xFFE5DDD0),
                            width: 1.1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              chip['icon'] as IconData,
                              size: 16,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF7A0C16),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              chip['label'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF2C2420),
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
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 14)),

          // 4. Puja Cards List
          if (pujas.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 44)),
                    const SizedBox(height: 10),
                    Text(
                      'No Pujas in this Category',
                      style: TextStyle(fontFamily: 'Headway', 
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4A1005),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B1E1E),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedCategoryId = 'all';
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      },
                      child: Text(
                        LocaleService().isHindi ? 'सभी पूजाएं दिखाएं' : 'Show All Pujas',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final puja = pujas[index];
                    return _buildPujaCard(puja);
                  },
                  childCount: pujas.length,
                ),
              ),
            ),

          // 5. Frequently Asked Questions Section (Bilingual Puja FAQs)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: FaqSection(serviceType: 'puja'),
            ),
          ),
        ],
      ),
    );
  }

  /// Individual Puja Card matching the exact visual design in mockup
  Widget _buildPujaCard(Map<String, dynamic> puja) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openPujaDetail(puja),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEDE4D4),
          width: 1.1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top & Middle area with Title, Details and Right Illustration
          Stack(
            children: [
              // Right-side devotional illustration
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                width: 175,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AppImage.asset(
                        puja['imageAsset'] as String,
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          color: const Color(0xFFFBEBC7),
                        ),
                      ),
                      // Soft left gradient fade so image merges into the cream card
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFFFDF8),
                              const Color(0xFFFFFDF8).withValues(alpha: 0.0),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Left-side textual information
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Special Pill Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: puja['badgeColor'] as Color? ??
                            const Color(0xFFFDE68A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            puja['badgeIcon'] as IconData? ??
                                Icons.people_alt_rounded,
                            size: 13,
                            color: puja['badgeTextColor'] as Color? ??
                                const Color(0xFF78350F),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            (LocaleService().isHindi ? puja['badge_hi'] : null) as String? ??
                                puja['badge'] as String? ?? (LocaleService().isHindi ? 'विशेष पूजा' : 'Special Puja'),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: puja['badgeTextColor'] as Color? ??
                                  const Color(0xFF78350F),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Puja Title
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.52,
                      child: Text(
                        (LocaleService().isHindi ? puja['title_hi'] : null) as String? ??
                            puja['title'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF4A1005),
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Subtitle / Objective
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.50,
                      child: Text(
                        (LocaleService().isHindi ? puja['subtitle_hi'] : null) as String? ??
                            puja['subtitle'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF5A4E46),
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Location Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Color(0xFF8B1E1E),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.46,
                          child: Text(
                            (LocaleService().isHindi ? puja['mandir_hi'] : null) as String? ??
                                puja['mandir'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF332D29),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Date & Tithi Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: Color(0xFF8B1E1E),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.46,
                          child: Text(
                            (LocaleService().isHindi ? puja['date_hi'] : null) as String? ??
                                puja['date'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF332D29),
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

          const SizedBox(height: 4),

          // Bottom Action Row: "From ₹..." on left, "Participate →" on right
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Price Tag
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      LocaleService().isHindi ? 'प्रारंभ ' : 'From ',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF5A4E46),
                      ),
                    ),
                    Text(
                      puja['price'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF4A1005),
                      ),
                    ),
                  ],
                ),

                // "Participate →" Pill Button
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _openBookingSheet(puja),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 9),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B1E1E), Color(0xFF6B1118)],
                      ),
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          LocaleService().isHindi ? 'संकल्प लें' : 'Participate',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 15,
                          color: Colors.white,
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

  void _showSearchModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (val) {
                  setState(() => _searchQuery = val);
                },
                decoration: InputDecoration(
                  hintText: LocaleService().isHindi
                      ? 'पूजा या मंदिर का नाम खोजें...'
                      : 'Search by puja name, temple...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF8B1E1E)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                      Navigator.pop(ctx);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B1E1E),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    LocaleService().isHindi ? 'खोजें' : 'Search',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

