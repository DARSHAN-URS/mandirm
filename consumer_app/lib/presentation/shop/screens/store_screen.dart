import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/locale_service.dart';
import '../../../services/api_service.dart';
import '../../../services/devotee_data_service.dart';
import 'prasad_orders_screen.dart';
import 'product_detail_screen.dart';
import '../../common/widgets/mandirm_header.dart';

class StoreScreen extends StatefulWidget {
  final VoidCallback? onBrowsePujas;
  const StoreScreen({super.key, this.onBrowsePujas});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedCategoryIndex = 0;
  final Set<String> _favoriteProductIds = {};
  int _cartCount = 0;
  final List<Map<String, dynamic>> _cartItems = [];

  // Color Palette matching screenshot
  static const Color _primaryMaroon = Color(0xFF7A0C16);
  static const Color _darkCharcoal = Color(0xFF2C2C2C);
  static const Color _subtleGrey = Color(0xFF757575);
  static const Color _cardBgLight = Color(0xFFFFFBF5);
  static const Color _cardBorder = Color(0xFFEFE6D8);
  static const Color _accentYellow = Color(0xFFFDCB06);

  // Dynamic Categories list matching reference and language
  List<Map<String, dynamic>> get _categories {
    final isHi = LocaleService().isHindi;
    return [
      {
        'id': 'all',
        'title': isHi ? 'सभी\nश्रेणियां' : 'All\nCategories',
        'asset': AppConstants.catAllAsset,
        'isGridIcon': true,
      },
      {
        'id': 'idols',
        'title': isHi ? 'अभिमंत्रित\nमूर्तियां' : 'Mantra\nEnergized Idols',
        'asset': AppConstants.catIdolsAsset,
        'isGridIcon': false,
      },
      {
        'id': 'samagri',
        'title': isHi ? 'पूजा\nसामग्री' : 'Puja\nSamagri',
        'asset': AppConstants.catSamagriAsset,
        'isGridIcon': false,
      },
      {
        'id': 'yantra',
        'title': isHi ? 'यंत्र\nव रत्न' : 'Yantra\n& Ratna',
        'asset': AppConstants.catYantraAsset,
        'isGridIcon': false,
      },
      {
        'id': 'dhoop',
        'title': isHi ? 'धूप व\nअगरबत्ती' : 'Dhoop &\nAgarbatti',
        'asset': AppConstants.catDhoopAsset,
        'isGridIcon': false,
      },
      {
        'id': 'essentials',
        'title': isHi ? 'पूजा\nसामग्री' : 'Puja\nEssentials',
        'asset': AppConstants.catEssentialsAsset,
        'isGridIcon': false,
      },
      {
        'id': 'vrat',
        'title': isHi ? 'व्रत व\nत्योहार' : 'Vrat &\nFestival Items',
        'asset': AppConstants.catVratAsset,
        'isGridIcon': false,
      },
      {
        'id': 'books',
        'title': isHi ? 'धार्मिक\nपुस्तकें' : 'Spiritual\nBooks',
        'asset': AppConstants.catBooksAsset,
        'isGridIcon': false,
      },
    ];
  }

  // Popular Deity Idols with dynamic localization
  List<Map<String, dynamic>> get _deityIdols {
    final isHi = LocaleService().isHindi;
    return [
      {
        'id': 'deity_ganesha',
        'name': isHi ? 'भगवान गणेश\nमूर्तियां' : 'Lord Ganesha\nIdols',
        'asset': AppConstants.deityGaneshaAsset,
        'category': 'idols',
      },
      {
        'id': 'deity_krishna',
        'name': isHi ? 'भगवान कृष्ण\nमूर्तियां' : 'Lord Krishna\nIdols',
        'asset': AppConstants.deityKrishnaAsset,
        'category': 'idols',
      },
      {
        'id': 'deity_shiva',
        'name': isHi ? 'भगवान शिव\nमूर्तियां' : 'Lord Shiva\nIdols',
        'asset': AppConstants.deityShivaAsset,
        'category': 'idols',
      },
      {
        'id': 'deity_lakshmi',
        'name': isHi ? 'मां लक्ष्मी\nमूर्तियां' : 'Goddess Lakshmi\nIdols',
        'asset': AppConstants.deityLakshmiAsset,
        'category': 'idols',
      },
      {
        'id': 'deity_samagri',
        'name': isHi ? 'पूजा थाली\nव सामग्री' : 'Puja Samagri\nSets',
        'asset': AppConstants.deitySamagriAsset,
        'category': 'samagri',
      },
      {
        'id': 'deity_rudraksha',
        'name': isHi ? 'सिद्ध रुद्राक्ष\nमाला' : 'Rudraksha\nMala',
        'asset': AppConstants.deityRudrakshaAsset,
        'category': 'essentials',
      },
    ];
  }

  // Featured Products matching reference screenshot
  final List<Map<String, dynamic>> _featuredProducts = [
    {
      'id': 'FP-01',
      'title': 'Lord Ganesha Idol',
      'subtitle': '5 inch (Brass)',
      'price': 1299,
      'originalPrice': 1699,
      'badge': 'Bestseller',
      'badgeBg': const Color(0xFFFFE082),
      'badgeText': const Color(0xFF4A3000),
      'asset': AppConstants.prodGaneshaAsset,
      'category': 'idols',
      'mandir': 'Siddhivinayak Sanctum Blessed',
      'rating': 4.9,
      'reviews': 428,
      'description':
          'Handcrafted 5-inch pure brass Lord Ganesha Idol, energized with sacred Ganapati Atharvashirsha Vedic chanting. Bestows wisdom, auspicious prosperity, and removes obstacles.',
    },
    {
      'id': 'FP-02',
      'title': 'Rudraksha Mala',
      'subtitle': '108 Beads',
      'price': 599,
      'originalPrice': 799,
      'badge': 'Popular',
      'badgeBg': const Color(0xFFD32F2F),
      'badgeText': Colors.white,
      'asset': AppConstants.prodRudrakshaAsset,
      'category': 'essentials',
      'mandir': 'Kashi Vishwanath Consecrated',
      'rating': 4.9,
      'reviews': 612,
      'description':
          'Authentic 5-Mukhi Nepali Rudraksha Mala with 108+1 consecrated beads and sacred red tassel. Energized through Vedic Maha Rudra Abhishekam at holy Kashi.',
    },
    {
      'id': 'FP-03',
      'title': 'Puja Thali Set',
      'subtitle': '7 Pieces (Brass)',
      'price': 899,
      'originalPrice': 1299,
      'badge': null,
      'asset': AppConstants.prodThaliAsset,
      'category': 'samagri',
      'mandir': 'Ayodhya Ram Janmabhoomi Blessed',
      'rating': 4.8,
      'reviews': 319,
      'description':
          'Complete 7-piece premium brass Puja Thali set including Diya, Agarbatti stand, Ghanti (bell), Panchamrit bowl, and sacred ritual spoon for daily home worship.',
    },
    {
      'id': 'FP-04',
      'title': 'Om Wall Plate',
      'subtitle': '8 inch',
      'price': 649,
      'originalPrice': 999,
      'badge': null,
      'asset': AppConstants.prodOmPlateAsset,
      'category': 'essentials',
      'mandir': 'Haridwar Ganga Sanctum Blessed',
      'rating': 4.8,
      'reviews': 245,
      'description':
          'Sacred 8-inch Om Wall Plate crafted with antique golden brass finish and cosmic Vedic symmetry. Radiates positive vibrations, protection, and spiritual calm.',
    },
  ];

  // Festival Specials
  List<Map<String, dynamic>> get _festivalSpecials {
    final isHi = LocaleService().isHindi;
    return [
      {
        'id': 'fest_navratri',
        'title': isHi ? 'नवरात्रि' : 'Navratri',
        'subtitle': isHi ? 'विशेष पूजा सामग्री' : 'Special Puja Samagri',
        'asset': AppConstants.festNavratriAsset,
        'bgGradient': const [Color(0xFF7A0C16), Color(0xFF4A050B)],
        'category': 'samagri',
      },
      {
        'id': 'fest_diwali',
        'title': isHi ? 'दीपावली' : 'Diwali',
        'subtitle': isHi ? 'पूजा एवं सजावट सामग्री' : 'Puja & Decoration Items',
        'asset': AppConstants.festDiwaliAsset,
        'bgGradient': const [Color(0xFF7A3E09), Color(0xFF4A2403)],
        'category': 'essentials',
      },
      {
        'id': 'fest_shivratri',
        'title': isHi ? 'महाशिवरात्रि' : 'Shivratri',
        'subtitle': isHi ? 'विशेष पूजा सामग्री' : 'Special Puja Samagri',
        'asset': AppConstants.festShivratriAsset,
        'bgGradient': const [Color(0xFF132B45), Color(0xFF091624)],
        'category': 'idols',
      },
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleFavorite(String productId) {
    setState(() {
      if (_favoriteProductIds.contains(productId)) {
        _favoriteProductIds.remove(productId);
      } else {
        _favoriteProductIds.add(productId);
      }
    });
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      _cartCount++;
      final existingIndex =
          _cartItems.indexWhere((item) => item['id'] == product['id']);
      if (existingIndex >= 0) {
        _cartItems[existingIndex]['qty'] =
            (_cartItems[existingIndex]['qty'] as int) + 1;
      } else {
        _cartItems.add({
          ...product,
          'qty': 1,
        });
      }
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Added ${product['title']} to Puja Cart',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                _openCartModal();
              },
              child: Text(
                'VIEW CART',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _accentYellow,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: _primaryMaroon,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _openCartModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final int totalPayable = _cartItems.fold<int>(
              0,
              (sum, item) => sum + ((item['price'] as int) * (item['qty'] as int)),
            );

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.shopping_cart_outlined,
                                color: _primaryMaroon, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              'Puja Store Cart ($_cartCount items)',
                              style: GoogleFonts.cinzel(
                                fontSize: 17,
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
                  ),
                  const Divider(height: 1),

                  // Items list
                  Expanded(
                    child: _cartItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.remove_shopping_cart_outlined,
                                    size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text(
                                  'Your sacred cart is empty',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Explore consecrated idols & sacred puja samagri',
                                  style: GoogleFonts.poppins(
                                      fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _cartItems.length,
                            separatorBuilder: (_, __) => const Divider(height: 20),
                            itemBuilder: (context, idx) {
                              final item = _cartItems[idx];
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      color: _cardBgLight,
                                      child: Image.asset(
                                        item['asset'] as String,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(
                                            Icons.shopping_bag_outlined,
                                            color: _primaryMaroon),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title'] as String,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                            color: _darkCharcoal,
                                          ),
                                        ),
                                        Text(
                                          item['subtitle'] as String,
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: _subtleGrey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '₹${item['price']}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: _primaryMaroon,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Quantity controller
                                  Row(
                                    children: [
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        icon: const Icon(Icons.remove_circle_outline,
                                            size: 20, color: _primaryMaroon),
                                        onPressed: () {
                                          setModalState(() {
                                            if (item['qty'] > 1) {
                                              item['qty']--;
                                              _cartCount--;
                                            } else {
                                              _cartItems.removeAt(idx);
                                              _cartCount--;
                                            }
                                          });
                                          setState(() {});
                                        },
                                      ),
                                      Text(
                                        '${item['qty']}',
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600, fontSize: 13),
                                      ),
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        icon: const Icon(Icons.add_circle_outline,
                                            size: 20, color: _primaryMaroon),
                                        onPressed: () {
                                          setModalState(() {
                                            item['qty']++;
                                            _cartCount++;
                                          });
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                  ),

                  // Bottom Checkout Bar
                  if (_cartItems.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 10,
                            offset: const Offset(0, -3),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Payable',
                                      style: GoogleFonts.poppins(
                                          fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                    Text(
                                      '₹$totalPayable',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: _primaryMaroon,
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primaryMaroon,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 28, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    _proceedToCheckout(_cartItems.first);
                                  },
                                  child: Row(
                                    children: [
                                      Text(
                                        'Checkout',
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600, fontSize: 14),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.arrow_forward_rounded, size: 16),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
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

  void _openProductDetailModal(Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          initialProduct: product,
          onBrowsePujas: widget.onBrowsePujas,
        ),
      ),
    );
  }

  void _proceedToCheckout(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final addressController = TextEditingController(
          text: 'Flat 402, Shanti Vihar, Mumbai, Maharashtra 400050',
        );

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sacred Order Checkout 📦',
                    style: GoogleFonts.cinzel(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _primaryMaroon,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Delivery Address',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.location_on_outlined, color: _primaryMaroon),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Item Total', style: GoogleFonts.poppins(fontSize: 13)),
                        Text('₹${product['price']}',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Vedic Consecration & Packing',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey.shade700)),
                        Text('FREE',
                            style: GoogleFonts.poppins(
                                color: AppColors.success, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Doorstep SpeedPost Courier',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey.shade700)),
                        Text('FREE',
                            style: GoogleFonts.poppins(
                                color: AppColors.success, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Payable',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('₹${product['price']}',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: _primaryMaroon)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryMaroon,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch % 100000}';
                    final trackingNo = 'BLUEDART-${DateTime.now().millisecondsSinceEpoch % 9000000}';

                    final orderData = {
                      'id': orderId,
                      'title': product['title'],
                      'mandir': product['mandir'] ?? 'Mandirm Divine Store',
                      'orderDate': 'Today, Just Now',
                      'status': 'Processing',
                      'currentStep': 0,
                      'trackingNumber': trackingNo,
                      'carrier': 'BlueDart Express',
                      'expectedDelivery': 'In 2-3 Days',
                      'address': addressController.text.trim(),
                    };

                    DevoteeDataService().addPrasadOrder(orderData);
                    DevoteeDataService().addBooking({
                      'id': orderId,
                      'title': product['title'],
                      'mandir': product['mandir'],
                      'date': 'Today, Just Now',
                      'amount': '₹${product['price']}',
                      'status': 'Confirmed',
                      'gotra': 'Devotee Gotra',
                      'devoteeName': 'Sunil Kumar',
                      'pandit': 'Mandirm Store Sanctum',
                      'prasadTracking': trackingNo,
                      'prasadStatus': 'Processing Consecration',
                    });

                    // Persist to FastAPI backend
                    ApiService().placeOrder({
                      'product_id': product['id'] ?? 'prod_custom',
                      'quantity': 1,
                      'total_amount': product['price'],
                      'shipping_address': addressController.text.trim(),
                    }).catchError((e) {
                      debugPrint('[StoreScreen] Backend note: $e');
                      return null;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                  'Order Placed! Holy item will be consecrated and shipped in 24h.'),
                            ),
                          ],
                        ),
                        action: SnackBarAction(
                          label: 'TRACK',
                          textColor: const Color(0xFFFDCB06),
                          onPressed: () {
                            _openMyOrders();
                          },
                        ),
                        backgroundColor: AppColors.success,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  },
                  child: Text('Confirm Order • Pay ₹${product['price']}',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _openMyOrders();
                  },
                  icon: const Icon(Icons.history_rounded, size: 16, color: _primaryMaroon),
                  label: Text(
                    'View My Prasad & Store Orders',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _primaryMaroon,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
    // Filter products based on search and category
    List<Map<String, dynamic>> displayedProducts = _featuredProducts;
    if (_searchQuery.isNotEmpty) {
      displayedProducts = displayedProducts.where((p) {
        final title = (p['title'] as String).toLowerCase();
        final subtitle = (p['subtitle'] as String).toLowerCase();
        final q = _searchQuery.toLowerCase();
        return title.contains(q) || subtitle.contains(q);
      }).toList();
    } else if (_selectedCategoryIndex > 0) {
      final selectedCategory = _categories[_selectedCategoryIndex]['id'] as String;
      final categoryProducts =
          displayedProducts.where((p) => p['category'] == selectedCategory).toList();
      if (categoryProducts.isNotEmpty) {
        displayedProducts = categoryProducts;
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

              // 2. Hero Banner ("Mantra Energized Divine Idols")
              _buildHeroBanner(),

              // 3. Trust Badges Row (Pure & Sacred, Mantra Energized, Authentic & Genuine)
              _buildTrustBadgesRow(),

              // 4. Search and Filter Bar
              _buildSearchBar(),

              // 5. Category Icons (Horizontal scroll with 8 items)
              _buildCategoryRow(),

              const SizedBox(height: 12),

              // 6. Section: "Popular Deity Idols" (View All →)
              _buildPopularDeitySection(),

              const SizedBox(height: 16),

              // 7. Middle Crimson Promo Banner
              _buildMiddlePromoBanner(),

              const SizedBox(height: 16),

              // 8. Section: "Featured Products" (View All →)
              _buildFeaturedProductsSection(displayedProducts),

              const SizedBox(height: 16),

              // 9. Section: "Festival Specials" (View All →)
              _buildFestivalSpecialsSection(),

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
        onTap: _openCartModal,
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

  /// 2. Hero Banner: Mantra Energized Divine Idols
  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      child: Stack(
        children: [
          // Banner Image
          Image.asset(
            AppConstants.storeHeroCropAsset,
            width: double.infinity,
            fit: BoxFit.fitWidth,
            errorBuilder: (_, __, ___) => Container(
              height: 160,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  'Mantra Energized Divine Idols',
                  style: GoogleFonts.marcellus(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _primaryMaroon,
                  ),
                ),
              ),
            ),
          ),

          // Invisible touch area on Shop Now button region to trigger action
          Positioned(
            left: 16,
            bottom: 24,
            child: GestureDetector(
              onTap: () {
                _openProductDetailModal(_featuredProducts[0]);
              },
              child: Container(
                color: Colors.transparent,
                width: 110,
                height: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Trust Badges Row (Pure & Sacred, Mantra Energized, Authentic & Genuine)
  Widget _buildTrustBadgesRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTrustItem(Icons.local_florist_outlined, 'Pure & Sacred'),
          _buildTrustItem(Icons.verified_user_outlined, 'Mantra Energized'),
          _buildTrustItem(Icons.star_border_rounded, 'Authentic & Genuine'),
        ],
      ),
    );
  }

  Widget _buildTrustItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _primaryMaroon, size: 14),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: _darkCharcoal,
          ),
        ),
      ],
    );
  }

  /// 4. Rounded Search & Filter Bar
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5DDD0), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(
            Icons.search_rounded,
            color: Color(0xFF757575),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() => _searchQuery = val);
              },
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: _darkCharcoal,
              ),
              decoration: InputDecoration(
                hintText: LocaleService().isHindi
                    ? 'पूजा सामग्री, मूर्तियां, यंत्र आदि खोजें...'
                    : 'Search for puja samagri, idols, yantra, or any product...',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 11.5,
                  color: const Color(0xFF8E8E93),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.close_rounded, size: 16, color: Colors.grey),
              ),
            ),
          // Filter / Slider icon
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Filters: Brass Idols, Consecrated Malas, Hawan Samagri',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Icon(
                Icons.tune_rounded,
                color: Color(0xFF2C2C2C),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 5. Horizontal Categories Row with 8 Circular Items
  Widget _buildCategoryRow() {
    return Container(
      height: 96,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final bool isSelected = _selectedCategoryIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
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

  /// 6. Popular Deity Idols Section
  Widget _buildPopularDeitySection() {
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
                LocaleService().isHindi ? 'लोकप्रिय देव मूर्तियां' : 'Popular Deity Idols',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _primaryMaroon,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() => _selectedCategoryIndex = 1);
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

        // Horizontal List of Deity Cards
        SizedBox(
          height: 116,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _deityIdols.length,
            itemBuilder: (context, index) {
              final deity = _deityIdols[index];
              return GestureDetector(
                onTap: () {
                  // Filter or show product
                  final match = _featuredProducts.firstWhere(
                    (p) => p['category'] == deity['category'],
                    orElse: () => _featuredProducts[0],
                  );
                  _openProductDetailModal(match);
                },
                child: Container(
                  width: 82,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _cardBgLight,
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
                      // Deity Image
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(10)),
                        child: Container(
                          width: double.infinity,
                          height: 70,
                          color: const Color(0xFFFFFDF8),
                          child: Image.asset(
                            deity['asset'] as String,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.image, color: Colors.grey, size: 28),
                            ),
                          ),
                        ),
                      ),
                      // Deity Name
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Text(
                              deity['name'] as String,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: _darkCharcoal,
                                height: 1.15,
                              ),
                            ),
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

  /// 7. Middle Crimson Promo Banner
  Widget _buildMiddlePromoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GestureDetector(
          onTap: () {
            _openProductDetailModal(_featuredProducts[0]);
          },
          child: Image.asset(
            AppConstants.storePromoBannerAsset,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7A0C16), Color(0xFF52070D)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.temple_hindu_rounded,
                      color: _accentYellow, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Mantra Energized Divine Idols',
                          style: GoogleFonts.marcellus(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Bring divinity & prosperity home',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
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

  /// 8. Featured Products Section
  Widget _buildFeaturedProductsSection(List<Map<String, dynamic>> products) {
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
                LocaleService().isHindi ? 'विशेष उत्पाद' : 'Featured Products',
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

        // Horizontal List of 4 Product Cards
        SizedBox(
          height: 235,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final prod = products[index];
              final bool isFav = _favoriteProductIds.contains(prod['id']);

              return GestureDetector(
                onTap: () => _openProductDetailModal(prod),
                child: Container(
                  width: 142,
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
                      // Product Image & Badges
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(10)),
                            child: Container(
                              width: double.infinity,
                              height: 105,
                              color: const Color(0xFFFAFAFA),
                              child: Image.asset(
                                prod['asset'] as String,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.image,
                                      color: Colors.grey, size: 36),
                                ),
                              ),
                            ),
                          ),
                          // Heart / Favorite Icon
                          Positioned(
                            top: 6,
                            right: 6,
                            child: GestureDetector(
                              onTap: () => _toggleFavorite(prod['id'] as String),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(230),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(15),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isFav
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: isFav ? Colors.red : Colors.grey.shade600,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                          // Badge if available (Bestseller, Popular)
                          if (prod['badge'] != null)
                            Positioned(
                              bottom: 4,
                              left: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: prod['badgeBg'] as Color,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  prod['badge'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                    color: prod['badgeText'] as Color,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Product Details
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prod['title'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: _darkCharcoal,
                              ),
                            ),
                            Text(
                              prod['subtitle'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: _subtleGrey,
                              ),
                            ),
                            const SizedBox(height: 3),
                            // Price
                            Row(
                              children: [
                                Text(
                                  '₹ ${prod['price']}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: _darkCharcoal,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '₹ ${prod['originalPrice']}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 9.5,
                                    color: Colors.grey.shade500,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Add to Cart Button (Red filled)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        child: SizedBox(
                          width: double.infinity,
                          height: 28,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8E161B),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: () => _addToCart(prod),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.shopping_cart_outlined, size: 13),
                                const SizedBox(width: 4),
                                Text(
                                  LocaleService().isHindi ? 'कार्ट में जोड़ें' : 'Add to Cart',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
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
            },
          ),
        ),
      ],
    );
  }

  /// 9. Festival Specials Section (Navratri, Diwali, Shivratri)
  Widget _buildFestivalSpecialsSection() {
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
                LocaleService().isHindi ? 'त्योहार विशेष सामग्री' : 'Festival Specials',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _primaryMaroon,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() => _selectedCategoryIndex = 6);
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

        // Horizontal list of Festival Cards
        SizedBox(
          height: 86,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _festivalSpecials.length,
            itemBuilder: (context, index) {
              final fest = _festivalSpecials[index];
              return GestureDetector(
                onTap: () {
                  final match = _featuredProducts.firstWhere(
                    (p) => p['category'] == fest['category'],
                    orElse: () => _featuredProducts[0],
                  );
                  _openProductDetailModal(match);
                },
                child: Container(
                  width: 170,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      fest['asset'] as String,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: fest['bgGradient'] as List<Color>,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              fest['title'] as String,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              fest['subtitle'] as String,
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 9.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _accentYellow,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Shop Now →',
                                style: TextStyle(
                                  fontSize: 8.5,
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
            },
          ),
        ),
      ],
    );
  }
}
