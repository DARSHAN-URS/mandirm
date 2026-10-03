import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/api_service.dart';
import '../../../services/devotee_data_service.dart';
import 'prasad_orders_screen.dart';
import '../../common/widgets/mandirm_header.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? initialProduct;
  final VoidCallback? onBrowsePujas;

  const ProductDetailScreen({
    super.key,
    this.initialProduct,
    this.onBrowsePujas,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedThumbIndex = 0;
  bool _isFavorited = false;
  int _quantity = 1;
  int _cartCount = 0;

  // Primary colors matching reference
  static const Color _primaryMaroon = Color(0xFF7A0C16);
  static const Color _darkCharcoal = Color(0xFF1E1E1E);
  static const Color _accentGold = Color(0xFFFDCB06);
  static const Color _softCream = Color(0xFFFBF8F3);
  static const Color _badgeCream = Color(0xFFFFF9ED);
  static const Color _badgeBorder = Color(0xFFFFE0B2);

  // Gallery Thumbnails matching reference screenshot
  final List<String> _galleryThumbnails = [
    AppConstants.mahakalThumb1Asset,
    AppConstants.mahakalThumb2Asset,
    AppConstants.mahakalThumb3Asset,
    AppConstants.mahakalThumb4Asset,
    AppConstants.mahakalThumb5Asset,
    AppConstants.mahakalThumb6Asset,
    AppConstants.mahakalThumb7Asset,
  ];

  void _shareProduct() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.share_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Sharing Mahakal Trishul Nandi Pendant with Rudraksha Mala link',
                style: GoogleFonts.poppins(fontSize: 12),
              ),
            ),
          ],
        ),
        backgroundColor: _primaryMaroon,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openWhatsAppHelp() {
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF25D366),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mandirm Seva Kendra',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    Text(
                      'Instant WhatsApp Pandit & Order Assistance',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Have queries about bead energization, gotra sankalp, or doorstep delivery for Mahakal Pendant?',
              style: GoogleFonts.poppins(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Connecting to Mandirm Pandit on WhatsApp...'),
                      backgroundColor: Color(0xFF25D366),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  'Chat on WhatsApp (+91 98765 43210)',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart() {
    setState(() => _cartCount += _quantity);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Added $_quantity x Mahakal Trishul Pendant to Sacred Cart!',
                style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w500),
              ),
            ),
            Text(
              'CART ($_cartCount)',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _accentGold,
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

  void _proceedToCheckout() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final addressController = TextEditingController(
          text: 'Flat 402, Shanti Vihar, Mumbai, Maharashtra 400050',
        );
        final int totalAmount = 1149 * _quantity;

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
                        Text('Mahakal Pendant ($_quantity item)',
                            style: GoogleFonts.poppins(fontSize: 13)),
                        Text('₹$totalAmount',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Vedic Consecration & Packing',
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700)),
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
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700)),
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
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('₹$totalAmount',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch % 100000}';
                    final trackingNo = 'BLUEDART-${DateTime.now().millisecondsSinceEpoch % 9000000}';
                    final itemTitle = widget.initialProduct?['title'] ?? 'Mahakal Trishul Nandi Pendant';

                    DevoteeDataService().addPrasadOrder({
                      'id': orderId,
                      'title': itemTitle,
                      'mandir': widget.initialProduct?['mandir'] ?? 'Ujjain Mahakaleshwar Consecrated',
                      'orderDate': 'Today, Just Now',
                      'status': 'Processing',
                      'currentStep': 0,
                      'trackingNumber': trackingNo,
                      'carrier': 'BlueDart Express',
                      'expectedDelivery': 'In 2-3 Days',
                      'address': addressController.text.trim(),
                    });

                    DevoteeDataService().addBooking({
                      'id': orderId,
                      'title': itemTitle,
                      'mandir': 'Ujjain Mahakaleshwar Consecrated',
                      'date': 'Today, Just Now',
                      'amount': '₹$totalAmount',
                      'status': 'Confirmed',
                      'gotra': 'Devotee Gotra',
                      'devoteeName': 'Sunil Kumar',
                      'pandit': 'Mandirm Store Sanctum',
                      'prasadTracking': trackingNo,
                      'prasadStatus': 'Processing Consecration',
                    });

                    // Persist to FastAPI backend
                    ApiService().placeOrder({
                      'product_id': widget.initialProduct?['id'] ?? 'prod_custom',
                      'quantity': _quantity,
                      'total_amount': totalAmount,
                      'shipping_address': addressController.text.trim(),
                    }).catchError((e) {
                      debugPrint('[ProductDetailScreen] Backend note: $e');
                      return null;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                  'Order Placed! Holy $itemTitle will be consecrated & shipped.'),
                            ),
                          ],
                        ),
                        action: SnackBarAction(
                          label: 'TRACK',
                          textColor: const Color(0xFFFDCB06),
                          onPressed: _openMyOrders,
                        ),
                        backgroundColor: AppColors.success,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  },
                  child: Text('Confirm Order • Pay ₹$totalAmount',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top App Bar with back arrow, Mandirm logo, search, cart, overflow menu
            _buildTopAppBar(),

            // 2. Main Scrollable Product Information
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Hero Image with Wishlist & Share buttons
                    _buildHeroImageSection(),

                    // Horizontal Thumbnail strip
                    _buildThumbnailGallery(),

                    const SizedBox(height: 14),

                    // Product Title & Rating
                    _buildTitleAndRating(),

                    const SizedBox(height: 12),

                    // Spiritual Benefit Badges (Builds Steadiness, Blessings of Lord Shiva)
                    _buildSpiritualBenefitBadges(),

                    const SizedBox(height: 14),

                    // Pricing, Discount & WhatsApp Button
                    _buildPriceSection(),

                    const SizedBox(height: 14),

                    // 100% Cashback Offer Banner
                    _buildOfferBanner(),

                    const SizedBox(height: 16),

                    // 4 Trust Guarantees (Free Delivery, COD, Easy Returns, Original & Authentic)
                    _buildGuaranteesRow(),

                    const SizedBox(height: 16),

                    // Mantra Energized & Sanctified Card
                    _buildConsecrationCard(),

                    const SizedBox(height: 20),

                    // Product Details Accordion
                    _buildProductDetailsAccordion(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // 3. Sticky Bottom Bar: [- 1 +] [Add to Cart] [Buy Now]
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  /// 1. Unified Mandirm Header (same header across entire app)
  Widget _buildTopAppBar() {
    return MandirmHeader(
      showBackButton: true,
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

  /// 2. Hero Image with Floating Heart & Share buttons
  Widget _buildHeroImageSection() {
    return Container(
      width: double.infinity,
      color: _softCream,
      child: Stack(
        children: [
          // Main Image (AnimatedSwitcher for smooth thumbnail transition)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Image.asset(
              _galleryThumbnails[_selectedThumbIndex],
              key: ValueKey<int>(_selectedThumbIndex),
              width: double.infinity,
              height: 360,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                AppConstants.mahakalHeroAsset,
                width: double.infinity,
                height: 360,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Floating Action Buttons (Heart Wishlist & Share)
          Positioned(
            top: 14,
            right: 14,
            child: Column(
              children: [
                // Wishlist Button
                GestureDetector(
                  onTap: () {
                    setState(() => _isFavorited = !_isFavorited);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isFavorited
                              ? 'Saved to Sacred Wishlist ❤️'
                              : 'Removed from Sacred Wishlist',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(240),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: _isFavorited ? Colors.red : const Color(0xFF7A0C16),
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Share Button
                GestureDetector(
                  onTap: _shareProduct,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(240),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.share_outlined,
                      color: _darkCharcoal,
                      size: 19,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Thumbnail Gallery Strip (7 items)
  Widget _buildThumbnailGallery() {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _galleryThumbnails.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedThumbIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedThumbIndex = index);
            },
            child: Container(
              width: 54,
              height: 54,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? _primaryMaroon : const Color(0xFFE5DDD0),
                  width: isSelected ? 2.0 : 1.0,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  _galleryThumbnails[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: _softCream,
                    child: const Icon(Icons.image, size: 20, color: Colors.grey),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 4. Product Title & Rating
  Widget _buildTitleAndRating() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Mahakal Trishul Nandi Pendant with Rudraksha Mala - 54+1 Beads',
            style: GoogleFonts.poppins(
              fontSize: 18.5,
              fontWeight: FontWeight.w700,
              color: _darkCharcoal,
              height: 1.28,
            ),
          ),
          const SizedBox(height: 8),

          // Rating Row
          Row(
            children: [
              // 5 Golden Stars
              Row(
                children: List.generate(
                  5,
                  (index) => const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFB300),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '4.8 (67 reviews)',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF616161),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 5. Spiritual Benefit Badges (Builds Steadiness, Blessings of Lord Shiva)
  Widget _buildSpiritualBenefitBadges() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Pill 1: Builds Steadiness
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: _badgeCream,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _badgeBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Red Trishul Symbol
                const Text(
                  '🔱',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 6),
                Text(
                  'Builds Steadiness',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _darkCharcoal,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Pill 2: Blessings of Lord Shiva
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: _badgeCream,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _badgeBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Red Sacred Om Symbol
                const Text(
                  'ॐ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC62828),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Blessings of Lord Shiva',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _darkCharcoal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 6. Pricing, Discount & WhatsApp Button
  Widget _buildPriceSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Price column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '₹ 1,149',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _darkCharcoal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹ 1,600',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey.shade500,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFC8E6C9)),
                    ),
                    child: Text(
                      '28% OFF',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'M.R.P. (incl. of all taxes)',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          // Green WhatsApp Chat Button
          GestureDetector(
            onTap: _openWhatsAppHelp,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF25D366),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3325D366),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chat_bubble_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 7. 100% Cashback Offer Banner
  Widget _buildOfferBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF8F1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFC8E6C9), width: 1.0),
      ),
      child: Row(
        children: [
          const Text(
            '🎉',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '100% Cashback + Extra 5% OFF with UPI',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B5E20),
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF1B5E20),
            size: 20,
          ),
        ],
      ),
    );
  }

  /// 8. 4 Service Guarantees
  Widget _buildGuaranteesRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildGuaranteeItem(Icons.local_shipping_outlined, 'Free\nDelivery'),
          _buildGuaranteeItem(Icons.verified_user_outlined, 'Cash on\nDelivery'),
          _buildGuaranteeItem(Icons.inventory_2_outlined, 'Easy\nReturns'),
          _buildGuaranteeItem(Icons.verified_outlined, 'Original\n& Authentic'),
        ],
      ),
    );
  }

  Widget _buildGuaranteeItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 24, color: _darkCharcoal),
        const SizedBox(height: 5),
        Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            color: _darkCharcoal,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  /// 9. Mantra Energized & Sanctified Card
  Widget _buildConsecrationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _badgeCream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _badgeBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Om Shield Icon Asset
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              AppConstants.consecratedOmShieldAsset,
              width: 44,
              height: 48,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                width: 44,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD54F),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('ॐ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Text details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mantra Energized & Sanctified',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _primaryMaroon,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Purified, energized and blessed by Vedic mantras for positive energy and protection.',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    height: 1.35,
                    color: Colors.brown.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 10. Product Details Accordion
  Widget _buildProductDetailsAccordion() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Specifications',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _darkCharcoal,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5DDD0)),
            ),
            child: Column(
              children: [
                _buildSpecRow('Bead Count', '54 + 1 Guru Bead (Original 5-Mukhi Nepali)'),
                const Divider(height: 16),
                _buildSpecRow('Pendant Material', 'Heavy Ashtadhatu Brass with Antique Gold Polish'),
                const Divider(height: 16),
                _buildSpecRow('Consecration Sanctum', 'Shree Mahakaleshwar Jyotirlinga, Ujjain'),
                const Divider(height: 16),
                _buildSpecRow('Pendant Elements', 'Trishul, Damru, Nandi Bull & "महाकाल" Carving'),
                const Divider(height: 16),
                _buildSpecRow('Certification', 'Authenticity Lab Certificate Included'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.grey.shade700),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: _darkCharcoal,
            ),
          ),
        ),
      ],
    );
  }

  /// 11. Sticky Bottom Purchase Bar [- 1 +] [Add to Cart] [Buy Now]
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quantity Selector [- 1 +]
            Container(
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5DDD0)),
              ),
              child: Row(
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.remove, size: 18, color: _darkCharcoal),
                    onPressed: () {
                      if (_quantity > 1) setState(() => _quantity--);
                    },
                  ),
                  Text(
                    '$_quantity',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _darkCharcoal,
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.add, size: 18, color: _darkCharcoal),
                    onPressed: () {
                      setState(() => _quantity++);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Add to Cart Button (Red filled)
            Expanded(
              flex: 5,
              child: SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E161B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _addToCart,
                  icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                  label: Text(
                    'Add to Cart',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Buy Now Button (Yellow filled)
            Expanded(
              flex: 4,
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentGold,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _proceedToCheckout,
                  child: Text(
                    'Buy Now',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
