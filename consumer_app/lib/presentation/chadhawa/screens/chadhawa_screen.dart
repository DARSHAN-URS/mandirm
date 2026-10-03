import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/api_service.dart';
import '../../../services/devotee_data_service.dart';
import '../../bookings/screens/bookings_screen.dart';
import '../../shop/screens/prasad_orders_screen.dart';
import '../../common/widgets/mandirm_header.dart';
import '../../../core/l10n/locale_service.dart';

class ChadhawaScreen extends StatefulWidget {
  final VoidCallback? onBrowsePujas;
  const ChadhawaScreen({super.key, this.onBrowsePujas});

  @override
  State<ChadhawaScreen> createState() => _ChadhawaScreenState();
}

class _ChadhawaScreenState extends State<ChadhawaScreen> {
  int _selectedCategoryIndex = 0;
  int _cartCount = 0;

  // Visual Colors matching screenshot
  static const Color _primaryMaroon = Color(0xFF7A0C16);
  static const Color _darkCharcoal = Color(0xFF1E1E1E);
  static const Color _cardBorder = Color(0xFFEFE6D8);
  static const Color _accentYellow = Color(0xFFFDCB06);

  // 1. Categories (7 Circular Items)
  List<Map<String, dynamic>> get _categories {
    final isHi = LocaleService().isHindi;
    return [
      {
        'id': 'all',
        'title': isHi ? 'सभी\nचढ़ावा' : 'All\nChadava',
        'asset': AppConstants.chadavaCatAllAsset,
        'isGridIcon': true,
      },
      {
        'id': 'shiva',
        'title': isHi ? 'शिव\nमंदिर' : 'Shiva\nTemple',
        'asset': AppConstants.chadavaCatShivaAsset,
        'isGridIcon': false,
      },
      {
        'id': 'vishnu',
        'title': isHi ? 'विष्णु\nमंदिर' : 'Vishnu\nTemple',
        'asset': AppConstants.chadavaCatVishnuAsset,
        'isGridIcon': false,
      },
      {
        'id': 'hanuman',
        'title': isHi ? 'हनुमान\nमंदिर' : 'Hanuman\nTemple',
        'asset': AppConstants.chadavaCatHanumanAsset,
        'isGridIcon': false,
      },
      {
        'id': 'devi',
        'title': isHi ? 'देवी\nमंदिर' : 'Devi\nTemple',
        'asset': AppConstants.chadavaCatDeviAsset,
        'isGridIcon': false,
      },
      {
        'id': 'ganesh',
        'title': isHi ? 'गणेश\nमंदिर' : 'Ganesh\nTemple',
        'asset': AppConstants.chadavaCatGaneshAsset,
        'isGridIcon': false,
      },
      {
        'id': 'other',
        'title': isHi ? 'अन्य\nमंदिर' : 'Other\nTemples',
        'asset': AppConstants.chadavaCatOtherAsset,
        'isGridIcon': false,
      },
    ];
  }

  // 2. Popular Chadava Cards
  final List<Map<String, dynamic>> _popularChadavas = [
    {
      'id': 'CHD-01',
      'title': 'Mahakal Special Chadava',
      'location': 'Ujjain, Madhya Pradesh',
      'rating': '4.9',
      'reviews': '12,450',
      'price': 251,
      'isMostPopular': true,
      'asset': AppConstants.chadavaCardMahakalAsset,
      'category': 'shiva',
      'includes': ['Bhasma Aarti Darshan', 'Gotra Sankalp Path', 'Desi Ghee Lamp'],
    },
    {
      'id': 'CHD-02',
      'title': 'Vishnu Sahasranam Path Chadava',
      'location': 'Tirupati, Andhra Pradesh',
      'rating': '4.8',
      'reviews': '9,820',
      'price': 501,
      'isMostPopular': false,
      'asset': AppConstants.chadavaCardVishnuAsset,
      'category': 'vishnu',
      'includes': ['Pitambar Vastra', 'Tulsi Garlands', 'Laddu Prasad Dispatch'],
    },
    {
      'id': 'CHD-03',
      'title': 'Ganesh Special Chadava',
      'location': 'Siddhivinayak, Mumbai',
      'rating': '4.8',
      'reviews': '8,760',
      'price': 351,
      'isMostPopular': false,
      'asset': AppConstants.chadavaCardGaneshAsset,
      'category': 'ganesh',
      'includes': ['Fresh Durva Grass', 'Modak Bhog', 'Red Sandalwood Tilak'],
    },
  ];

  // 3. Types of Chadava (6 items)
  List<Map<String, dynamic>> get _chadavaTypes {
    final isHi = LocaleService().isHindi;
    return [
      {
        'id': 'type_flower',
        'title': isHi ? 'पुष्प अर्पण' : 'Flower Offering',
        'priceText': isHi ? '₹ 51 से' : 'From ₹ 51',
        'amount': 51,
        'asset': AppConstants.chadavaTypeFlowerAsset,
      },
      {
        'id': 'type_coconut',
        'title': isHi ? 'श्रीफल अर्पण' : 'Coconut Offering',
        'priceText': isHi ? '₹ 101 से' : 'From ₹ 101',
        'amount': 101,
        'asset': AppConstants.chadavaTypeCoconutAsset,
      },
      {
        'id': 'type_sweet',
        'title': isHi ? 'मिष्ठान अर्पण' : 'Sweet Offering',
        'priceText': isHi ? '₹ 151 से' : 'From ₹ 151',
        'amount': 151,
        'asset': AppConstants.chadavaTypeSweetAsset,
      },
      {
        'id': 'type_lamp',
        'title': isHi ? 'घृत दीप अर्पण' : 'Ghee Lamp',
        'priceText': isHi ? '₹ 51 से' : 'From ₹ 51',
        'amount': 51,
        'asset': AppConstants.chadavaTypeLampAsset,
      },
      {
        'id': 'type_rudraksha',
        'title': isHi ? 'रुद्राक्ष माला' : 'Rudraksha Mala',
        'priceText': isHi ? '₹ 251 से' : 'From ₹ 251',
        'amount': 251,
        'asset': AppConstants.chadavaTypeRudrakshaAsset,
      },
      {
        'id': 'type_vastra',
        'title': isHi ? 'वस्त्र अर्पण' : 'Vastra Offering',
        'priceText': isHi ? '₹ 251 से' : 'From ₹ 251',
        'amount': 251,
        'asset': AppConstants.chadavaTypeVastraAsset,
      },
    ];
  }

  // 4. Popular Temples (5 items)
  final List<Map<String, dynamic>> _popularTemples = [
    {
      'id': 'temple_mahakal',
      'name': 'Mahakaleshwar',
      'location': 'Ujjain, MP',
      'asset': AppConstants.chadavaTempleMahakalAsset,
      'category': 'shiva',
    },
    {
      'id': 'temple_kashi',
      'name': 'Kashi Vishwanath',
      'location': 'Varanasi, UP',
      'asset': AppConstants.chadavaTempleKashiAsset,
      'category': 'shiva',
    },
    {
      'id': 'temple_kedarnath',
      'name': 'Kedarnath',
      'location': 'Uttarakhand',
      'asset': AppConstants.chadavaTempleKedarnathAsset,
      'category': 'shiva',
    },
    {
      'id': 'temple_tirupati',
      'name': 'Tirupati Balaji',
      'location': 'Andhra Pradesh',
      'asset': AppConstants.chadavaTempleTirupatiAsset,
      'category': 'vishnu',
    },
    {
      'id': 'temple_siddhivinayak',
      'name': 'Siddhivinayak',
      'location': 'Mumbai, MH',
      'asset': AppConstants.chadavaTempleSiddhivinayakAsset,
      'category': 'ganesh',
    },
  ];

  void _openBookingModal(Map<String, dynamic> item) {
    final nameController = TextEditingController(text: 'Sunil Kumar');
    final gotraController = TextEditingController(text: 'Kashyap');
    int selectedAmount = (item['price'] ?? item['amount'] ?? 251) as int;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Close
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.volunteer_activism_rounded,
                              color: _primaryMaroon, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Offer Sacred Chadava',
                            style: GoogleFonts.cinzel(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _primaryMaroon,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 22),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 16),

                  // Selected item info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9ED),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFE0B2)),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            item['asset'] as String,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.temple_hindu_rounded,
                                color: _primaryMaroon),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] ?? item['name'] ?? 'Sacred Chadava',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: _darkCharcoal,
                                ),
                              ),
                              Text(
                                item['location'] ?? 'Vedic Temple Sanctum',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.brown.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Devotee Name
                  Text(
                    'Devotee Name (for Temple Sankalp)',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline, color: _primaryMaroon),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Gotra
                  Text(
                    'Gotra (Family Lineage)',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: gotraController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.family_restroom_rounded,
                          color: _primaryMaroon),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Amount Options
                  Text(
                    'Offering Seva Amount',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [51, 101, 251, 501].map((amt) {
                      final bool isSel = selectedAmount == amt;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() => selectedAmount = amt);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel ? _primaryMaroon : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSel ? _primaryMaroon : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              '₹$amt',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isSel ? Colors.white : _darkCharcoal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  // WhatsApp Video Assurance
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.videocam_outlined,
                            color: Color(0xFF2E7D32), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Video of Chadava recitation will be shared on WhatsApp',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF1B5E20),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryMaroon,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() => _cartCount++);

                        final bookingId = 'CHD-${DateTime.now().millisecondsSinceEpoch % 100000}';
                        final bookingData = {
                          'id': bookingId,
                          'title': item['title'] ?? item['name'] ?? 'Sacred Chadava',
                          'mandir': item['location'] ?? 'Vedic Temple Sanctum',
                          'date': 'Today, Upcoming Aarti',
                          'amount': '₹$selectedAmount',
                          'status': 'Confirmed',
                          'gotra': gotraController.text,
                          'devoteeName': nameController.text,
                          'pandit': 'Mandirm Verified Temple Priest',
                          'prasadTracking': 'WHATSAPP-CLIP-PENDING',
                          'prasadStatus': 'Sankalp Scheduled',
                        };

                        DevoteeDataService().addBooking(bookingData);

                        // Persist to FastAPI backend with safe fallback
                        ApiService().createBooking({
                          'chadhawa_id': item['id'] ?? 'chd_custom',
                          'amount': selectedAmount,
                          'devotee_name': nameController.text,
                          'gotra': gotraController.text,
                          'temple_name': item['location'] ?? 'Vedic Temple Sanctum',
                          'date': 'Today, Upcoming Aarti',
                        }).catchError((e) {
                          debugPrint('[ChadhawaScreen] Backend note: $e');
                          return null;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Chadava booked for ${nameController.text} (₹$selectedAmount)!',
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            action: SnackBarAction(
                              label: 'VIEW',
                              textColor: const Color(0xFFFDCB06),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BookingsScreen(
                                      onBrowsePujas: widget.onBrowsePujas,
                                    ),
                                  ),
                                );
                              },
                            ),
                            backgroundColor: AppColors.success,
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      },
                      child: Text(
                        'Offer Chadava • ₹$selectedAmount',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openMyOrders() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrasadOrdersScreen(onBrowsePujas: widget.onBrowsePujas),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    // Filter popular chadava based on category
    List<Map<String, dynamic>> displayedChadavas = _popularChadavas;
    if (_selectedCategoryIndex > 0) {
      final selectedCat = _categories[_selectedCategoryIndex]['id'] as String;
      final filtered =
          _popularChadavas.where((c) => c['category'] == selectedCat).toList();
      if (filtered.isNotEmpty) {
        displayedChadavas = filtered;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F3), // Warm cream background from screenshot
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Custom App Bar
              _buildTopAppBar(),

              // 2. Hero Banner ("Offer Chadava From Home")
              _buildHeroBanner(),

              // 3. Trust Badges Row (Safe & Secure, Authentic Temples, Instant Photos/Videos)
              _buildTrustBadgesRow(),

              const SizedBox(height: 8),

              // 4. Horizontal Categories Row (7 Circular Items)
              _buildCategoryRow(),

              const SizedBox(height: 14),

              // 5. Section: "Popular Chadava" (View All →)
              _buildPopularChadavaSection(displayedChadavas),

              const SizedBox(height: 16),

              // 6. Section: "Types of Chadava" (View All →)
              _buildTypesOfChadavaSection(),

              const SizedBox(height: 16),

              // 7. Section: "Popular Temples" (View All →)
              _buildPopularTemplesSection(),

              const SizedBox(height: 16),

              // 8. Bottom Promo Banner: "Special Chadava Packages"
              _buildSpecialPackagesBanner(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// 1. Unified Mandirm Header (same header across entire app)
  Widget _buildTopAppBar() {
    return MandirmHeader(
      trailing: GestureDetector(
        onTap: _openMyOrders,
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
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                color: _primaryMaroon,
                size: 19,
              ),
              if (_cartCount > 0)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD32F2F),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    child: Text(
                      '$_cartCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
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

  /// 2. Hero Banner: Offer Chadava From Home
  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      child: Stack(
        children: [
          // Banner Image
          Image.asset(
            AppConstants.chadavaHeroBannerAsset,
            width: double.infinity,
            fit: BoxFit.fitWidth,
            errorBuilder: (_, __, ___) => Container(
              height: 160,
              color: const Color(0xFFFFF9ED),
              child: Center(
                child: Text(
                  'Offer Chadava From Home',
                  style: GoogleFonts.marcellus(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _primaryMaroon,
                  ),
                ),
              ),
            ),
          ),

          // Touch area on "Offer Now →" button region
          Positioned(
            left: 20,
            bottom: 28,
            child: GestureDetector(
              onTap: () {
                _openBookingModal(_popularChadavas[0]);
              },
              child: Container(
                width: 120,
                height: 36,
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Trust Badges Row (Safe & Secure, Authentic Temples, Instant Photos/Videos)
  Widget _buildTrustBadgesRow() {
    final isHi = LocaleService().isHindi;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTrustBadgeItem(Icons.verified_user_outlined, isHi ? 'सुरक्षित एवं\nविश्वसनीय' : 'Safe & Secure\nOfferings'),
          _buildTrustBadgeItem(Icons.spa_outlined, isHi ? 'प्रामाणिक मंदिर\nएवं पुजारी' : 'Authentic Temples\n& Priests'),
          _buildTrustBadgeItem(
              Icons.video_camera_back_outlined, isHi ? 'तुरंत वीडियो एवं\nफोटो साक्ष्य' : 'Instant Photos/\nVideos of Offerings'),
        ],
      ),
    );
  }

  Widget _buildTrustBadgeItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _primaryMaroon, size: 16),
        const SizedBox(width: 5),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: _darkCharcoal,
            height: 1.15,
          ),
        ),
      ],
    );
  }

  /// 4. Horizontal Categories Row (7 Circular Items)
  Widget _buildCategoryRow() {
    return Container(
      height: 94,
      margin: const EdgeInsets.only(top: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final bool isSelected = _selectedCategoryIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategoryIndex = index);
            },
            child: Container(
              width: 58,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  // Circular Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? const Color(0xFFC62828) : Colors.transparent,
                        width: 2.0,
                      ),
                    ),
                    child: cat['isGridIcon'] == true
                        ? Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFC62828),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.grid_view_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          )
                        : ClipOval(
                            child: Image.asset(
                              cat['asset'] as String,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFFFFF3E0),
                                child: const Icon(Icons.circle,
                                    color: _primaryMaroon, size: 20),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 5),

                  // Label
                  Expanded(
                    child: Text(
                      cat['title'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? const Color(0xFFC62828) : _darkCharcoal,
                        height: 1.15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 5. Popular Chadava Section
  Widget _buildPopularChadavaSection(List<Map<String, dynamic>> chadavas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocaleService().isHindi ? 'लोकप्रिय चढ़ावा' : 'Popular Chadava',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _primaryMaroon,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() => _selectedCategoryIndex = 0);
                },
                child: Row(
                  children: [
                    Text(
                      LocaleService().isHindi ? 'सभी देखें' : 'View All',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _primaryMaroon,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.arrow_forward_rounded,
                        size: 13, color: _primaryMaroon),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Horizontal List of 3 Popular Chadava Cards
        SizedBox(
          height: 228,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: chadavas.length,
            itemBuilder: (context, index) {
              final item = chadavas[index];

              return Container(
                width: 175,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _cardBorder, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withAlpha(12),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image with Most Popular Badge
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(10)),
                          child: Image.asset(
                            item['asset'] as String,
                            width: double.infinity,
                            height: 104,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 104,
                              color: const Color(0xFFFAFAFA),
                              child: const Icon(Icons.temple_hindu,
                                  color: Colors.grey, size: 36),
                            ),
                          ),
                        ),
                        if (item['isMostPopular'] == true)
                          Positioned(
                            top: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD54F),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                LocaleService().isHindi ? 'सर्वाधिक लोकप्रिय' : 'Most Popular',
                                style: GoogleFonts.poppins(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF332000),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Details
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: _darkCharcoal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  size: 11, color: Color(0xFF757575)),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  item['location'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 9.5,
                                    color: const Color(0xFF757575),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 13, color: Color(0xFFFFB300)),
                              const SizedBox(width: 2),
                              Text(
                                '${item['rating']} (${item['reviews']})',
                                style: GoogleFonts.poppins(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF616161),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Price & Offer Now Button Row
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹ ${item['price']}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: _darkCharcoal,
                            ),
                          ),
                          SizedBox(
                            height: 28,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8E161B),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () => _openBookingModal(item),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    LocaleService().isHindi ? 'चढ़ावा अर्पित करें' : 'Offer Now',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(Icons.arrow_forward_rounded,
                                      size: 11),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 6. Types of Chadava Section (6 Offering Types)
  Widget _buildTypesOfChadavaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocaleService().isHindi ? 'चढ़ावा के प्रकार' : 'Types of Chadava',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _primaryMaroon,
                ),
              ),
              Row(
                children: [
                  Text(
                    LocaleService().isHindi ? 'सभी देखें' : 'View All',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _primaryMaroon,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 13, color: _primaryMaroon),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Horizontal List of 6 Offering Types
        SizedBox(
          height: 112,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _chadavaTypes.length,
            itemBuilder: (context, index) {
              final type = _chadavaTypes[index];

              return GestureDetector(
                onTap: () => _openBookingModal(type),
                child: Container(
                  width: 86,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _cardBorder, width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.brown.withAlpha(10),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10)),
                        child: Container(
                          width: double.infinity,
                          height: 62,
                          color: const Color(0xFFFAFAFA),
                          child: Image.asset(
                            type['asset'] as String,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.image,
                                color: Colors.grey,
                                size: 24),
                          ),
                        ),
                      ),
                      // Title & Price
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 2, vertical: 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                type['title'] as String,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: _darkCharcoal,
                                ),
                              ),
                              Text(
                                type['priceText'] as String,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  color: _primaryMaroon,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 7. Popular Temples Section (5 Temples)
  Widget _buildPopularTemplesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocaleService().isHindi ? 'प्रसिद्ध मंदिर' : 'Popular Temples',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _primaryMaroon,
                ),
              ),
              Row(
                children: [
                  Text(
                    LocaleService().isHindi ? 'सभी देखें' : 'View All',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _primaryMaroon,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 13, color: _primaryMaroon),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Horizontal List of 5 Temples
        SizedBox(
          height: 112,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _popularTemples.length,
            itemBuilder: (context, index) {
              final temple = _popularTemples[index];

              return GestureDetector(
                onTap: () => _openBookingModal(temple),
                child: Container(
                  width: 98,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _cardBorder, width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.brown.withAlpha(10),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Temple Image
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10)),
                        child: Image.asset(
                          temple['asset'] as String,
                          width: double.infinity,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 64,
                            color: const Color(0xFFFAFAFA),
                            child: const Icon(Icons.temple_hindu,
                                color: Colors.grey, size: 24),
                          ),
                        ),
                      ),
                      // Temple Name & Location
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 2, vertical: 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                temple['name'] as String,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: _darkCharcoal,
                                ),
                              ),
                              Text(
                                temple['location'] as String,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 8.5,
                                  color: const Color(0xFF757575),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 8. Bottom Promo Banner: Special Chadava Packages
  Widget _buildSpecialPackagesBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GestureDetector(
          onTap: () {
            _openBookingModal(_popularChadavas[0]);
          },
          child: Image.asset(
            AppConstants.chadavaPackagesBannerAsset,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 70,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFD54F)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department_rounded,
                      color: Color(0xFFE65100), size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Special Chadava Packages',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: _primaryMaroon,
                          ),
                        ),
                        Text(
                          'For family happiness and prosperity',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.brown.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _accentYellow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Explore Packages →',
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
