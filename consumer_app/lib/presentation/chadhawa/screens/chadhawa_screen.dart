import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/api_service.dart';
import '../../../services/devotee_data_service.dart';
import '../../shop/screens/prasad_orders_screen.dart';
import 'chadhawa_booking_view_screen.dart';
import '../../common/widgets/mandirm_header.dart';
import '../../common/widgets/faq_section.dart';
import '../../common/widgets/app_image.dart';
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

  // 2. Popular Chadava Cards (Enriched across Shiva, Vishnu, Ganesh, Hanuman, Devi)
  final List<Map<String, dynamic>> _popularChadavas = [
    {
      'id': 'CHD-01',
      'title': 'Mahakal Special Chadava',
      'title_hi': 'महाकाल विशेष चढ़ावा',
      'location': 'Ujjain, Madhya Pradesh',
      'location_hi': 'उज्जैन, मध्य प्रदेश',
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
      'title_hi': 'विष्णु सहस्रनाम पाठ चढ़ावा',
      'location': 'Tirupati, Andhra Pradesh',
      'location_hi': 'तिरुपति, आंध्र प्रदेश',
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
      'title_hi': 'गणेश विशेष चढ़ावा',
      'location': 'Siddhivinayak, Mumbai',
      'location_hi': 'सिद्धिविनायक, मुंबई',
      'rating': '4.8',
      'reviews': '8,760',
      'price': 351,
      'isMostPopular': false,
      'asset': AppConstants.chadavaCardGaneshAsset,
      'category': 'ganesh',
      'includes': ['Fresh Durva Grass', 'Modak Bhog', 'Red Sandalwood Tilak'],
    },
    {
      'id': 'CHD-04',
      'title': 'Kashi Vishwanath Rudra Chadava',
      'title_hi': 'काशी विश्वनाथ रुद्राभिषेक चढ़ावा',
      'location': 'Varanasi, Uttar Pradesh',
      'location_hi': 'वाराणसी, उत्तर प्रदेश',
      'rating': '4.9',
      'reviews': '15,200',
      'price': 301,
      'isMostPopular': true,
      'asset': AppConstants.chadavaTempleKashiAsset,
      'category': 'shiva',
      'includes': ['108 Bilva Patra', 'Pure Gangajal', 'Kashi Sanctum Aarti'],
    },
    {
      'id': 'CHD-05',
      'title': 'Sankat Mochan Sindoor & Chola',
      'title_hi': 'संकट मोचन सिंदूर व चोला अर्पण',
      'location': 'Varanasi, Uttar Pradesh',
      'location_hi': 'वाराणसी, उत्तर प्रदेश',
      'rating': '4.9',
      'reviews': '11,100',
      'price': 201,
      'isMostPopular': false,
      'asset': AppConstants.chadavaCatHanumanAsset,
      'category': 'hanuman',
      'includes': ['Desi Ghee Chola', 'Chameli Oil Deepam', 'Hanuman Chalisa Path'],
    },
    {
      'id': 'CHD-06',
      'title': 'Kamakhya Devi Chunri & Kumkum',
      'title_hi': 'कामाख्या देवी चुनरी एवं कुमकुम अर्पण',
      'location': 'Guwahati, Assam',
      'location_hi': 'गुवाहाटी, असम',
      'rating': '4.9',
      'reviews': '7,650',
      'price': 351,
      'isMostPopular': false,
      'asset': AppConstants.chadavaCatDeviAsset,
      'category': 'devi',
      'includes': ['Red Rakt Vastra', 'Siddh Sindoor', 'Shakti Peeth Aarti'],
    },
    {
      'id': 'CHD-07',
      'title': 'Kedarnath Dham Akhand Deepam',
      'title_hi': 'केदारनाथ धाम अखंड दीप अर्पण',
      'location': 'Kedarnath, Uttarakhand',
      'location_hi': 'केदारनाथ, उत्तराखंड',
      'rating': '5.0',
      'reviews': '18,400',
      'price': 501,
      'isMostPopular': true,
      'asset': AppConstants.chadavaTempleKedarnathAsset,
      'category': 'shiva',
      'includes': ['Akhand Ghee Diya', 'Himalayan Flowers', 'Shiva Sankalp'],
    },
    {
      'id': 'CHD-08',
      'title': 'Banke Bihari Makhan Misri Bhog',
      'title_hi': 'बांके बिहारी माखन मिश्री भोग चढ़ावा',
      'location': 'Vrindavan, Uttar Pradesh',
      'location_hi': 'वृंदावन, उत्तर प्रदेश',
      'rating': '4.9',
      'reviews': '14,300',
      'price': 251,
      'isMostPopular': false,
      'asset': AppConstants.chadavaTypeSweetAsset,
      'category': 'vishnu',
      'includes': ['Fresh Makhan Bhog', 'Tulsi Dal Arpan', 'Vrindavan Ashirwad'],
    },
  ];

  // 3. Types of Chadava (8 items)
  List<Map<String, dynamic>> get _chadavaTypes {
    final isHi = LocaleService().isHindi;
    return [
      {
        'id': 'type_flower',
        'title': isHi ? 'पुष्प अर्पण' : 'Flower Offering',
        'desc': isHi ? 'पवित्र ताजे पुष्प व सुगंधित माला' : 'Fresh fragrant garlands & flowers',
        'priceText': isHi ? '₹ 51 से' : 'From ₹ 51',
        'amount': 51,
        'asset': AppConstants.chadavaTypeFlowerAsset,
      },
      {
        'id': 'type_coconut',
        'title': isHi ? 'श्रीफल अर्पण' : 'Coconut Offering',
        'desc': isHi ? 'शुभ कार्य सिद्धि हेतु पवित्र श्रीफल' : 'Auspicious sacred coconut for wish fulfillment',
        'priceText': isHi ? '₹ 101 से' : 'From ₹ 101',
        'amount': 101,
        'asset': AppConstants.chadavaTypeCoconutAsset,
      },
      {
        'id': 'type_sweet',
        'title': isHi ? 'मिष्ठान अर्पण' : 'Sweet Offering',
        'desc': isHi ? 'पवित्र मोदक, पेड़ा व माखन भोग' : 'Sanctified modak, peda & bhog sweets',
        'priceText': isHi ? '₹ 151 से' : 'From ₹ 151',
        'amount': 151,
        'asset': AppConstants.chadavaTypeSweetAsset,
      },
      {
        'id': 'type_lamp',
        'title': isHi ? 'घृत दीप अर्पण' : 'Ghee Lamp',
        'desc': isHi ? 'अखंड ज्योति व देशी घी का दीपक' : 'Akhand pure cow ghee deepam',
        'priceText': isHi ? '₹ 51 से' : 'From ₹ 51',
        'amount': 51,
        'asset': AppConstants.chadavaTypeLampAsset,
      },
      {
        'id': 'type_rudraksha',
        'title': isHi ? 'रुद्राक्ष माला' : 'Rudraksha Mala',
        'desc': isHi ? 'पंचमुखी सिद्ध रुद्राक्ष माला अर्पण' : 'Consecrated 5-mukhi holy rudraksha mala',
        'priceText': isHi ? '₹ 251 से' : 'From ₹ 251',
        'amount': 251,
        'asset': AppConstants.chadavaTypeRudrakshaAsset,
      },
      {
        'id': 'type_vastra',
        'title': isHi ? 'वस्त्र अर्पण' : 'Vastra Offering',
        'desc': isHi ? 'पीतांबर व माता की लाल चुनरी' : 'Sacred pitambar or red mata chunri',
        'priceText': isHi ? '₹ 251 से' : 'From ₹ 251',
        'amount': 251,
        'asset': AppConstants.chadavaTypeVastraAsset,
      },
      {
        'id': 'type_sindoor',
        'title': isHi ? 'सिंदूर व चोला' : 'Sindoor & Chola',
        'desc': isHi ? 'हनुमान जी को पवित्र चोला व सिंदूर' : 'Sacred vermilion & chola for Hanuman Ji',
        'priceText': isHi ? '₹ 201 से' : 'From ₹ 201',
        'amount': 201,
        'asset': AppConstants.chadavaCatHanumanAsset,
      },
      {
        'id': 'type_panchamrit',
        'title': isHi ? 'पंचामृत अभिषेक' : 'Panchamrit Seva',
        'desc': isHi ? 'दूध, दही, घी, शहद व गंगाजल' : 'Holy milk, curd, honey, ghee & gangajal',
        'priceText': isHi ? '₹ 351 से' : 'From ₹ 351',
        'amount': 351,
        'asset': AppConstants.chadavaCardMahakalAsset,
      },
    ];
  }

  // 4. Popular Temples (8 items)
  final List<Map<String, dynamic>> _popularTemples = [
    {
      'id': 'temple_mahakal',
      'name': 'Mahakaleshwar',
      'name_hi': 'महाकालेश्वर',
      'location': 'Ujjain, MP',
      'asset': AppConstants.chadavaTempleMahakalAsset,
      'category': 'shiva',
      'deity': 'Lord Shiva (Mahakal)',
    },
    {
      'id': 'temple_kashi',
      'name': 'Kashi Vishwanath',
      'name_hi': 'काशी विश्वनाथ',
      'location': 'Varanasi, UP',
      'asset': AppConstants.chadavaTempleKashiAsset,
      'category': 'shiva',
      'deity': 'Lord Shiva (Vishwanath)',
    },
    {
      'id': 'temple_kedarnath',
      'name': 'Kedarnath',
      'name_hi': 'केदारनाथ',
      'location': 'Uttarakhand',
      'asset': AppConstants.chadavaTempleKedarnathAsset,
      'category': 'shiva',
      'deity': 'Lord Shiva (Kedarnath)',
    },
    {
      'id': 'temple_tirupati',
      'name': 'Tirupati Balaji',
      'name_hi': 'तिरुपति बालाजी',
      'location': 'Andhra Pradesh',
      'asset': AppConstants.chadavaTempleTirupatiAsset,
      'category': 'vishnu',
      'deity': 'Lord Venkateswara',
    },
    {
      'id': 'temple_siddhivinayak',
      'name': 'Siddhivinayak',
      'name_hi': 'सिद्धिविनायक',
      'location': 'Mumbai, MH',
      'asset': AppConstants.chadavaTempleSiddhivinayakAsset,
      'category': 'ganesh',
      'deity': 'Lord Ganesha',
    },
    {
      'id': 'temple_kamakhya',
      'name': 'Kamakhya Devi',
      'name_hi': 'कामाख्या देवी',
      'location': 'Guwahati, Assam',
      'asset': AppConstants.chadavaCatDeviAsset,
      'category': 'devi',
      'deity': 'Maa Kamakhya Shakti',
    },
    {
      'id': 'temple_rammandir',
      'name': 'Ayodhya Ram Mandir',
      'name_hi': 'अयोध्या राम मंदिर',
      'location': 'Ayodhya, UP',
      'asset': AppConstants.chadavaCatVishnuAsset,
      'category': 'vishnu',
      'deity': 'Bhagwan Shri Ram',
    },
    {
      'id': 'temple_mehandipur',
      'name': 'Mehandipur Balaji',
      'name_hi': 'मेहंदीपुर बालाजी',
      'location': 'Dausa, Rajasthan',
      'asset': AppConstants.chadavaCatHanumanAsset,
      'category': 'hanuman',
      'deity': 'Shri Hanuman Ji',
    },
  ];

  /// Sheet 1: All Popular Chadavas with interactive category filters
  void _openAllPopularChadavasSheet() {
    int activeFilterIndex = _selectedCategoryIndex;
    final isHi = LocaleService().isHindi;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            List<Map<String, dynamic>> items = _popularChadavas;
            if (activeFilterIndex > 0) {
              final cat = _categories[activeFilterIndex]['id'] as String;
              items = _popularChadavas.where((c) => c['category'] == cat).toList();
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Color(0xFFFBF8F3),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isHi ? 'सभी लोकप्रिय चढ़ावा' : 'All Popular Chadavas',
                              style: GoogleFonts.marcellus(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: _primaryMaroon,
                              ),
                            ),
                            Text(
                              isHi ? 'पवित्र मंदिरों में संकल्प के साथ चढ़ावा अर्पित करें' : 'Sanctified offerings across holy temples',
                              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 22),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      children: List.generate(_categories.length, (i) {
                        final cat = _categories[i];
                        final bool isSel = activeFilterIndex == i;
                        final String titleClean = (cat['title'] as String).replaceAll('\n', ' ');
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            label: Text(
                              titleClean,
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                color: isSel ? Colors.white : _darkCharcoal,
                              ),
                            ),
                            selected: isSel,
                            selectedColor: _primaryMaroon,
                            backgroundColor: Colors.white,
                            checkmarkColor: Colors.white,
                            side: BorderSide(
                              color: isSel ? _primaryMaroon : const Color(0xFFDECDB4),
                            ),
                            onSelected: (val) {
                              setModalState(() {
                                activeFilterIndex = i;
                              });
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                  Expanded(
                    child: items.isEmpty
                        ? Center(
                            child: Text(
                              isHi ? 'इस श्रेणी में कोई चढ़ावा उपलब्ध नहीं है' : 'No Chadavas in this category',
                              style: GoogleFonts.poppins(color: Colors.grey.shade600),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                            physics: const BouncingScrollPhysics(),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _cardBorder),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.brown.withAlpha(8),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: AppImage.asset(
                                        item['asset'] as String,
                                        width: 72,
                                        height: 72,
                                        fit: BoxFit.cover,
                                        errorWidget: const Icon(Icons.temple_hindu, color: _primaryMaroon, size: 30),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (isHi ? item['title_hi'] : null) as String? ?? item['title'] as String,
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: _darkCharcoal,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            (isHi ? item['location_hi'] : null) as String? ?? item['location'] as String,
                                            style: GoogleFonts.poppins(
                                              fontSize: 10.5,
                                              color: Colors.grey.shade600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.star_rounded, size: 13, color: Color(0xFFFFB300)),
                                              const SizedBox(width: 2),
                                              Text(
                                                '${item['rating']}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                '₹${item['price']}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w800,
                                                  color: _primaryMaroon,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _primaryMaroon,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        _openBookingModal(item);
                                      },
                                      child: Text(
                                        isHi ? 'अर्पित करें' : 'Offer',
                                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
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

  /// Sheet 2: All Types of Chadava
  void _openAllChadavaTypesSheet() {
    final isHi = LocaleService().isHindi;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Color(0xFFFBF8F3),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHi ? 'चढ़ावा के सभी प्रकार' : 'All Types of Chadava',
                          style: GoogleFonts.marcellus(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _primaryMaroon,
                          ),
                        ),
                        Text(
                          isHi ? 'पवित्र अर्पण सामग्री चुनें' : 'Select sacred offering items for sanctum seva',
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(14),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _chadavaTypes.length,
                  itemBuilder: (context, index) {
                    final type = _chadavaTypes[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.withAlpha(8),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 60,
                              height: 60,
                              color: const Color(0xFFFAFAFA),
                              child: AppImage.asset(
                                type['asset'] as String,
                                fit: BoxFit.contain,
                                errorWidget: const Icon(Icons.image, color: Colors.grey),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  type['title'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _darkCharcoal,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  type['desc']?.toString() ?? '',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.5,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  type['priceText'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _primaryMaroon,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryMaroon,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              _openBookingModal(type);
                            },
                            child: Text(
                              isHi ? 'अर्पित करें' : 'Offer',
                              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Sheet 3: All Popular Temples
  void _openAllPopularTemplesSheet() {
    final isHi = LocaleService().isHindi;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Color(0xFFFBF8F3),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHi ? 'सभी प्रसिद्ध मंदिर' : 'All Popular Temples',
                          style: GoogleFonts.marcellus(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _primaryMaroon,
                          ),
                        ),
                        Text(
                          isHi ? 'अपने इष्टदेव के पावन धाम में चढ़ावा अर्पित करें' : 'Holy sanctums welcoming online chadava offerings',
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(14),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _popularTemples.length,
                  itemBuilder: (context, index) {
                    final temple = _popularTemples[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.withAlpha(8),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: AppImage.asset(
                              temple['asset'] as String,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorWidget: const Icon(Icons.temple_hindu, color: _primaryMaroon, size: 30),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (isHi ? temple['name_hi'] : null) as String? ?? temple['name'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _darkCharcoal,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded, size: 12, color: Color(0xFF757575)),
                                    const SizedBox(width: 2),
                                    Text(
                                      temple['location'] as String,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  temple['deity']?.toString() ?? '',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: _primaryMaroon,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryMaroon,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              _openBookingModal(temple);
                            },
                            child: Text(
                              isHi ? 'चढ़ावा दें' : 'Offer',
                              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Sheet 4: Special Chadava Packages
  void _openSpecialPackagesSheet() {
    final isHi = LocaleService().isHindi;
    final List<Map<String, dynamic>> packages = [
      {
        'id': 'PKG-01',
        'title': isHi ? 'सम्पूर्ण परिवार सुख-शांति पैकेज' : 'Sampurna Parivar Sukh Shanti Seva',
        'location': 'Mahakaleshwar & Kashi Sanctum',
        'price': 1100,
        'asset': AppConstants.chadavaPackagesBannerAsset,
        'features': [
          isHi ? 'अखंड घृत दीप प्रज्वलन' : 'Akhand Pure Ghee Deepam',
          isHi ? 'परिवार के सभी सदस्यों का गोत्र संकल्प' : 'Gotra Sankalp for whole family',
          isHi ? 'पवित्र श्रीफल, पुष्प माला व पंचामृत भोग' : 'Sacred Shrifal, Garlands & Panchamrit',
          isHi ? 'व्हाट्सएप पर 1 मिनट का विशेष वीडियो दर्शन' : '1-Min Personalized Aarti Video Clip on WhatsApp',
        ],
      },
      {
        'id': 'PKG-02',
        'title': isHi ? 'महारुद्र शांति एवं संरक्षण पैकेज' : 'Maha Rudra Shanti & Protection Seva',
        'location': 'Shri Kedarnath & Mahakal Jyotirlinga',
        'price': 501,
        'asset': AppConstants.chadavaCardMahakalAsset,
        'features': [
          isHi ? '108 बेलपत्र अर्पण' : '108 Sacred Bilva Patra Offering',
          isHi ? 'भस्म व धतूरा अर्पण' : 'Sacred Bhasma & Dhatura Offering',
          isHi ? 'रुद्र गायत्री महामंत्र उच्चारण' : 'Rudra Gayatri Chanting with devotee Gotra',
        ],
      },
      {
        'id': 'PKG-03',
        'title': isHi ? 'नवग्रह दोष निवारण एवं समृद्धि पैकेज' : 'Navgraha Dosha Nivaran Seva',
        'location': 'Tirupati Balaji Sanctum',
        'price': 751,
        'asset': AppConstants.chadavaCardVishnuAsset,
        'features': [
          isHi ? 'नवधान्य एवं सरसों तेल दीप अर्पण' : '9-Grain Offering & Mustard Oil Lamp',
          isHi ? 'पीतांबर वस्त्र अर्पण' : 'Pitambar Vastra Offering',
          isHi ? 'संकल्पित रक्षा सूत्र प्रसाद' : 'Sanctified Raksha Sutra Blessing',
        ],
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Color(0xFFFBF8F3),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHi ? 'विशेष चढ़ावा पैकेज' : 'Special Chadava Packages',
                          style: GoogleFonts.marcellus(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _primaryMaroon,
                          ),
                        ),
                        Text(
                          isHi ? 'पारिवारिक सुख, शांति एवं ग्रह निवारण हेतु' : 'Comprehensive family & planetary prosperity seva',
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(14),
                  physics: const BouncingScrollPhysics(),
                  itemCount: packages.length,
                  itemBuilder: (context, index) {
                    final pkg = packages[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFFD54F)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.withAlpha(10),
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
                              Expanded(
                                child: Text(
                                  pkg['title'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _primaryMaroon,
                                  ),
                                ),
                              ),
                              Text(
                                '₹${pkg['price']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFC62828),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.temple_hindu, size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                pkg['location'] as String,
                                style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...((pkg['features'] as List<String>).map((f) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF2E7D32)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        f,
                                        style: GoogleFonts.poppins(fontSize: 11, color: _darkCharcoal),
                                      ),
                                    ),
                                  ],
                                ),
                              ))),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 38,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryMaroon,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                _openBookingModal(pkg);
                              },
                              child: Text(
                                isHi ? 'यह पैकेज बुक करें • ₹${pkg['price']}' : 'Book This Package • ₹${pkg['price']}',
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Sheet 5: Trust & Assurance Info
  void _openTrustInfoSheet(int initialTab) {
    final isHi = LocaleService().isHindi;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_user_rounded, color: _primaryMaroon, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        isHi ? 'मंदिरम् विश्वसनीयता एवं संकल्प' : 'Mandirm Trust Assurance',
                        style: GoogleFonts.marcellus(fontSize: 17, fontWeight: FontWeight.w700, color: _primaryMaroon),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 16),
              _buildTrustItem(
                Icons.verified_user_outlined,
                isHi ? '100% सुरक्षित एवं प्रामाणिक' : '100% Safe & Sanctified',
                isHi ? 'सभी अनुष्ठान एवं चढ़ावा प्राचीन सनातन नियमों के अनुसार संपन्न कराए जाते हैं।' : 'All rituals follow strict Sanatan Vedic traditions.',
              ),
              const SizedBox(height: 12),
              _buildTrustItem(
                Icons.spa_outlined,
                isHi ? 'सत्यापित मंदिर एवं आचार्य' : 'Verified Sanctums & Priests',
                isHi ? 'मंदिरम्-सत्यापित मुख्य आचार्यों द्वारा आपके नाम-गोत्र का शुद्ध उच्चारण किया जाता है।' : 'Conducted only by verified purohits with authentic gotra recitation.',
              ),
              const SizedBox(height: 12),
              _buildTrustItem(
                Icons.video_camera_back_outlined,
                isHi ? 'व्हाट्सएप पर वीडियो साक्ष्य' : 'WhatsApp Video Proof',
                isHi ? 'अर्पण का व्यक्तिगत 30-सेकंड वीडियो व्हाट्सएप पर सीधे आपके नंबर पर प्रेषित किया जाता है।' : 'Personalized video proof delivered straight to your WhatsApp after Aarti.',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryMaroon,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    isHi ? 'समझ गए • हर हर महादेव' : 'Understood • Har Har Mahadev',
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrustItem(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _primaryMaroon, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w700, color: _darkCharcoal),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ],
    );
  }

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
                          child: AppImage.asset(
                            item['asset'] as String,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorWidget: const Icon(
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
                          'asset': item['asset'] ?? AppConstants.chadavaCardMahakalAsset,
                          'type': 'chadhawa',
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

                        // Navigate immediately to dedicated View Page!
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChadhawaBookingViewScreen(
                              booking: bookingData,
                              onBrowsePujas: widget.onBrowsePujas,
                            ),
                          ),
                        );

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
                                    builder: (_) => ChadhawaBookingViewScreen(
                                      booking: bookingData,
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

              const SizedBox(height: 16),

              // 9. FAQ Section
              const FaqSection(serviceType: 'chadhawa'),

              const SizedBox(height: 32),
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
          AppImage.asset(
            AppConstants.chadavaHeroBannerAsset,
            width: double.infinity,
            fit: BoxFit.fitWidth,
            errorWidget: Container(
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
          _buildTrustBadgeItem(
            Icons.verified_user_outlined,
            isHi ? 'सुरक्षित एवं\nविश्वसनीय' : 'Safe & Secure\nOfferings',
            onTap: () => _openTrustInfoSheet(0),
          ),
          _buildTrustBadgeItem(
            Icons.spa_outlined,
            isHi ? 'प्रामाणिक मंदिर\nएवं पुजारी' : 'Authentic Temples\n& Priests',
            onTap: () => _openTrustInfoSheet(1),
          ),
          _buildTrustBadgeItem(
            Icons.video_camera_back_outlined,
            isHi ? 'तुरंत वीडियो एवं\nफोटो साक्ष्य' : 'Instant Photos/\nVideos of Offerings',
            onTap: () => _openTrustInfoSheet(2),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadgeItem(IconData icon, String text, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
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
      ),
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
                            child: AppImage.asset(
                              cat['asset'] as String,
                              fit: BoxFit.cover,
                              errorWidget: Container(
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
                onTap: _openAllPopularChadavasSheet,
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

              return GestureDetector(
                onTap: () => _openBookingModal(item),
                child: Container(
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
                          child: AppImage.asset(
                            item['asset'] as String,
                            width: double.infinity,
                            height: 104,
                            fit: BoxFit.cover,
                            errorWidget: Container(
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
                            (LocaleService().isHindi ? item['title_hi'] : null) as String? ??
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
                                  (LocaleService().isHindi ? item['location_hi'] : null) as String? ??
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
              GestureDetector(
                onTap: _openAllChadavaTypesSheet,
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
                          child: AppImage.asset(
                            type['asset'] as String,
                            fit: BoxFit.contain,
                            errorWidget: const Icon(
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
              GestureDetector(
                onTap: _openAllPopularTemplesSheet,
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
                        child: AppImage.asset(
                          temple['asset'] as String,
                          width: double.infinity,
                          height: 64,
                          fit: BoxFit.cover,
                          errorWidget: Container(
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
          onTap: _openSpecialPackagesSheet,
          child: AppImage.asset(
            AppConstants.chadavaPackagesBannerAsset,
            width: double.infinity,
            fit: BoxFit.cover,
            errorWidget: Container(
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
