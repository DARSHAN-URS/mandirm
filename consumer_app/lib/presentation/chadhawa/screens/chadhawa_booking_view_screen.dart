import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/locale_service.dart';
import '../../common/widgets/app_image.dart';
import '../../common/widgets/certificate_download_card.dart';
import '../../bookings/screens/bookings_screen.dart';

/// Dedicated Devotional View Page for a Confirmed Chadhawa Booking.
/// Displays booking verification, sanctum details, devotee Sankalp,
/// live seva progress tracking stepper, WhatsApp video assurance, and certificate.
class ChadhawaBookingViewScreen extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback? onBrowsePujas;

  const ChadhawaBookingViewScreen({
    super.key,
    required this.booking,
    this.onBrowsePujas,
  });

  static const Color _primaryMaroon = Color(0xFF7A0C16);
  static const Color _deepCrimson = Color(0xFF5A0810);
  static const Color _accentGold = Color(0xFFFDCB06);
  static const Color _warmBackground = Color(0xFFFBF8F3);
  static const Color _darkCharcoal = Color(0xFF1E1E1E);
  static const Color _cardBorder = Color(0xFFEFE6D8);

  @override
  Widget build(BuildContext context) {
    final isHi = LocaleService().isHindi;
    final bookingId = booking['id']?.toString() ?? 'CHD-108';
    final title = booking['title']?.toString() ?? (isHi ? 'पवित्र चढ़ावा' : 'Sacred Chadava');
    final mandir = booking['mandir']?.toString() ?? (isHi ? 'पवित्र मंदिर गर्भगृह' : 'Holy Temple Sanctum');
    final amount = booking['amount']?.toString() ?? '₹251';
    final devoteeName = booking['devoteeName']?.toString() ?? (isHi ? 'श्रद्धालु' : 'Devotee');
    final gotra = booking['gotra']?.toString() ?? (isHi ? 'कश्यप' : 'Kashyap');
    final date = booking['date']?.toString() ?? (isHi ? 'आज, आगामी आरती' : 'Today, Upcoming Aarti');
    final assetPath = booking['asset']?.toString() ?? AppConstants.chadavaCardMahakalAsset;

    return Scaffold(
      backgroundColor: _warmBackground,
      appBar: AppBar(
        backgroundColor: _primaryMaroon,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isHi ? 'चढ़ावा रसीद एवं विवरण' : 'Chadava Booking Details',
          style: TextStyle(fontFamily: 'Headway', 
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            tooltip: isHi ? 'साझा करें' : 'Share Booking',
            icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: _deepCrimson,
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: _accentGold, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isHi
                            ? 'चढ़ावा संकल्प विवरण कॉपी किया गया!'
                            : 'Chadava Sankalp summary copied to share!',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Success Hero Confirmation Card
            _buildConfirmationHero(context, isHi, bookingId, date),

            const SizedBox(height: 16),

            // 2. Chadhawa Offering Summary Card
            _buildOfferingCard(isHi, title, mandir, amount, assetPath),

            const SizedBox(height: 16),

            // 3. Devotee Sankalp Card (यजमान संकल्प विवरण)
            _buildSankalpCard(isHi, devoteeName, gotra),

            const SizedBox(height: 16),

            // 4. Devotional Live Progress Stepper (चढ़ावा सेवा प्रगति)
            _buildProgressStepper(isHi),

            const SizedBox(height: 16),

            // 5. WhatsApp Video Proof Assurance Card
            _buildWhatsAppProofCard(context, isHi),

            const SizedBox(height: 16),

            // 6. Sacred Certificate Card
            CertificateDownloadCard(
              referenceId: bookingId,
              certType: 'chadhawa',
              devoteeName: devoteeName,
              serviceTitle: title,
              templeName: mandir,
              date: date,
            ),

            const SizedBox(height: 24),

            // 7. Action Buttons
            _buildActionButtons(context, isHi),
          ],
        ),
      ),
    );
  }

  /// 1. Success Hero Confirmation Card
  Widget _buildConfirmationHero(BuildContext context, bool isHi, String bookingId, String date) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8B121D),
            Color(0xFF6B0E17),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryMaroon.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF4CAF50),
              size: 40,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isHi ? 'चढ़ावा संकल्प स्वीकृत ✨' : 'Chadava Sankalp Confirmed ✨',
            style: TextStyle(fontFamily: 'Headway', 
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isHi
                ? 'आपका संकल्प पवित्र मंदिर के गर्भगृह में दर्ज कर लिया गया है।'
                : 'Your holy offering is registered in the sanctum sanctorum.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              color: const Color(0xFFFEE2E2),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(60),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _accentGold.withAlpha(120), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isHi ? 'बुकिंग संख्या: ' : 'Booking ID: ',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  bookingId,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: _accentGold,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: bookingId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isHi ? 'बुकिंग ID कॉपी हो गई' : 'Booking ID copied to clipboard',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Icon(Icons.copy_rounded, color: _accentGold, size: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Chadhawa Offering Summary Card
  Widget _buildOfferingCard(
    bool isHi,
    String title,
    String mandir,
    String amount,
    String assetPath,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder),
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
            children: [
              const Icon(Icons.volunteer_activism_rounded, color: _primaryMaroon, size: 18),
              const SizedBox(width: 6),
              Text(
                isHi ? 'चढ़ावा विवरण' : 'Chadava Offering Details',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _primaryMaroon,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isHi ? 'भुगतान सफल' : 'Paid Seva',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 64,
                  height: 64,
                  color: const Color(0xFFFFF9ED),
                  child: AppImage.asset(
                    assetPath,
                    fit: BoxFit.cover,
                    errorWidget: const Icon(Icons.temple_hindu, color: _primaryMaroon, size: 30),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _darkCharcoal,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 13, color: Color(0xFF757575)),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            mandir,
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              color: const Color(0xFF757575),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      amount,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _primaryMaroon,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, size: 16, color: Color(0xFFD97706)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isHi
                        ? 'शामिल: पवित्र सामग्री, गोत्र संकल्प पाठ एवं आरती दर्शन'
                        : 'Includes: Consecrated Samagri, Gotra Sankalp recitation & Aarti Seva',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF92400E),
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

  /// 3. Devotee Sankalp Card (यजमान संकल्प विवरण)
  Widget _buildSankalpCard(bool isHi, String devoteeName, String gotra) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder),
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
            children: [
              const Icon(Icons.person_pin_rounded, color: _primaryMaroon, size: 18),
              const SizedBox(width: 6),
              Text(
                isHi ? 'यजमान संकल्प विवरण' : 'Devotee Sankalp Details',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _primaryMaroon,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildInfoRow(isHi ? 'यजमान का नाम' : 'Devotee Name', devoteeName),
          const SizedBox(height: 8),
          _buildInfoRow(isHi ? 'गोत्र' : 'Gotra', gotra),
          const SizedBox(height: 8),
          _buildInfoRow(
            isHi ? 'संकल्प उद्देश्य' : 'Sankalp Prayer',
            isHi ? 'पारिवारिक सुख, शांति एवं उत्तम स्वास्थ्य' : 'Family Happiness, Peace & Good Health',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            isHi ? 'मुख्य पुजारी' : 'Presiding Purohit',
            isHi ? 'मंदिरम् अधिकृत मुख्य अर्चक' : 'Mandirm Verified Temple Priest',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _darkCharcoal,
          ),
        ),
      ],
    );
  }

  /// 4. Devotional Live Progress Stepper (चढ़ावा सेवा प्रगति)
  Widget _buildProgressStepper(bool isHi) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder),
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
            children: [
              const Icon(Icons.timeline_rounded, color: _primaryMaroon, size: 18),
              const SizedBox(width: 6),
              Text(
                isHi ? 'चढ़ावा सेवा प्रगति' : 'Chadava Seva Progress',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _primaryMaroon,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildStepItem(
            isCompleted: true,
            isCurrent: false,
            title: isHi ? 'संकल्प पंजीकृत' : 'Sankalp Recorded',
            subtitle: isHi
                ? 'आपका नाम व गोत्र मंदिर गर्भगृह पंजिका में दर्ज किया गया।'
                : 'Devotee Gotra & prayer entered in holy registry.',
            time: isHi ? 'संपन्न' : 'Completed',
          ),
          _buildStepDivider(isCompleted: true),
          _buildStepItem(
            isCompleted: false,
            isCurrent: true,
            title: isHi ? 'पवित्र सामग्री तैयारी' : 'Consecration of Offerings',
            subtitle: isHi
                ? 'शुद्ध पुष्प, श्रीफल व दीप वैदिक आचार्यों द्वारा सिद्ध किए जा रहे हैं।'
                : 'Pure items consecrated by Vedic Acharyas at mandir.',
            time: isHi ? 'प्रगति पर' : 'In Progress',
          ),
          _buildStepDivider(isCompleted: false),
          _buildStepItem(
            isCompleted: false,
            isCurrent: false,
            title: isHi ? 'गर्भगृह में चढ़ावा अर्पण' : 'Chadhawa Offered at Sanctum',
            subtitle: isHi
                ? 'आरती के दौरान विग्रह पर मंत्रोच्चार के साथ अर्पण।'
                : 'Offered during upcoming Aarti with sacred mantras.',
            time: isHi ? 'आज सायं' : 'Today Evening',
          ),
          _buildStepDivider(isCompleted: false),
          _buildStepItem(
            isCompleted: false,
            isCurrent: false,
            title: isHi ? 'व्हाट्सएप पर वीडियो दर्शन' : 'WhatsApp Video Clip Proof',
            subtitle: isHi
                ? 'आपके नाम के उच्चारण का 30-सेकंड वीडियो व्हाट्सएप पर प्राप्त होगा।'
                : 'Personalized recitation video delivered to your WhatsApp.',
            time: isHi ? '2-4 घंटे में' : 'Within 2-4 hrs',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required bool isCompleted,
    required bool isCurrent,
    required String title,
    required String subtitle,
    required String time,
    bool isLast = false,
  }) {
    Color iconColor;
    IconData iconData;

    if (isCompleted) {
      iconColor = const Color(0xFF2E7D32);
      iconData = Icons.check_circle_rounded;
    } else if (isCurrent) {
      iconColor = const Color(0xFFE65100);
      iconData = Icons.radio_button_checked_rounded;
    } else {
      iconColor = Colors.grey.shade400;
      iconData = Icons.radio_button_unchecked_rounded;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(iconData, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                      color: isCurrent ? _primaryMaroon : _darkCharcoal,
                    ),
                  ),
                  Text(
                    time,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? const Color(0xFF2E7D32)
                          : (isCurrent ? const Color(0xFFE65100) : Colors.grey.shade500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider({required bool isCompleted}) {
    return Padding(
      padding: const EdgeInsets.only(left: 9),
      child: Container(
        height: 20,
        width: 2,
        color: isCompleted ? const Color(0xFF81C784) : Colors.grey.shade300,
      ),
    );
  }

  /// 5. WhatsApp Video Proof Assurance Card
  Widget _buildWhatsAppProofCard(BuildContext context, bool isHi) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF25D366),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHi ? 'व्हाट्सएप वीडियो दर्शन की गारंटी' : 'Guaranteed WhatsApp Video Proof',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isHi
                      ? 'आरती के बाद पुजारी जी द्वारा आपके नाम-गोत्र के साथ चढ़ावा अर्पित करने का वीडियो आपके फोन पर भेजा जाएगा।'
                      : 'A personalized clip of the priest offering your chadava with your Gotra will be sent to your WhatsApp.',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF2E7D32),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 7. Action Buttons
  Widget _buildActionButtons(BuildContext context, bool isHi) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryMaroon,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
            onPressed: () {
              // Navigate to BookingsScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingsScreen(onBrowsePujas: onBrowsePujas),
                ),
              );
            },
            icon: const Icon(Icons.receipt_long_rounded, size: 18),
            label: Text(
              isHi ? 'मेरी सभी बुकिंग देखें' : 'View All My Bookings',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: _primaryMaroon,
              side: const BorderSide(color: _primaryMaroon, width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.volunteer_activism_rounded, size: 18),
            label: Text(
              isHi ? 'अन्य पवित्र चढ़ावा अर्पित करें' : 'Offer Another Chadava',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
