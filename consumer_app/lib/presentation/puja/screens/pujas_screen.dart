import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/api_service.dart';
import '../../../core/l10n/locale_service.dart';
import 'puja_detail_screen.dart';
import '../../common/widgets/mandirm_header.dart';

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
      {'id': 'Pitr Dosha', 'label': isHi ? 'पितृ दोष' : 'Pitr Dosha', 'icon': Icons.people_outline_rounded},
      {'id': 'Health', 'label': isHi ? 'स्वास्थ्य' : 'Health', 'icon': Icons.favorite_border_rounded},
      {'id': 'Wealth', 'label': isHi ? 'समृद्धि' : 'Wealth', 'icon': Icons.account_balance_wallet_outlined},
      {'id': 'Career', 'label': isHi ? 'करियर' : 'Career', 'icon': Icons.trending_up_rounded},
    ];
  }

  final List<Map<String, dynamic>> _allPujas = [
    {
      'id': 'pj_pitru_1',
      'title': 'Haridwar Pitru Dosh Shanti Mahapuja, Ganga Aarti and Brahmin Bhojan',
      'subtitle': 'For Pitru Dosh relief and ancestral blessings',
      'badge': 'Maha Bharani Special',
      'badgeColor': const Color(0xFFFDE68A),
      'badgeTextColor': const Color(0xFF78350F),
      'badgeIcon': Icons.people_alt_rounded,
      'mandir': 'Ganga Ghat, Haridwar, Uttarakhand',
      'date': '29 Sep, Tue • 7:00 AM\nAshwin Krishna Tritiya',
      'category': 'Pitr Dosha',
      'price': '₹851',
      'numericPrice': 851,
      'imageAsset': AppConstants.pujaGangaDiyaAsset,
      'pandits': '3 Ganga Tirtha Purohits',
      'duration': '60 mins',
      'benefits': 'Relief from Pitru Dosh, ancestral peace, removal of hurdles in family prosperity.',
      'inclusions': [
        'Personalized Sankalp with ancestral names & Gotra',
        'Ganga Aarti offering with fresh lotus flowers',
        'Brahmin Bhojan and cow grass seva conducted in your name',
        'Blessed Ganga Jal and dry fruits prasad dispatched to home',
      ],
    },
    {
      'id': 'pj_guru_2',
      'title': 'Guru Chandal Dosh Nivaran Puja',
      'subtitle': 'For financial stability, removing hurdles in career and mental clarity',
      'badge': 'Thursday Guru Chandal Special',
      'badgeColor': const Color(0xFFFED7AA),
      'badgeTextColor': const Color(0xFF9A3412),
      'badgeIcon': Icons.public_rounded,
      'mandir': 'Brihaspati Temple, Kashi, Uttar Pradesh',
      'date': '29 Oct, Thu • 7:00 PM\nAsvayujamu Krishna Chaviti',
      'category': 'Career',
      'price': '₹1,101',
      'numericPrice': 1101,
      'imageAsset': AppConstants.pujaGuruBrihaspatiAsset,
      'pandits': '2 Vedic Brihaspati Acharyas',
      'duration': '50 mins',
      'benefits': 'Removes Guru & Rahu afflictions, eliminates career stagnation, enhances intellect and stability.',
      'inclusions': [
        'Brihaspati Beej Mantra 11,000 Japa Sankalp',
        'Chana Dal and Yellow Flower archana to Lord Guru',
        'Energized Yellow Sapphire yantra card by post',
        'Prasad box with sanctified Kashi chandan',
      ],
    },
    {
      'id': 'pj_navgraha_3',
      'title': 'Navgraha Shanti Puja',
      'subtitle': 'Bring balance and positivity in life by pacifying the nine planets',
      'badge': 'Navgraha Special',
      'badgeColor': const Color(0xFFFEE2E2),
      'badgeTextColor': const Color(0xFF991B1B),
      'badgeIcon': Icons.local_fire_department_rounded,
      'mandir': 'Online / At Your Location',
      'date': 'Select Date & Time',
      'category': 'Wealth',
      'price': '₹1,501',
      'numericPrice': 1501,
      'imageAsset': AppConstants.pujaNavgrahaAsset,
      'pandits': '3 Navgraha Specialists',
      'duration': '75 mins',
      'benefits': 'Harmonizes all nine planetary influences, neutralizes Sade Sati, bestows health & financial growth.',
      'inclusions': [
        '9 Planetary Homa with sacred Samidha sticks',
        'Personal Navgraha Stotram recital for all family members',
        'Energized 9-Gem Navratna Raksha Yantra',
        'Doorstep consecrated Prasad delivery',
      ],
    },
    {
      'id': 'pj_shiva_4',
      'title': 'Maha Rudrabhishek with 108 Bilva Patra',
      'subtitle': 'Supreme remedy for health recovery, peace, and spiritual elevation',
      'badge': 'Shiva Pradosh Special',
      'badgeColor': const Color(0xFFE0E7FF),
      'badgeTextColor': const Color(0xFF3730A3),
      'badgeIcon': Icons.temple_hindu_rounded,
      'mandir': 'Kashi Vishwanath Mandir, Varanasi',
      'date': 'Coming Monday • 08:00 AM\nShukla Trayodashi',
      'category': 'Health',
      'price': '₹1,100',
      'numericPrice': 1100,
      'imageAsset': AppConstants.pujaGangaDiyaAsset,
      'pandits': '3 Vedic Acharyas',
      'duration': '45 mins',
      'benefits': 'Removes fear, bestows mental calmness, purifies karmic debts.',
      'inclusions': [
        'Jyotirlinga Jalabhishek with Milk, Honey & Holy Ganga Jal',
        '108 Bilva Patra offering in devotee Gotra',
        'Sanctum Bhasma and Rudraksha delivered by courier',
      ],
    },
    {
      'id': 'pj_wealth_5',
      'title': 'Sri Lakshmi Kuber Dhan Prapti Puja',
      'subtitle': 'Attracts auspicious prosperity, business abundance, and debt freedom',
      'badge': 'Friday Mahalakshmi Special',
      'badgeColor': const Color(0xFFFEF3C7),
      'badgeTextColor': const Color(0xFF92400E),
      'badgeIcon': Icons.account_balance_wallet_rounded,
      'mandir': 'Tirupati Balaji Mandir, AP',
      'date': 'Coming Friday • 09:00 AM\nShukla Ashtami',
      'category': 'Wealth',
      'price': '₹2,100',
      'numericPrice': 2100,
      'imageAsset': AppConstants.pujaNavgrahaAsset,
      'pandits': '3 Sri Vaishnava Archakas',
      'duration': '50 mins',
      'benefits': 'Unblocks frozen financial channels, blesses new business ventures, attracts Mahalakshmi grace.',
      'inclusions': [
        'Sri Suktam and Kanakadhara Stotram recitations',
        'Lotus Archana with energized Kuber Yantra',
        'Blessed Tirupati Laddu Prasadam delivered to home',
      ],
    },
  ];

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
          for (final bp in backendPujas) {
            final id = bp['id']?.toString() ?? 'pj_${bp.hashCode}';
            if (!_allPujas.any((item) => item['id'] == id)) {
              _allPujas.add({
                'id': id,
                'title': bp['title'] ?? bp['name'] ?? 'Vedic Puja Ritual',
                'subtitle': bp['description'] ?? bp['subtitle'] ?? 'Holy ceremony conducted by certified temple priests',
                'badge': bp['badge'] ?? 'Special Seva',
                'badgeColor': const Color(0xFFFDE68A),
                'badgeTextColor': const Color(0xFF78350F),
                'badgeIcon': Icons.spa_rounded,
                'mandir': bp['temple_name'] ?? bp['mandir'] ?? 'Sacred Temple Sanctum',
                'date': bp['date'] ?? 'Upcoming Auspicious Muhurat',
                'category': bp['category'] ?? 'All Pujas',
                'price': '₹${bp['price'] ?? 1100}',
                'numericPrice': (bp['price'] as num?)?.toInt() ?? 1100,
                'imageAsset': bp['image_url'] ?? AppConstants.pujaGangaDiyaAsset,
                'pandits': bp['pandits'] ?? '3 Vedic Purohits',
                'duration': bp['duration'] ?? '45 mins',
                'benefits': bp['benefits'] ?? 'Spiritual peace, obstacle removal, divine blessings.',
                'inclusions': [
                  'Personalized Sankalp in devotee Gotra',
                  'Live Video Link & Prasad Delivery',
                ],
              });
            }
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
                    style: GoogleFonts.cinzel(
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
                      style: GoogleFonts.cinzel(
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
                      Image.asset(
                        puja['imageAsset'] as String,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
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
                            puja['badge'] as String? ?? 'Special Puja',
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

