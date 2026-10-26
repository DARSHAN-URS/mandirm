import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/cart_service.dart';
import '../../../services/devotee_data_service.dart';
import '../../../services/api_service.dart';
import '../../../services/razorpay_service.dart';
import '../../../services/supabase_service.dart';
import '../../common/widgets/app_image.dart';

class CartDrawerSheet extends StatefulWidget {
  final VoidCallback? onOrderSuccess;

  const CartDrawerSheet({super.key, this.onOrderSuccess});

  static void show(BuildContext context, {VoidCallback? onOrderSuccess}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CartDrawerSheet(onOrderSuccess: onOrderSuccess),
    );
  }

  @override
  State<CartDrawerSheet> createState() => _CartDrawerSheetState();
}

class _CartDrawerSheetState extends State<CartDrawerSheet> {
  final CartService _cart = CartService();
  final TextEditingController _addressController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _addressController.text = '';
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _checkout() async {
    if (_cart.items.isEmpty) return;
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter delivery address')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final address = _addressController.text.trim();
      final user = SupabaseService().currentUser;
      final profile = SupabaseService().currentProfile;
      final userName = profile?.fullName ??
          (user?.userMetadata?['full_name'] as String?) ??
          (user?.userMetadata?['name'] as String?) ??
          'Devotee';
      final userGotra = profile?.gotra ?? 'Devotee Gotra';

      final totalAmt = _cart.subtotal;
      final cartOrderId = 'CART-${DateTime.now().millisecondsSinceEpoch % 1000000}';

      // Launch native Razorpay Checkout Sheet
      final payRes = await RazorpayService().openPayment(
        amount: totalAmt,
        referenceType: 'shop_order',
        referenceId: cartOrderId,
        devoteeName: userName,
        description: 'Mandirm Divine Store Order (${_cart.totalCount} items)',
      );

      if (!payRes.isSuccess) {
        if (mounted) setState(() => _isSubmitting = false);
        if (mounted && payRes.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(payRes.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      for (final item in _cart.items) {
        final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch % 1000000}';
        final trackingNo = 'BLUEDART-${DateTime.now().millisecondsSinceEpoch % 9000000}';

        final orderData = {
          'id': orderId,
          'title': item.title,
          'mandir': item.mandir,
          'orderDate': 'Today, Just Now',
          'status': 'Processing Consecration',
          'currentStep': 0,
          'trackingNumber': trackingNo,
          'carrier': 'BlueDart Express',
          'expectedDelivery': 'In 2-3 Days',
          'address': address,
        };

        DevoteeDataService().addPrasadOrder(orderData);
        DevoteeDataService().addBooking({
          'id': orderId,
          'title': item.title,
          'mandir': item.mandir,
          'date': 'Today, Auspicious Muhurat',
          'amount': '₹${(item.price * item.quantity).toInt()}',
          'status': 'Confirmed',
          'gotra': userGotra,
          'devoteeName': userName,
          'pandit': 'Mandirm Store Sanctum',
          'prasadTracking': trackingNo,
          'prasadStatus': 'Processing Consecration',
        });

        // Persist to backend
        ApiService().placeOrder({
          'product_id': item.id,
          'quantity': item.quantity,
          'total_amount': item.price * item.quantity,
          'shipping_address': address,
        }).catchError((_) => null);
      }

      _cart.clearCart();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF7A0C16),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFFFDCB06)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Sacred Order Placed Successfully! Track in Profile → Orders',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
        widget.onOrderSuccess?.call();
      }
    } catch (_) {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFBF8F3),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7A0C16).withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF7A0C16), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Spiritual Cart (${_cart.totalCount})',
                      style: const TextStyle(
                        fontFamily: 'Headway',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                  ],
                ),
                if (_cart.items.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() => _cart.clearCart());
                    },
                    child: Text(
                      'Clear',
                      style: GoogleFonts.poppins(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Body
          Expanded(
            child: _cart.items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFF9ED),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.remove_shopping_cart_outlined, color: Color(0xFF7A0C16), size: 34),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Your Spiritual Cart is Empty',
                            style: const TextStyle(
                              fontFamily: 'Headway',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF7A0C16),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Explore sacred murtis, yantras, authentic Rudraksha malas, and organic puja samagri.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    children: [
                      // Cart items list
                      ..._cart.items.map((item) => _buildCartItemCard(item)),

                      const SizedBox(height: 16),

                      // Delivery Address
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFDECDB4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, color: Color(0xFF7A0C16), size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'Delivery Address for Consecrated Prasad',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E1E1E),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _addressController,
                              maxLines: 2,
                              style: GoogleFonts.poppins(fontSize: 12),
                              decoration: InputDecoration(
                                hintText: 'Enter complete flat, street, city & pincode...',
                                filled: true,
                                fillColor: const Color(0xFFFBF8F3),
                                contentPadding: const EdgeInsets.all(10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Order Summary Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFDECDB4)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Items Subtotal', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700)),
                                Text('₹ ${_cart.subtotal.toInt()}', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Sanctum Consecration Packing', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700)),
                                Text('FREE', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.green.shade700)),
                              ],
                            ),
                            const Divider(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Payable',
                                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF7A0C16)),
                                ),
                                Text(
                                  '₹ ${_cart.subtotal.toInt()}',
                                  style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w800, color: const Color(0xFF7A0C16)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),

          // Checkout CTA Bar
          if (_cart.items.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10, offset: const Offset(0, -3)),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _checkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7A0C16),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Proceed to Sacred Checkout (₹ ${_cart.subtotal.toInt()})',
                          style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 60,
              height: 60,
              child: AppImage.asset(
                item.imageUrl,
                fit: BoxFit.cover,
                errorWidget: Container(color: Colors.amber.shade100, child: const Icon(Icons.spa, color: Color(0xFF7A0C16))),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: const Color(0xFF1E1E1E)),
                ),
                Text(
                  item.mandir,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 10.5, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹ ${item.price.toInt()}',
                  style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF7A0C16)),
                ),
              ],
            ),
          ),
          // Quantity Controls
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.remove_circle_outline, size: 20, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    _cart.updateQuantity(item.id, item.quantity - 1);
                  });
                },
              ),
              Text(
                '${item.quantity}',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.add_circle_outline, size: 20, color: Color(0xFF7A0C16)),
                onPressed: () {
                  setState(() {
                    _cart.updateQuantity(item.id, item.quantity + 1);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
