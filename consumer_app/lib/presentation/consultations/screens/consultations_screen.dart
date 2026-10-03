import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/api_service.dart';
import '../../../services/devotee_data_service.dart';
import '../../astrologers/screens/astrologers_screen.dart';
import '../../common/widgets/mandirm_header.dart';

class ConsultationsScreen extends StatefulWidget {
  final VoidCallback? onBrowseAstrologers;
  const ConsultationsScreen({super.key, this.onBrowseAstrologers});

  @override
  State<ConsultationsScreen> createState() => _ConsultationsScreenState();
}

class _ConsultationsScreenState extends State<ConsultationsScreen> {
  static const Color _primaryMaroon = Color(0xFF7A0C16);
  static const Color _darkCharcoal = Color(0xFF1E1E1E);
  static const Color _cardBorder = Color(0xFFEFE6D8);
  static const Color _warmCreamBg = Color(0xFFFBF8F3);
  static const Color _accentYellow = Color(0xFFFDCB06);

  @override
  void initState() {
    super.initState();
    _fetchBackendConsultations();
  }

  Future<void> _fetchBackendConsultations() async {
    try {
      final backendList = await ApiService().getMyConsultations();
      if (backendList.isNotEmpty && mounted) {
        setState(() {
          DevoteeDataService().syncBackendConsultations(backendList);
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final consultations = DevoteeDataService().consultations;

    return Scaffold(
      backgroundColor: _warmCreamBg,
      body: Column(
        children: [
          // 1. Same Unified Header all over the app!
          const MandirmHeader(),

            // 2. Scrollable Body
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchBackendConsultations,
                color: _primaryMaroon,
                child: consultations.isEmpty
                    ? _buildEmptyState(context)
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        children: [
                          // Summary Banner
                          _buildSummaryBanner(consultations.length),

                          const SizedBox(height: 16),

                          // Section Title
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Past Sessions (${consultations.length})',
                                style: GoogleFonts.marcellus(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: _primaryMaroon,
                                ),
                              ),
                              Text(
                                'Prescribed Remedies & Notes',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: const Color(0xFF757575),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Consultation Cards
                          ...consultations.map((c) => _buildConsultationCard(context, c)),
                        ],
                      ),
              ),
            ),
          ],
        ),
    );
  }

  /// Summary Banner
  Widget _buildSummaryBanner(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF9ED), Color(0xFFFFF3DB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B1E1E).withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _accentYellow,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'VEDIC SANCTIFIED REMEDIES',
                  style: GoogleFonts.poppins(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: _primaryMaroon,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              const Text('✨', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                '100% Verified Acharyas',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _primaryMaroon,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your Vedic Guidance History',
            style: GoogleFonts.marcellus(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _primaryMaroon,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Track all prescribed remedies, daily mantra counts, and sacred gemstone recommendations.',
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              color: const Color(0xFF5A4A42),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Consultation Card
  Widget _buildConsultationCard(BuildContext context, Map<String, dynamic> c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar + Acharya Info + Price
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B1E1E), Color(0xFF500609)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF3E5D8), width: 1.2),
                ),
                child: const Center(
                  child: Text('🧘‍♂️', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            c['astrologerName'] as String,
                            style: GoogleFonts.marcellus(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _darkCharcoal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded, size: 15, color: Color(0xFF2E7D32)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      c['specialty'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF6E6E6E),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                c['amount'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFD64D18),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Date & Duration Badges
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF8F3),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xFF757575)),
                    const SizedBox(width: 4),
                    Text(
                      c['date'] as String,
                      style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF555555)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF8F3),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF757575)),
                    const SizedBox(width: 4),
                    Text(
                      'Duration: ${c['duration']}',
                      style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF555555)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Prescribed Remedy Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFD54F), width: 1.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🪷', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      'Remedies Prescribed by Acharya:',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: _primaryMaroon,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  c['remedy'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: const Color(0xFF333333),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFEFE6D8)),
          const SizedBox(height: 10),

          // Bottom: Devotee Rating & Action CTA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 18),
                  const SizedBox(width: 4),
                  Text(
                    'Your Rating: 5.0 ★',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF555555),
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7A0C16), Color(0xFF9E1B26)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(100, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (widget.onBrowseAstrologers != null) {
                      widget.onBrowseAstrologers!();
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AstrologersScreen()),
                      );
                    }
                  },
                  child: Text(
                    'Consult Again',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Empty State
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9ED),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFDCB06), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B1E1E).withAlpha(15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🧘‍♂️', style: TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Consultations Yet',
              style: GoogleFonts.marcellus(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _primaryMaroon,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Talk with certified Vedic Acharyas for call & chat remedies, Kundli dosha analysis, and personalized remedies.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF6E6E6E),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Container(
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (widget.onBrowseAstrologers != null) {
                    widget.onBrowseAstrologers!();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AstrologersScreen()),
                    );
                  }
                },
                child: Text(
                  'Consult an Astrologer',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.white,
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
