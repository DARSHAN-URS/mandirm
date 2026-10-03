import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../services/api_service.dart';
import '../../../../services/devotee_data_service.dart';
import '../../../../services/supabase_service.dart';

/// Reusable Modal for Vedic Sankalp Booking with Gotra, Name, Prasad Address, and Payment
class SankalpBookingModal extends StatefulWidget {
  final Map<String, dynamic> puja;
  final VoidCallback onSuccess;

  const SankalpBookingModal({
    super.key,
    required this.puja,
    required this.onSuccess,
  });

  @override
  State<SankalpBookingModal> createState() => _SankalpBookingModalState();
}

class _SankalpBookingModalState extends State<SankalpBookingModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _wishController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedGotra = 'Kashyap';
  String _selectedPayment = 'UPI (Google Pay / PhonePe)';
  bool _wantPrasadDelivered = true;
  bool _joinLiveVideo = true;
  bool _isProcessing = false;

  final List<String> _gotras = [
    'Kashyap',
    'Bharadwaja',
    'Vashishta',
    'Vishwamitra',
    'Gautama',
    'Atri',
    'Sandilya',
    'Angirasa',
    'Shiva Gotra',
  ];

  final List<String> _paymentMethods = [
    'UPI (Google Pay / PhonePe)',
    'Paytm / BHIM UPI',
    'Credit / Debit Card',
    'Net Banking (All Major Banks)',
  ];

  static const Color _primaryMaroon = Color(0xFF7A0C16);
  static const Color _darkCharcoal = Color(0xFF1E1E1E);
  static const Color _cardBorder = Color(0xFFEFE6D8);
  static const Color _warmCreamBg = Color(0xFFFFFDF9);
  static const Color _accentYellow = Color(0xFFFDCB06);

  @override
  void initState() {
    super.initState();
    final user = SupabaseService().currentUser;
    _nameController.text = user?.userMetadata?['full_name'] ?? 'Devotee';
    _wishController.text = 'Family health, prosperity, and spiritual peace';
    _addressController.text =
        'Flat 402, Shanti Vihar, Mumbai, Maharashtra 400050';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _wishController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submitBooking() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isProcessing = true);
      await Future.delayed(const Duration(milliseconds: 900));

      final newBookingId =
          'MND-${DateTime.now().millisecondsSinceEpoch % 10000}';
      final newBooking = {
        'id': newBookingId,
        'title': widget.puja['title'],
        'mandir': widget.puja['mandir'] ?? 'Haridwar Ghat',
        'date': widget.puja['date'] ?? 'Upcoming Auspicious Day',
        'amount': widget.puja['price'],
        'status': 'Confirmed',
        'gotra': _selectedGotra,
        'devoteeName': _nameController.text.trim(),
        'pandit': 'Pt. Ramakant Shastri',
        'prasadTracking':
            'IP${DateTime.now().millisecondsSinceEpoch % 100000000}IN',
        'prasadStatus': 'In Preparation',
      };

      DevoteeDataService().addBooking(newBooking);

      // Persist to FastAPI backend with safe fallback
      try {
        await ApiService().createBooking({
          'puja_id': widget.puja['id'] ?? 'pj_custom',
          'package_id': widget.puja['package_id'] ?? 'pkg_standard',
          'amount': widget.puja['numericPrice'] ?? 1100,
          'devotee_name': _nameController.text.trim(),
          'gotra': _selectedGotra,
          'special_wishes': _wishController.text.trim(),
          'prasad_address': _wantPrasadDelivered ? _addressController.text.trim() : null,
          'is_live_stream_requested': _joinLiveVideo,
          'scheduled_date': widget.puja['date']?.toString(),
        });
      } catch (e) {
        debugPrint('[SankalpBookingModal] Backend sync note: $e');
      }

      if (!mounted) return;
      setState(() => _isProcessing = false);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFFFFFDF9),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: _cardBorder)),
          title: Row(
            children: [
              const Text('🚩', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sankalp Confirmed!',
                  style: GoogleFonts.marcellus(
                      fontSize: 19, fontWeight: FontWeight.w700, color: _primaryMaroon),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFFD54F)),
                ),
                child: Text(
                  'Auspicious Booking ID: $newBookingId',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: _primaryMaroon,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Sacred Sankalp for ${_nameController.text.trim()} (Gotra: $_selectedGotra) registered successfully at ${widget.puja['mandir'] ?? 'Mandir'}.',
                style: GoogleFonts.poppins(fontSize: 12, color: _darkCharcoal, height: 1.4),
              ),
              const SizedBox(height: 8),
              Text(
                'Pandit Ji will recite your name and wish during the holy ritual. Live video link & consecrated prasad will be shared.',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: const Color(0xFF6E6E6E), height: 1.3),
              ),
            ],
          ),
          actions: [
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7A0C16), Color(0xFF9E1B26)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  widget.onSuccess();
                },
                child: Text(
                  'View in My Bookings',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: _warmCreamBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFD7CCC8),
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vedic Sankalp Booking',
                        style: GoogleFonts.marcellus(
                            fontSize: 18, fontWeight: FontWeight.w700, color: _primaryMaroon),
                      ),
                      Text(
                        widget.puja['title'] as String? ?? 'Sacred Puja',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF6E6E6E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF5A4A42)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _cardBorder),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Puja info banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF9ED),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _cardBorder),
                      ),
                      child: Row(
                        children: [
                          const Text('📍', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Venue: ${widget.puja['mandir'] ?? 'Ganga Ghat'} • ${widget.puja['date'] ?? 'Upcoming'}',
                              style: GoogleFonts.poppins(
                                  fontSize: 11.5, fontWeight: FontWeight.w600, color: _darkCharcoal),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _accentYellow,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.puja['price'] as String? ?? '₹ 1,100',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _primaryMaroon,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section 1: Devotee & Gotra
                    Text('1. Sacred Sankalp Details',
                        style: GoogleFonts.marcellus(
                            fontSize: 15, fontWeight: FontWeight.w700, color: _primaryMaroon)),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _nameController,
                      style: GoogleFonts.poppins(fontSize: 13, color: _darkCharcoal),
                      decoration: InputDecoration(
                        labelText: 'Devotee / Yajman Full Name *',
                        labelStyle: GoogleFonts.poppins(fontSize: 12),
                        prefixIcon: const Icon(Icons.person_outline, size: 20, color: _primaryMaroon),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Enter devotee name'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedGotra,
                      decoration: InputDecoration(
                        labelText: 'Vedic Gotra *',
                        labelStyle: GoogleFonts.poppins(fontSize: 12),
                        prefixIcon:
                            const Icon(Icons.temple_hindu_outlined, size: 20, color: _primaryMaroon),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                      items: _gotras
                          .map((g) =>
                              DropdownMenuItem(value: g, child: Text(g, style: GoogleFonts.poppins(fontSize: 13))))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedGotra = val ?? 'Kashyap'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _wishController,
                      style: GoogleFonts.poppins(fontSize: 13, color: _darkCharcoal),
                      decoration: InputDecoration(
                        labelText: 'Sankalp Objective / Mano-kamna *',
                        labelStyle: GoogleFonts.poppins(fontSize: 12),
                        hintText: 'e.g. Health, Career, Family peace',
                        prefixIcon: const Icon(Icons.auto_awesome, size: 20, color: _primaryMaroon),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty
                          ? 'Enter prayer wish'
                          : null,
                    ),

                    const SizedBox(height: 20),

                    // Section 2: Prasad & Video
                    Text('2. Prasad Delivery & Stream Options',
                        style: GoogleFonts.marcellus(
                            fontSize: 15, fontWeight: FontWeight.w700, color: _primaryMaroon)),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _wantPrasadDelivered,
                      activeThumbColor: _primaryMaroon,
                      title: Text('Doorstep Holy Prasad Delivery',
                          style: GoogleFonts.poppins(
                              fontSize: 13, fontWeight: FontWeight.w600, color: _darkCharcoal)),
                      subtitle: Text(
                          'Receive energized Bhasma, Raksha Sutra, and dry fruits box',
                          style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF6E6E6E))),
                      onChanged: (val) =>
                          setState(() => _wantPrasadDelivered = val),
                    ),
                    if (_wantPrasadDelivered)
                      TextFormField(
                        controller: _addressController,
                        maxLines: 2,
                        style: GoogleFonts.poppins(fontSize: 13, color: _darkCharcoal),
                        decoration: InputDecoration(
                          labelText: 'Prasad Courier Address *',
                          labelStyle: GoogleFonts.poppins(fontSize: 12),
                          prefixIcon: const Icon(Icons.home_outlined, size: 20, color: _primaryMaroon),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                        ),
                        validator: (val) => _wantPrasadDelivered &&
                                (val == null || val.trim().isEmpty)
                            ? 'Enter delivery address'
                            : null,
                      ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _joinLiveVideo,
                      activeThumbColor: _primaryMaroon,
                      title: Text('Join Live Priest Video Sankalp',
                          style: GoogleFonts.poppins(
                              fontSize: 13, fontWeight: FontWeight.w600, color: _darkCharcoal)),
                      subtitle: Text(
                          'Direct video connection with the Mandir sanctum during ritual',
                          style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF6E6E6E))),
                      onChanged: (val) =>
                          setState(() => _joinLiveVideo = val),
                    ),

                    const SizedBox(height: 20),

                    // Section 3: Payment
                    Text('3. Payment Method',
                        style: GoogleFonts.marcellus(
                            fontSize: 15, fontWeight: FontWeight.w700, color: _primaryMaroon)),
                    const SizedBox(height: 10),
                    ..._paymentMethods.map((method) {
                      final isSelected = _selectedPayment == method;
                      return InkWell(
                        onTap: () => setState(() => _selectedPayment = method),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_off_rounded,
                                color: isSelected
                                    ? _primaryMaroon
                                    : Colors.grey.shade400,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                method,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? _primaryMaroon
                                      : _darkCharcoal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 24),

                    // Submit Button
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7A0C16), Color(0xFF9E1B26)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryMaroon.withAlpha(50),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isProcessing ? null : _submitBooking,
                        child: _isProcessing
                            ? const CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2)
                            : Text(
                                'Confirm & Book Dakshina (${widget.puja['price'] ?? '₹ 1,100'})',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

