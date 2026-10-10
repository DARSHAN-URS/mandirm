import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/api_service.dart';

/// A beautiful certificate download card shown in the bookings/order detail screen.
///
/// Shows a golden ornamental card with the certificate preview details
/// and a "Download Certificate" button that opens the SVG via URL launcher.
class CertificateDownloadCard extends StatefulWidget {
  /// The booking ID (for puja) or order ID (for chadhawa)
  final String referenceId;

  /// 'puja' or 'chadhawa'
  final String certType;

  /// Devotee name to show on the card (fallback display)
  final String devoteeName;

  /// Service title (puja name / chadhawa title)
  final String serviceTitle;

  /// Temple name
  final String templeName;

  /// Date of puja/chadhawa
  final String? date;

  const CertificateDownloadCard({
    super.key,
    required this.referenceId,
    required this.certType,
    required this.devoteeName,
    required this.serviceTitle,
    required this.templeName,
    this.date,
  });

  @override
  State<CertificateDownloadCard> createState() => _CertificateDownloadCardState();
}

class _CertificateDownloadCardState extends State<CertificateDownloadCard>
    with SingleTickerProviderStateMixin {
  bool _isDownloading = false;
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _shimmerAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _downloadCertificate() async {
    setState(() => _isDownloading = true);
    try {
      final api = ApiService();
      final url = widget.certType == 'puja'
          ? api.getPujaCertificateUrl(widget.referenceId)
          : api.getChaDhawaCertificateUrl(widget.referenceId);

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open certificate. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPuja = widget.certType == 'puja';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8E7), Color(0xFFFFF3CD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFD4A017).withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4A017).withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background pattern
          Positioned(
            right: -20,
            top: -20,
            child: AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (ctx, child) => Opacity(
                opacity: _shimmerAnimation.value * 0.07,
                child: child,
              ),
              child: const Text(
                'ॐ',
                style: TextStyle(
                  fontSize: 120,
                  color: Color(0xFFD4A017),
                  fontFamily: 'serif',
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFD4A017), Color(0xFFB8860B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Text('📜', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Sacred Certificate',
                            style: GoogleFonts.cinzel(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF4A1005),
                            ),
                          ),
                          Text(
                            isPuja ? 'Puja Participation Certificate' : 'Chadava Offering Certificate',
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              color: const Color(0xFF7A5C3A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Gold seal icon
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4A017).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFD4A017).withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        '✅ Ready',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF7A5C3A),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Gold divider
                Container(
                  height: 1,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Color(0xFFD4A017), Colors.transparent],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Certificate details
                _buildDetailRow('👤 Devotee', widget.devoteeName),
                const SizedBox(height: 5),
                _buildDetailRow(isPuja ? '🪔 Puja' : '🌸 Chadava', widget.serviceTitle),
                const SizedBox(height: 5),
                _buildDetailRow('🏛 Temple', widget.templeName),
                if (widget.date != null) ...[
                  const SizedBox(height: 5),
                  _buildDetailRow('📅 Date', widget.date!),
                ],

                const SizedBox(height: 14),

                // Download button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _isDownloading ? null : _downloadCertificate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4A017),
                      disabledBackgroundColor: const Color(0xFFD4A017).withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isDownloading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.download_rounded,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Download Certificate',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 8),

                // Sub note
                Center(
                  child: Text(
                    'Certificate opens as an SVG file • Share or print anytime',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: const Color(0xFF9E8E6A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF7A5C3A),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF3E2B1F),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
