import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/api_service.dart';
import '../../../core/l10n/locale_service.dart';
import '../widgets/astrologer_consultation_modals.dart';
import '../widgets/ai_jyotish_modal.dart';
import 'astrologer_detail_screen.dart';
import '../../common/widgets/mandirm_header.dart';
import '../../common/widgets/app_image.dart';

class AstrologersScreen extends StatefulWidget {
  final VoidCallback? onConsultationFinished;
  const AstrologersScreen({super.key, this.onConsultationFinished});

  @override
  State<AstrologersScreen> createState() => _AstrologersScreenState();
}

class _AstrologersScreenState extends State<AstrologersScreen> {
  String _selectedCategory = 'All Astrologers';
  String _selectedTopic = '';
  String _selectedSort = 'Top Rated';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Top Filter Pills (Row 1)
  List<Map<String, dynamic>> get _categoryPills {
    final isHi = LocaleService().isHindi;
    return [
      {'key': 'All Astrologers', 'label': isHi ? 'सभी ज्योतिषी' : 'All Astrologers', 'icon': Icons.people_alt_rounded},
      {'key': 'AI Jyotish', 'label': isHi ? 'एआई ज्योतिषी ✨' : 'AI Jyotish ✨', 'icon': Icons.auto_awesome_rounded},
      {'key': 'Vedic Astrology', 'label': isHi ? 'वैदिक ज्योतिष' : 'Vedic Astrology', 'icon': Icons.spa_rounded},
      {'key': 'Kundli Analysis', 'label': isHi ? 'कुंडली विश्लेषण' : 'Kundli Analysis', 'icon': Icons.auto_stories_rounded},
      {'key': 'Tarot Cards', 'label': isHi ? 'टैरो कार्ड्स' : 'Tarot Cards', 'icon': Icons.style_rounded},
      {'key': 'Numerology', 'label': isHi ? 'अंक ज्योतिष' : 'Numerology', 'icon': Icons.casino_rounded},
    ];
  }

  // Topic Badges (Row 2)
  List<Map<String, dynamic>> get _topicPills {
    final isHi = LocaleService().isHindi;
    return [
      {'key': 'Love & Relationships', 'label': isHi ? 'प्रेम व संबंध' : 'Love & Relationships', 'icon': Icons.favorite_border_rounded},
      {'key': 'Career & Jobs', 'label': isHi ? 'करियर व नौकरी' : 'Career & Jobs', 'icon': Icons.work_outline_rounded},
      {'key': 'Wealth & Prosperity', 'label': isHi ? 'धन व समृद्धि' : 'Wealth & Prosperity', 'icon': Icons.account_balance_wallet_outlined},
      {'key': 'Health', 'label': isHi ? 'स्वास्थ्य' : 'Health', 'icon': Icons.local_hospital_outlined},
      {'key': 'Home & Vastu', 'label': isHi ? 'घर व वास्तु' : 'Home & Vastu', 'icon': Icons.home_outlined},
      {'key': 'Other Topics', 'label': isHi ? 'अन्य विषय' : 'Other Topics', 'icon': Icons.more_horiz_rounded},
    ];
  }

  // 24/7 AI Jyotish Bot
  static final Map<String, dynamic> _aiAstrologerItem = {
    'id': 'ast_ai_jyotish',
    'name': 'Acharya AI Jyotish (एआई ज्योतिषी)',
    'badge': 'Instant 24x7 AI',
    'badgeIcon': Icons.auto_awesome_rounded,
    'isVerified': true,
    'isAi': true,
    'specialties': 'AI Kundli Analysis • Real-time Vedic Predictions • Dosha Remedies • 24/7 Instant',
    'categories': ['All Astrologers', 'AI Jyotish', 'Vedic Astrology', 'Kundli Analysis'],
    'topics': ['Love & Relationships', 'Career & Jobs', 'Wealth & Prosperity', 'Health', 'Home & Vastu'],
    'rating': '4.9',
    'reviews': '(28,500+ reviews)',
    'sessions': '52,800 sessions',
    'experience': 'Vedic AI Intelligence',
    'expNumeric': 99,
    'languages': 'Hindi, English, Sanskrit',
    'isOnline': true,
    'price': 'FREE Instant',
    'priceNumeric': 0,
    'originalPrice': '₹ 22/min',
    'imageAsset': AppConstants.logoAsset,
  };

  // Only real astrologers from database + 24/7 AI Jyotish
  final List<Map<String, dynamic>> _allAstrologers = [
    _aiAstrologerItem,
  ];

  @override
  void initState() {
    super.initState();
    _loadAstrologers();
  }

  Future<void> _loadAstrologers() async {
    try {
      final dbAstros = await ApiService().getAstrologers(limit: 150);
      if (dbAstros.isNotEmpty && mounted) {
        setState(() {
          _allAstrologers.clear();
          _allAstrologers.add(_aiAstrologerItem);
          for (final raw in dbAstros) {
            _allAstrologers.add(_normalizeAstrologer(raw));
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

  Map<String, dynamic> _normalizeAstrologer(Map<String, dynamic> raw) {
    final id = raw['id']?.toString() ?? 'ast_${raw.hashCode}';
    final name = raw['name']?.toString() ?? 'Vedic Astrologer';
    final specialties = raw['specialties']?.toString() ??
        raw['specialities']?.toString() ??
        'Vedic Astrology • Kundli Analysis';

    final ratingNum = (raw['rating'] is num)
        ? (raw['rating'] as num).toDouble()
        : double.tryParse(raw['rating']?.toString() ?? '4.8') ?? 4.8;
    final ratingStr = ratingNum.toStringAsFixed(1);

    final reviewsCount = raw['reviews_count'] ?? raw['consultations_count'] ?? 1250;
    final reviewsStr = raw['reviews']?.toString() ?? '($reviewsCount+ reviews)';
    final sessionsStr = raw['sessions']?.toString() ?? '$reviewsCount sessions';

    final expNum = (raw['expNumeric'] is num)
        ? (raw['expNumeric'] as num).toInt()
        : (raw['experience_years'] is num)
            ? (raw['experience_years'] as num).toInt()
            : int.tryParse(raw['experience_years']?.toString() ?? '10') ?? 10;
    final expStr = raw['experience']?.toString() ?? '$expNum+ Years Experience';

    final chatRate = (raw['priceNumeric'] is num)
        ? (raw['priceNumeric'] as num).toInt()
        : (raw['per_minute_chat_rate'] is num)
            ? (raw['per_minute_chat_rate'] as num).toInt()
            : int.tryParse(raw['per_minute_chat_rate']?.toString() ?? '22') ?? 22;
    final priceStr = raw['price']?.toString() ?? '₹ $chatRate/min';
    final origPrice = raw['originalPrice']?.toString() ?? '₹ ${(chatRate * 1.5).round()}';

    final isOnline = raw['isOnline'] == true ||
        raw['is_online'] == 1 ||
        raw['is_online'] == true;

    final imageAsset = raw['imageAsset']?.toString() ?? '';
    final imageUrl = raw['avatar_url']?.toString() ?? raw['imageUrl']?.toString() ?? '';

    List<String> categories = [];
    if (raw['categories'] is List) {
      categories = (raw['categories'] as List).map((e) => e.toString()).toList();
    } else {
      categories = ['All Astrologers', 'Vedic Astrology'];
      final spLower = specialties.toLowerCase();
      if (spLower.contains('kundli')) categories.add('Kundli Analysis');
      if (spLower.contains('tarot')) categories.add('Tarot Cards');
      if (spLower.contains('numerology')) categories.add('Numerology');
    }

    List<String> topics = [];
    if (raw['topics'] is List) {
      topics = (raw['topics'] as List).map((e) => e.toString()).toList();
    } else {
      topics = ['Love & Relationships', 'Career & Jobs'];
    }

    return {
      'id': id,
      'name': name,
      'badge': raw['badge']?.toString() ?? 'Top Rated',
      'badgeIcon': raw['badgeIcon'] is IconData ? raw['badgeIcon'] : Icons.emoji_events_rounded,
      'isVerified': raw['isVerified'] ?? true,
      'specialties': specialties,
      'categories': categories,
      'topics': topics,
      'rating': ratingStr,
      'ratingNumeric': ratingNum,
      'reviews': reviewsStr,
      'sessions': sessionsStr,
      'experience': expStr,
      'expNumeric': expNum,
      'languages': raw['languages']?.toString() ?? 'Hindi, English',
      'isOnline': isOnline,
      'price': priceStr,
      'priceNumeric': chatRate,
      'originalPrice': origPrice,
      'imageAsset': imageAsset.isNotEmpty ? imageAsset : AppConstants.astroRajeshAsset,
      'avatarUrl': imageUrl,
      'bio': raw['bio']?.toString() ?? '',
    };
  }

  List<Map<String, dynamic>> get _filteredAstrologers {
    var list = _allAstrologers.where((a) {
      final categories = (a['categories'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
      final topics = (a['topics'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

      final matchesCategory = _selectedCategory == 'All Astrologers' ||
          categories.contains(_selectedCategory);

      final matchesTopic = _selectedTopic.isEmpty ||
          topics.contains(_selectedTopic);

      final q = _searchQuery.toLowerCase();
      final name = a['name']?.toString().toLowerCase() ?? '';
      final specialties = a['specialties']?.toString().toLowerCase() ?? '';
      final languages = a['languages']?.toString().toLowerCase() ?? '';

      final matchesSearch = q.isEmpty ||
          name.contains(q) ||
          specialties.contains(q) ||
          languages.contains(q);

      return matchesCategory && matchesTopic && matchesSearch;
    }).toList();

    // Apply Sorting safely
    if (_selectedSort == 'Top Rated') {
      list.sort((a, b) {
        final rA = (a['ratingNumeric'] as num?)?.toDouble() ?? double.tryParse(a['rating']?.toString() ?? '0') ?? 0.0;
        final rB = (b['ratingNumeric'] as num?)?.toDouble() ?? double.tryParse(b['rating']?.toString() ?? '0') ?? 0.0;
        return rB.compareTo(rA);
      });
    } else if (_selectedSort == 'Experience: High to Low') {
      list.sort((a, b) {
        final eA = (a['expNumeric'] as num?)?.toInt() ?? int.tryParse(a['expNumeric']?.toString() ?? '0') ?? 0;
        final eB = (b['expNumeric'] as num?)?.toInt() ?? int.tryParse(b['expNumeric']?.toString() ?? '0') ?? 0;
        return eB.compareTo(eA);
      });
    } else if (_selectedSort == 'Price: Low to High') {
      list.sort((a, b) {
        final pA = (a['priceNumeric'] as num?)?.toInt() ?? int.tryParse(a['priceNumeric']?.toString() ?? '0') ?? 0;
        final pB = (b['priceNumeric'] as num?)?.toInt() ?? int.tryParse(b['priceNumeric']?.toString() ?? '0') ?? 0;
        return pA.compareTo(pB);
      });
    }

    return list;
  }

  void _openAstrologerDetail(Map<String, dynamic> a) {
    if (a['isAi'] == true) {
      _openAiJyotishModal();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AstrologerDetailScreen(astrologer: a),
      ),
    );
  }

  void _openAiJyotishModal([String? initialQuestion]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AiJyotishModal(
        initialQuestion: initialQuestion,
        onConsultationFinished: () {
          if (widget.onConsultationFinished != null) {
            widget.onConsultationFinished!();
          }
        },
      ),
    );
  }

  void _startConsultation(Map<String, dynamic> astrologer, {required bool isVideo}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => LiveConsultationCallDialog(
        astrologer: astrologer,
        isVideo: isVideo,
        onFinished: () {
          if (widget.onConsultationFinished != null) {
            widget.onConsultationFinished!();
          }
        },
      ),
    );
  }

  void _startChatConsultation(Map<String, dynamic> astrologer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => LiveChatModal(
        astrologer: astrologer,
        onFinished: () {
          if (widget.onConsultationFinished != null) {
            widget.onConsultationFinished!();
          }
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final astrologers = _filteredAstrologers;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F2),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Unified Mandirm Header (same header across entire app)
          const SliverToBoxAdapter(
            child: MandirmHeader(),
          ),

          // 2. Hero Banner: "Talk to Astrologer" with Astrological OM Wheel Art
          SliverToBoxAdapter(
            child: _buildHeroBanner(),
          ),

          // 3. Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFEDE4D4), width: 1.1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0C000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded,
                        color: Color(0xFF7A6E65), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: LocaleService().isHindi
                              ? 'ज्योतिषी का नाम या विशेषज्ञता खोजें...'
                              : 'Search astrologer name or specialty...',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 12.5,
                            color: const Color(0xFF9CA3AF),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE5DDD0)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.tune_rounded,
                          color: Color(0xFF4A3E38), size: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3.5. AI Jyotish Spotlight Banner
          SliverToBoxAdapter(
            child: _buildAiJyotishBanner(),
          ),

          // 4. Filter Pills Row 1: Categories (All Astrologers, Vedic, Kundli, Tarot, Numerology)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categoryPills.length,
                itemBuilder: (context, i) {
                  final pill = _categoryPills[i];
                  final isSelected = _selectedCategory == pill['key'];

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        setState(() {
                          _selectedCategory = pill['key'] as String;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
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
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              pill['icon'] as IconData,
                              size: 15,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF7A0C16),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              pill['label'] as String,
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
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // 5. Filter Pills Row 2: Topics (Love & Relationships, Career & Jobs, Wealth, Health, Vastu)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 34,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _topicPills.length,
                itemBuilder: (context, i) {
                  final pill = _topicPills[i];
                  final isSelected = _selectedTopic == pill['key'];

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        setState(() {
                          if (_selectedTopic == pill['key']) {
                            _selectedTopic = '';
                          } else {
                            _selectedTopic = pill['key'] as String;
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFBEBC7)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFD97706)
                                : const Color(0xFFEAE2D5),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              pill['icon'] as IconData,
                              size: 13,
                              color: isSelected
                                  ? const Color(0xFF92400E)
                                  : const Color(0xFF8B1E1E),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              pill['label'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? const Color(0xFF92400E)
                                    : const Color(0xFF5A4E46),
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

          // 6. Section Header: "Featured Astrologers" + "Top Rated ∨"
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LocaleService().isHindi ? 'विशेष ज्योतिषी' : 'Featured Astrologers',
                    style: TextStyle(fontFamily: 'Headway', 
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF4A1005),
                    ),
                  ),

                  // Sort Filter Dropdown
                  PopupMenuButton<String>(
                    onSelected: (val) {
                      setState(() => _selectedSort = val);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                          value: 'Top Rated', child: Text(LocaleService().isHindi ? 'सर्वश्रेष्ठ' : 'Top Rated')),
                      PopupMenuItem(
                          value: 'Experience: High to Low',
                          child: Text(LocaleService().isHindi ? 'अनुभव: अधिक से कम' : 'Experience: High to Low')),
                      PopupMenuItem(
                          value: 'Price: Low to High',
                          child: Text(LocaleService().isHindi ? 'मूल्य: कम से अधिक' : 'Price: Low to High')),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFFE5DDD0), width: 1.0),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _selectedSort,
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF332D29),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down_rounded,
                              size: 16, color: Color(0xFF7A6E65)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // 7. Astrologers List
          if (astrologers.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔮', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text(
                      'No Astrologers Found',
                      style: TextStyle(fontFamily: 'Headway', 
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Try resetting filters or searching for another expertise.',
                      style:
                          GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B1E1E),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedCategory = 'All Astrologers';
                          _selectedTopic = '';
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      },
                      child: const Text('Show All Astrologers',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final a = astrologers[index];
                    return _buildAstrologerCard(a);
                  },
                  childCount: astrologers.length,
                ),
              ),
            ),

          // 8. Bottom Promo Banner ("FIRST CHAT ABSOLUTELY FREE!")
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              child: _buildFreePromoBanner(),
            ),
          ),
        ],
      ),
    );
  }

  /// Top Hero Banner: "Talk to Astrologer" with Astrological OM Wheel
  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFF9ED),
            Color(0xFFFFF0D4),
            Color(0xFFFDE5B5),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE0CE), width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Right-side Astrologer with Laptop & Glowing OM Wheel
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              width: MediaQuery.of(context).size.width * 0.52,
              child: ShaderMask(
                shaderCallback: (rect) => LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.transparent,
                    Colors.white.withValues(alpha: 0.95),
                  ],
                  stops: const [0.0, 0.35],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: AppImage.asset(
                  AppConstants.astroHeroBannerAsset,
                  fit: BoxFit.cover,
                  errorWidget: Container(
                    color: const Color(0xFFFBE4BA),
                  ),
                ),
              ),
            ),

            // Left-side Text Information
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 14, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LocaleService().isHindi ? 'ज्योतिषी से\nबात करें' : 'Talk to\nAstrologer',
                    style: TextStyle(fontFamily: 'Headway', 
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF5A1208),
                      height: 1.15,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.44,
                    child: Text(
                      LocaleService().isHindi
                          ? 'सत्यापित और अनुभवी ज्योतिषियों से अपने जीवन के प्रश्नों का उत्तर पाएं'
                          : 'Get answers to life\'s questions from verified and experienced astrologers',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF4A3830),
                        height: 1.35,
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

  /// Dedicated AI Jyotish Spotlight Banner
  Widget _buildAiJyotishBanner() {
    final isHi = LocaleService().isHindi;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2C0B05),
            Color(0xFF5A1408),
            Color(0xFF8B2510),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x228B1E1E),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Subtle glowing cosmic aura background
            Positioned(
              right: -25,
              top: -25,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFB300).withValues(alpha: 0.12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top badge row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD97706),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome_rounded, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              isHi ? 'एआई ज्योतिषी 24/7' : 'AI JYOTISH 24/7',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A).withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          isHi ? '● तुरंत निःशुल्क उत्तर' : '● Instant Free Answers',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF86EFAC),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Headline
                  Text(
                    isHi
                        ? 'आचार्य एआई ज्योतिषी से तुरंत पूछें ✨'
                        : 'Ask Acharya AI Jyotish ✨',
                    style: TextStyle(fontFamily: 'Headway', 
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFFF3CD),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isHi
                        ? 'कुंडली दोष, करियर, विवाह योग व ग्रह शांति के सटीक वैदिक उपाय पाएं।'
                        : 'Get instant Vedic answers on Kundli Dosha, Career, Marriage & daily remedies.',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Quick Ask Chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildQuickAskChip(
                        isHi ? '🔮 कुंडली दोष व उपाय' : '🔮 Kundli Doshas',
                        isHi ? 'मेरी कुंडली के मुख्य ग्रह दोष और उपाय' : 'What are the main doshas in my Kundli?',
                      ),
                      _buildQuickAskChip(
                        isHi ? '💼 करियर व नौकरी' : '💼 Career & Job',
                        isHi ? 'नौकरी और करियर में तरक्की कब होगी?' : 'When will my career and job prospects improve?',
                      ),
                      _buildQuickAskChip(
                        isHi ? '❤️ विवाह योग' : '❤️ Marriage Yoga',
                        isHi ? 'विवाह योग और मांगलिक दोष निवारण' : 'Marriage prospects and Manglik dosha remedies',
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD97706),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => _openAiJyotishModal(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            isHi ? 'एआई ज्योतिषी से निःशुल्क पूछें →' : 'Chat with AI Jyotish (FREE) →',
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
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

  Widget _buildQuickAskChip(String label, String query) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openAiJyotishModal(query),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFFFE082),
          ),
        ),
      ),
    );
  }

  Widget _buildAstrologerAvatar(Map<String, dynamic> a) {
    if (a['isAi'] == true) {
      return Container(
        width: 68,
        height: 68,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFD54F), Color(0xFFD97706), Color(0xFF91240D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Text('🔮', style: TextStyle(fontSize: 34)),
        ),
      );
    }
    final avatarUrl = a['avatarUrl']?.toString() ?? '';
    final imageAsset = a['imageAsset']?.toString() ?? AppConstants.astroRajeshAsset;

    return AppImage(
      imageUrl: (avatarUrl.isNotEmpty && (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')))
          ? avatarUrl
          : null,
      assetPath: imageAsset,
      width: 68,
      height: 68,
      fit: BoxFit.cover,
      errorWidget: Container(
        width: 68,
        height: 68,
        color: const Color(0xFFFBEBC7),
        child: const Center(
          child: Text('🧘‍♂️', style: TextStyle(fontSize: 30)),
        ),
      ),
    );
  }

  /// Individual Astrologer Card with clean 2-tier layout, no text truncation, and dedicated action bar
  Widget _buildAstrologerCard(Map<String, dynamic> a) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openAstrologerDetail(a),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDE4D4), width: 1.1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // ─── Top Info Section (Avatar + Astrologer Details) ───
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Left Avatar with Online Dot & Rating Badge below
                  Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: _buildAstrologerAvatar(a),
                          ),
                          if (a['isOnline'] == true)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: 13,
                                height: 13,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22C55E),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Rating Pill under avatar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 13),
                            const SizedBox(width: 2),
                            Text(
                              a['rating']?.toString() ?? '4.8',
                              style: GoogleFonts.poppins(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 12),

                  // 2. Right/Center Details (Takes full remaining width!)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Row: Badge + Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Badge (e.g. "🏆 Top Rated")
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFFFEDD5)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    a['badgeIcon'] as IconData? ?? Icons.star_rounded,
                                    size: 11,
                                    color: const Color(0xFFC2410C),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    a['badge']?.toString() ?? 'Top Rated',
                                    style: GoogleFonts.poppins(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFC2410C),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Online Status Text
                            if (a['isOnline'] == true)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF22C55E),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Online',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF16A34A),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Full Astrologer Name (No truncation!)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                a['name']?.toString() ?? 'Vedic Astrologer',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1E1B18),
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified_rounded,
                              color: Color(0xFF2563EB),
                              size: 15,
                            ),
                          ],
                        ),

                        const SizedBox(height: 3),

                        // Specialties
                        Text(
                          a['specialties']?.toString() ?? 'Vedic Astrology',
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF6B5E55),
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // Experience + Languages Row
                        Row(
                          children: [
                            const Icon(Icons.work_history_outlined, size: 12, color: Color(0xFF8C7E74)),
                            const SizedBox(width: 3),
                            Text(
                              a['experience']?.toString() ?? '10+ Years Experience',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6B5E55),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('•', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 10)),
                            const SizedBox(width: 8),
                            const Icon(Icons.translate_rounded, size: 12, color: Color(0xFF8C7E74)),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                a['languages']?.toString() ?? 'Hindi, English',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B5E55),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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

            // ─── Divider between info and actions ───
            const Divider(height: 1, color: Color(0xFFF3ECE0), thickness: 1),

            // ─── Bottom Action Bar (Price on left, Call & Chat on right) ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Price section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            a['price']?.toString() ?? '₹ 22/min',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF7A0C16),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            a['originalPrice']?.toString() ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              color: const Color(0xFF9CA3AF),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                      if (a['reviews'] != null && a['reviews'].toString().isNotEmpty)
                        Text(
                          '${a['reviews']}',
                          style: GoogleFonts.poppins(
                            fontSize: 9.5,
                            color: const Color(0xFF9E8E82),
                          ),
                        ),
                    ],
                  ),

                  // Action Buttons
                  if (a['isAi'] == true)
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _openAiJyotishModal(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD97706), Color(0xFF91240D)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x35D97706),
                              blurRadius: 5,
                              offset: Offset(0, 1.5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              LocaleService().isHindi ? 'एआई चैट (निःशुल्क) →' : 'Chat with AI (FREE) →',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Call Button
                        InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => _startConsultation(a, isVideo: false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBF4EA),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFE2C9A5),
                                width: 1.1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.phone_in_talk_rounded,
                                  size: 15,
                                  color: Color(0xFF8B2510),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  LocaleService().isHindi ? 'कॉल' : 'Call',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF8B2510),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // "FREE Chat →" Button
                        InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => _startChatConsultation(a),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF581C87), Color(0xFF3B0764)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x28581C87),
                                  blurRadius: 4,
                                  offset: Offset(0, 1.5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.chat_bubble_rounded,
                                  size: 13,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  LocaleService().isHindi ? 'मुफ्त चैट' : 'FREE Chat',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 12,
                                  color: Colors.white,
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

  /// Bottom Promo Banner: "FIRST CHAT ABSOLUTELY FREE!"
  Widget _buildFreePromoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFDE68A),
            Color(0xFFFCD34D),
            Color(0xFFFBBF24),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18B45309),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // 3D Gift Box 🎁
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33DC2626),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text('🎁', style: TextStyle(fontSize: 24)),
            ),
          ),

          const SizedBox(width: 12),

          // Promo Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LocaleService().isHindi ? 'पहली चैट बिल्कुल मुफ्त!' : 'FIRST CHAT ABSOLUTELY FREE!',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF7F1D1D),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  LocaleService().isHindi
                      ? 'हमारे अनुभवी ज्योतिषियों से परामर्श लें'
                      : 'Talk to our experienced astrologers',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF4A3830),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Purple Button: "FREE Chat →"
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              if (_allAstrologers.isNotEmpty) {
                _startChatConsultation(_allAstrologers[0]);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF581C87), Color(0xFF3B0764)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33581C87),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LocaleService().isHindi ? 'मुफ्त चैट' : 'FREE Chat',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 13, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
