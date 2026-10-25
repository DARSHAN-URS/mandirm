import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/models/consultation_model.dart';
import '../../../services/api/api_service.dart';
import '../../../services/auth/auth_service.dart';
import '../../common/widgets/app_image.dart';
import '../../common/widgets/mandirm_header.dart';

class AstrologerHistoryScreen extends StatefulWidget {
  const AstrologerHistoryScreen({super.key});

  @override
  State<AstrologerHistoryScreen> createState() => _AstrologerHistoryScreenState();
}

class _AstrologerHistoryScreenState extends State<AstrologerHistoryScreen> {
  final List<PastConsultation> _history = [];
  String _filterType = 'all'; // all, audio, video

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final astroId = AuthService().currentAstrologerId;
    if (astroId.isEmpty) return;
    try {
      final cons = await ApiService().getAstrologerConsultations(astroId);
      final List<PastConsultation> fetched = [];
      for (var c in cons) {
        final status = (c['status'] ?? 'completed').toString().toLowerCase();
        if (status == 'completed') {
          fetched.add(PastConsultation.fromJson(c));
        }
      }
      if (mounted) {
        setState(() {
          _history.clear();
          _history.addAll(fetched);
        });
      }
    } catch (e) {
      debugPrint('[HistoryScreen] Error loading history: $e');
    }
  }

  List<PastConsultation> get _filteredHistory {
    if (_filterType == 'audio') {
      return _history.where((h) => h.type == 'audio' || h.type == 'voice').toList();
    } else if (_filterType == 'video') {
      return _history.where((h) => h.type == 'video').toList();
    }
    return _history;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // Unified Mandirm Header (same as consumer app)
          const MandirmHeader(),

          // Subheader & Filter Chips
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: AppColors.headerBg,
              border: Border(bottom: BorderSide(color: AppColors.lightBorder, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Devotee Records & Kundlis',
                  style: TextStyle(fontFamily: 'Headway', 
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Past consultations, prescribed remedies & devotee reviews',
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildFilterChip('All Records', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Voice Calls', 'audio'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Video Calls', 'video'),
                  ],
                ),
              ],
            ),
          ),

          // List of Past Consultations
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadHistory,
              color: AppColors.primaryMaroon,
              child: _filteredHistory.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 68,
                                height: 68,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.warmCream,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.marigoldGold.withOpacity(0.4)),
                                ),
                                child: Image.asset(
                                  AppConstants.flameLogoAsset,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.history, color: AppColors.textMuted),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'No consultations recorded yet.',
                                style: GoogleFonts.poppins(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredHistory.length,
                      itemBuilder: (context, index) {
                      final item = _filteredHistory[index];
                      final isVideo = item.type == 'video';

                      return GestureDetector(
                        onTap: () => _showRecordDetails(context, item),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.lightBorder),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x06000000),
                              blurRadius: 4,
                              offset: Offset(0, 1.5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.lightBorder, width: 1.2),
                                      ),
                                      child: ClipOval(
                                        child: AppImage.network(
                                          item.devoteePhoto,
                                          width: 44,
                                          height: 44,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: isVideo ? AppColors.primaryMaroon : AppColors.deepAmber,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isVideo ? Icons.videocam : Icons.phone,
                                          size: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.devoteeName,
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        '${item.timeAgo} • ${item.durationMinutes} mins',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '+₹${item.amount.toStringAsFixed(0)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.statusOnline,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          size: 15,
                                          color: AppColors.marigoldGold,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${item.rating}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (item.feedback.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warmCream,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.lightBorder),
                                ),
                                child: Text(
                                  '"${item.feedback}"',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRecordDetails(BuildContext context, PastConsultation item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ClipOval(
                  child: AppImage.network(
                    item.devoteePhoto,
                    fallbackAsset: AppConstants.logoAsset,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.devoteeName, style: TextStyle(fontFamily: 'Headway', fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      Text('${item.type.toUpperCase()} • ${item.durationMinutes} mins • ₹${item.amount.toInt()}', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.deepAmber)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.warmCream, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.marigoldGold, size: 16),
                      Text('${item.rating}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.lightBorder),
            const SizedBox(height: 10),
            Text('Prescribed Vedic Remedies in Session:', style: TextStyle(fontFamily: 'Headway', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildRemedyThumb('Yellow Sapphire', AppConstants.catYantraAsset),
                const SizedBox(width: 10),
                _buildRemedyThumb('5-Mukhi Rudraksha', AppConstants.deityRudrakshaAsset),
              ],
            ),
            const SizedBox(height: 16),
            if (item.feedback.isNotEmpty) ...[
              Text('Devotee Blessing & Review:', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.warmCream, borderRadius: BorderRadius.circular(10)),
                child: Text('“${item.feedback}”', style: GoogleFonts.poppins(fontSize: 12, fontStyle: FontStyle.italic)),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRemedyThumb(String name, String image) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.warmCream,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.lightBorder),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: AppImage.network(
                AppConstants.cdnUrl(image),
                fallbackAsset: AppConstants.logoAsset,
                width: 30,
                height: 30,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(name, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String key) {
    final isSelected = _filterType == key;
    return GestureDetector(
      onTap: () => setState(() => _filterType = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryMaroon : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryMaroon : AppColors.lightBorder,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
