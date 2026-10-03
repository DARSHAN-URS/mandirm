import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/api_service.dart';
import '../../../services/devotee_data_service.dart';
import '../../common/widgets/mandirm_header.dart';
import '../../../core/l10n/app_strings.dart';

class BookingsScreen extends StatefulWidget {
  final VoidCallback? onBrowsePujas;
  const BookingsScreen({super.key, this.onBrowsePujas});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color _primaryMaroon = Color(0xFF7A0C16);
  static const Color _darkCharcoal = Color(0xFF1E1E1E);
  static const Color _cardBorder = Color(0xFFEFE6D8);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchBackendBookings();
  }

  Future<void> _fetchBackendBookings() async {
    try {
      final backendList = await ApiService().getMyBookings();
      if (backendList.isNotEmpty && mounted) {
        setState(() {
          DevoteeDataService().syncBackendBookings(backendList);
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCertificateDialog(Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFFD54F), width: 2),
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFFFFF9ED),
                ),
                child: Column(
                  children: [
                    const Text('🕉️', style: TextStyle(fontSize: 34)),
                    const SizedBox(height: 6),
                    Text(
                      'Sankalp Blessing Certificate',
                      style: GoogleFonts.marcellus(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _primaryMaroon,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'This certifies that sacred Vedic rituals for',
                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking['title'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _primaryMaroon,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'were conducted in the name of ${booking['devoteeName']} (Gotra: ${booking['gotra']}) at ${booking['mandir']}.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 11, color: _darkCharcoal),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Purohit: ${booking['pandit']} • Ref: ${booking['id']}',
                      style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primaryMaroon,
                        side: const BorderSide(color: _primaryMaroon),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryMaroon,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Downloading Sankalp Certificate PDF...'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download_rounded, size: 16),
                      label: const Text('Download'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookings = DevoteeDataService().bookings;
    final activeBookings = bookings.where((b) => b['status'] != 'Completed').toList();
    final completedBookings = bookings.where((b) => b['status'] == 'Completed').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F3),
      body: Column(
        children: [
          const MandirmHeader(),
          Container(
            color: const Color(0xFFFBF8F3),
            child: TabBar(
              controller: _tabController,
              labelColor: _primaryMaroon,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: _primaryMaroon,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700),
              unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
              tabs: [
                Tab(text: '${AppStrings.t('pending')} (${activeBookings.length})'),
                Tab(text: '${AppStrings.t('completed')} (${completedBookings.length})'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBookingsList(activeBookings, isActive: true),
                _buildBookingsList(completedBookings, isActive: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(List<Map<String, dynamic>> list, {required bool isActive}) {
    if (list.isEmpty) {
      return Center(
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
                  child: Icon(Icons.spa_outlined, color: _primaryMaroon, size: 40),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isActive ? 'No Active Puja Bookings' : 'No Completed Pujas Yet',
                style: GoogleFonts.marcellus(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: _primaryMaroon,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Book sacred Vedic pujas conducted with your Gotra & Name at holy sanctums.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 12.5, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 20),
              if (widget.onBrowsePujas != null)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryMaroon,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: widget.onBrowsePujas,
                  child: Text(
                    'Browse Sacred Pujas',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final b = list[index];

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
              // Header
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
                      'Booking ID: ${b['id']}',
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
                      color: b['status'] == 'Confirmed'
                          ? Colors.green.shade50
                          : Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: b['status'] == 'Confirmed'
                            ? Colors.green.shade200
                            : Colors.amber.shade300,
                      ),
                    ),
                    child: Text(
                      b['status'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: b['status'] == 'Confirmed'
                            ? Colors.green.shade800
                            : Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Puja Title & Mandir
              Text(
                b['title'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: _darkCharcoal,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Sanctum: ${b['mandir']}',
                style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 10),

              // Devotee Details Pill
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF8F3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5DDD0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.family_restroom_rounded, size: 16, color: _primaryMaroon),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sankalp for ${b['devoteeName']} • Gotra: ${b['gotra']}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _darkCharcoal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Date & Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Scheduled: ${b['date']}',
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade700),
                  ),
                  Text(
                    'Seva: ${b['amount']}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _primaryMaroon,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Certificate Action
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primaryMaroon,
                      side: const BorderSide(color: _primaryMaroon),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _showCertificateDialog(b),
                    icon: const Icon(Icons.workspace_premium_outlined, size: 15),
                    label: Text(
                      'Sankalp Certificate',
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
