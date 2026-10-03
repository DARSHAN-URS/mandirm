import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/api_service.dart';
import '../../../services/devotee_data_service.dart';
import 'store_screen.dart';
import '../../common/widgets/mandirm_header.dart';

class PrasadOrdersScreen extends StatefulWidget {
  final VoidCallback? onBrowsePujas;
  const PrasadOrdersScreen({super.key, this.onBrowsePujas});

  @override
  State<PrasadOrdersScreen> createState() => _PrasadOrdersScreenState();
}

class _PrasadOrdersScreenState extends State<PrasadOrdersScreen> {
  static const Color _primaryMaroon = Color(0xFF7A0C16);
  static const Color _darkCharcoal = Color(0xFF1E1E1E);
  static const Color _cardBorder = Color(0xFFEFE6D8);

  @override
  void initState() {
    super.initState();
    _fetchBackendOrders();
  }

  Future<void> _fetchBackendOrders() async {
    try {
      final backendOrders = await ApiService().getMyOrders();
      if (backendOrders.isNotEmpty && mounted) {
        setState(() {
          DevoteeDataService().syncBackendOrders(backendOrders);
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final orders = DevoteeDataService().prasadOrders;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F3),
      appBar: const MandirmHeader(isAppBar: true),
      body: orders.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF9ED),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.shopping_bag_outlined, color: _primaryMaroon, size: 40),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Sacred Orders Yet',
                      style: GoogleFonts.marcellus(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _primaryMaroon,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Order consecrated idols, malas, or sacred temple chadava delivered with SpeedPost to your doorstep.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 12.5, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryMaroon,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        if (widget.onBrowsePujas != null) {
                          widget.onBrowsePujas!();
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const StoreScreen()),
                          );
                        }
                      },
                      child: Text(
                        'Explore Mandirm Store & Pujas',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              itemCount: orders.length,
              itemBuilder: (context, i) {
                final o = orders[i];
                final currentStep = (o['currentStep'] as int? ?? 1);

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.brown.withAlpha(8),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF9ED),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFFFE0B2)),
                            ),
                            child: Text(
                              'Order ID: ${o['id']}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF7A4A00),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: o['status'] == 'Delivered'
                                  ? Colors.green.shade50
                                  : Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: o['status'] == 'Delivered'
                                    ? Colors.green.shade200
                                    : Colors.amber.shade300,
                              ),
                            ),
                            child: Text(
                              o['status'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: o['status'] == 'Delivered'
                                    ? Colors.green.shade800
                                    : Colors.amber.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Title & Mandir
                      Text(
                        o['title'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _darkCharcoal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Blessed from: ${o['mandir']}',
                        style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 14),

                      // Stepper: Blessed -> Packed -> In Transit -> Delivered
                      Text(
                        'Consecration & Dispatch Status:',
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildStepDot(label: 'Blessed', isDone: currentStep >= 0),
                          _buildStepLine(isDone: currentStep >= 1),
                          _buildStepDot(label: 'Packed', isDone: currentStep >= 1),
                          _buildStepLine(isDone: currentStep >= 2),
                          _buildStepDot(label: 'In Transit', isDone: currentStep >= 2),
                          _buildStepLine(isDone: currentStep >= 3),
                          _buildStepDot(label: 'Delivered', isDone: currentStep >= 3),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Tracking info card
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBF8F3),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE5DDD0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.local_shipping_outlined,
                                    size: 16, color: _primaryMaroon),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${o['carrier']} • Tracking: ${o['trackingNumber']}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _darkCharcoal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Estimated Delivery: ${o['estDelivery'] ?? '3-5 Business Days'}',
                              style: GoogleFonts.poppins(fontSize: 10.5, color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Action Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Tracking ${o['trackingNumber']} with BlueDart SpeedPost'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.open_in_new_rounded, size: 14, color: _primaryMaroon),
                          label: Text(
                            'Live Track on BlueDart',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
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
            ),
    );
  }

  Widget _buildStepDot({required String label, required bool isDone}) {
    return Column(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: isDone ? _primaryMaroon : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: isDone
              ? const Icon(Icons.check, size: 12, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 9,
            fontWeight: isDone ? FontWeight.w600 : FontWeight.w400,
            color: isDone ? _primaryMaroon : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine({required bool isDone}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 14),
        color: isDone ? _primaryMaroon : Colors.grey.shade300,
      ),
    );
  }
}
