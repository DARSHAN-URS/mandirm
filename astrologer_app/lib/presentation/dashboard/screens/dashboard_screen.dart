import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/l10n/locale_service.dart';
import '../../../domain/models/astrologer_profile.dart';
import '../../../domain/models/consultation_model.dart';
import '../../../services/api/api_service.dart';
import '../../../services/auth/auth_service.dart';
import '../../calls/screens/live_consultation_screen.dart';
import '../../common/widgets/app_image.dart';
import '../../common/widgets/mandirm_header.dart';

class AstrologerDashboardScreen extends StatefulWidget {
  const AstrologerDashboardScreen({super.key});

  @override
  State<AstrologerDashboardScreen> createState() => _AstrologerDashboardScreenState();
}

class _AstrologerDashboardScreenState extends State<AstrologerDashboardScreen> {
  AstrologerProfile? _profile;
  String _astrologerStatus = 'online'; // online, busy, offline
  final List<DevoteeConsultationRequest> _queue = [];
  EarningsSummary _earnings = EarningsSummary(
    todayEarnings: 0.0,
    todayMinutes: 0,
    todayConsultations: 0,
    walletBalance: 0.0,
    rating: 4.95,
  );
  final List<PastConsultation> _recentHistory = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() async {
    final current = AuthService().currentProfile;
    if (current != null) {
      setState(() {
        _profile = current;
        _astrologerStatus = current.isOnline ? 'online' : 'offline';
      });
    }

    final astroId = current?.id ?? AuthService().currentAstrologerId;
    if (astroId.isEmpty) return;

    try {
      final p = await ApiService().getAstrologerProfile(astroId);
      if (p != null && mounted) {
        setState(() {
          _profile = p;
          _astrologerStatus = p.isOnline ? 'online' : 'offline';
        });
      }

      final earningsData = await ApiService().getAstrologerEarnings(astroId);
      if (earningsData != null && mounted) {
        setState(() {
          _earnings = EarningsSummary(
            todayEarnings: (earningsData['total_earned'] as num?)?.toDouble() ?? 0.0,
            todayMinutes: (earningsData['today_minutes'] as num?)?.toInt() ?? 0,
            todayConsultations: (earningsData['completed_consultations'] as num?)?.toInt() ?? 0,
            walletBalance: (earningsData['wallet_balance'] as num?)?.toDouble() ?? 0.0,
            rating: _profile?.rating ?? 5.0,
          );
        });
      }

      final cons = await ApiService().getAstrologerConsultations(astroId);
      final List<DevoteeConsultationRequest> fetchedQueue = [];
      final List<PastConsultation> fetchedHistory = [];

      for (var c in cons) {
        final status = (c['status'] ?? 'requested').toString().toLowerCase();
        if (status == 'requested' || status == 'active') {
          fetchedQueue.add(DevoteeConsultationRequest.fromJson(c));
        } else if (status == 'completed') {
          fetchedHistory.add(PastConsultation.fromJson(c));
        }
      }

      if (mounted) {
        setState(() {
          _queue.clear();
          _queue.addAll(fetchedQueue);
          _recentHistory.clear();
          _recentHistory.addAll(fetchedHistory);
        });
      }
    } catch (e) {
      debugPrint('[Dashboard] Error fetching backend data: $e');
    }
  }

  void _onStatusChanged(String newStatus) async {
    setState(() => _astrologerStatus = newStatus);
    final astroId = _profile?.id ?? AuthService().currentAstrologerId;
    if (astroId.isEmpty) return;
    final ok = await ApiService().updateAstrologerAvailability(
      astroId,
      isOnline: newStatus != 'offline',
      isChatActive: newStatus == 'online',
      isCallActive: newStatus == 'online',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Status updated to ${newStatus.toUpperCase()} on Mandirm network'
              : 'Status set to ${newStatus.toUpperCase()}',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: newStatus == 'online'
            ? AppColors.statusOnline
            : (newStatus == 'busy' ? AppColors.statusBusy : AppColors.statusOffline),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _acceptConsultation(DevoteeConsultationRequest request) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveConsultationScreen(consultation: request),
      ),
    );

    if (result != null && result['completed'] == true) {
      final durationMins = ((result['duration'] as int? ?? 60) ~/ 60) + 1;
      final earned = (result['earnings'] as num?)?.toDouble() ?? (request.perMinuteRate * durationMins);
      final remediesList = result['prescribed_remedies'] as List?;
      final remediesNotes = (remediesList != null && remediesList.isNotEmpty)
          ? 'Prescribed remedies: ${remediesList.join(', ')}'
          : null;

      // Persist status update to Backend & Supabase
      ApiService().updateConsultationStatus(
        request.id,
        status: 'completed',
        durationMinutes: durationMins,
        totalAmount: earned,
        notes: remediesNotes,
      );

      setState(() {
        _queue.removeWhere((r) => r.id == request.id);
        _recentHistory.insert(
          0,
          PastConsultation(
            id: 'hist_${DateTime.now().millisecondsSinceEpoch}',
            devoteeName: request.devoteeName,
            devoteePhoto: request.devoteePhoto,
            type: request.type,
            durationMinutes: durationMins,
            amount: earned,
            timeAgo: 'Just now',
            rating: 5.0,
            feedback: remediesNotes ?? 'Thank you Guruji for the auspicious remedies.',
          ),
        );
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Consultation completed with ${request.devoteeName}! ₹${earned.toStringAsFixed(2)} added to wallet.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.statusOnline,
        ),
      );
    }
  }

  void _dismissRequest(DevoteeConsultationRequest request) {
    setState(() {
      _queue.removeWhere((r) => r.id == request.id);
    });

    // Notify backend & Supabase that request was passed
    ApiService().updateConsultationStatus(request.id, status: 'rejected');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Request from ${request.devoteeName} passed.', style: GoogleFonts.poppins()),
        backgroundColor: AppColors.warmCream,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // Unified Mandirm Header (identical to consumer app)
          const MandirmHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Acharya Profile & Duty Status (Availability Settings)
                  _buildHeader(),
                  const SizedBox(height: 16),

                  // 2. Today's Dakshina & Performance Hub (Earnings View)
                  _buildEarningsCard(),
                  const SizedBox(height: 20),

                  // 3. Incoming Devotee Consultations Queue (Consultation Requests: Voice, Video, Chat)
                  _buildQueueSection(),
                  const SizedBox(height: 20),

                  // 4. Recent Devotee Consultations & Reviews (Consultation History)
                  _buildHistorySection(),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final isHi = LocaleService().isHindi;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.marigoldGold, width: 2),
                    ),
                    child: ClipOval(
                      child: AppImage.network(
                        AppConstants.cdnUrl(AppConstants.astroRajeshAsset),
                        fallbackAsset: AppConstants.logoAsset,
                        width: 58,
                        height: 58,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _profile?.name ?? (isHi ? 'पं. रामचन्द्र शास्त्री' : 'Pt. Ramachandra Shastri'),
                      style: TextStyle(fontFamily: 'Headway', 
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _profile?.specialities ?? (isHi ? 'ज्योतिष प्रवीण • वैदिक व वास्तु विशेषज्ञ' : 'Jyotish Praveen • Vedic & Vastu Expert'),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.deepAmber,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.deepAmber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.deepAmber.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.marigoldGold, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '4.92',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepAmber,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.lightBorder, height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isHi ? 'ड्यूटी स्थिति:' : 'Duty Status:',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              _buildStatusPill('online', AstroStrings.t('online'), AppColors.statusOnline),
              _buildStatusPill('busy', AstroStrings.t('busy'), AppColors.statusBusy),
              _buildStatusPill('offline', AstroStrings.t('offline'), AppColors.statusOffline),
            ],
          ),
        ],
      ),
    );
  }

  Color get _statusColor {
    switch (_astrologerStatus) {
      case 'online':
        return AppColors.statusOnline;
      case 'busy':
        return AppColors.statusBusy;
      default:
        return AppColors.statusOffline;
    }
  }

  Widget _buildStatusPill(String statusKey, String label, Color color) {
    final isSelected = _astrologerStatus == statusKey;
    return GestureDetector(
      onTap: () => _onStatusChanged(statusKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.lightBorder,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsCard() {
    final isHi = LocaleService().isHindi;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryMaroon,
            AppColors.kumkumMaroon,
            Color(0xFF991B1B),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.marigoldGold.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryMaroon.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                AppConstants.flameLogoAsset,
                width: 110,
                height: 110,
                errorBuilder: (_, __, ___) => const Icon(Icons.wb_sunny, size: 80, color: Colors.white),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHi ? 'आज की कुल दक्षिणा' : "Today's Consultation Earnings",
                        style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFFFFF6E5)),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.currency_rupee, color: Color(0xFFFFD54F), size: 26),
                          Text(
                            _earnings.todayEarnings.toStringAsFixed(0),
                            style: TextStyle(fontFamily: 'Headway', 
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      children: [
                        Text(
                          isHi ? 'वॉलेट' : 'Wallet',
                          style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFFFFF6E5)),
                        ),
                        Text(
                          '₹${_earnings.walletBalance.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFFD54F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetric(
                    isHi ? 'परामर्श' : 'Consultations',
                    '${_earnings.todayConsultations} ${isHi ? 'भक्त' : 'devotees'}',
                    Icons.people_outline,
                  ),
                  _buildMetric(
                    isHi ? 'परामर्श समय' : 'Spoken Time',
                    '${_earnings.todayMinutes} ${isHi ? 'मिनट' : 'mins'}',
                    Icons.timer_outlined,
                  ),
                  _buildMetric(
                    isHi ? 'कॉल दर' : 'Call Rate',
                    '₹35 / ${isHi ? 'मिनट' : 'min'}',
                    Icons.call_outlined,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFFFD54F), size: 18),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFFFFF6E5).withOpacity(0.8))),
      ],
    );
  }

  Widget _buildQueueSection() {
    final isHi = LocaleService().isHindi;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  isHi ? 'प्रतीक्षारत भक्त कतार' : 'Live Devotee Queue',
                  style: TextStyle(fontFamily: 'Headway', 
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMaroon,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_queue.length}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            if (_queue.isNotEmpty)
              Text(
                isHi ? 'त्वरित कॉल कनेक्ट' : 'Instant Call Connect',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.statusOnline,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_queue.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: Center(
              child: Column(
                children: [
                  Image.asset(
                    AppConstants.flameLogoAsset,
                    width: 56,
                    height: 56,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.self_improvement,
                      color: AppColors.deepAmber,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isHi ? 'कतार वर्तमान में रिक्त है 🙏' : 'Queue is clear 🙏',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    isHi
                        ? 'अपनी स्थिति ऑनलाइन रखें। मार्गदर्शन चाहने वाले भक्त यहाँ स्वतः प्रदर्शित होंगे।'
                        : 'Keep your status Online. Devotees seeking guidance will appear here automatically.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          )
        else
          ..._queue.map((req) => _buildQueueCard(req)),
      ],
    );
  }

  Widget _buildQueueCard(DevoteeConsultationRequest req) {
    final isVideo = req.type == 'video';
    final isVoice = req.type == 'voice';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Devotee Photo Image Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.lightBorder, width: 1.5),
                ),
                child: ClipOval(
                  child: AppImage.network(
                    req.devoteePhoto,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req.devoteeName,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Gotra: ${req.devoteeGotra} • Rashi: ${req.devoteeRashi}',
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isVideo
                      ? AppColors.primaryMaroon.withOpacity(0.1)
                      : isVoice
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVideo ? Icons.videocam : isVoice ? Icons.phone : Icons.chat,
                      size: 13,
                      color: isVideo ? AppColors.primaryMaroon : isVoice ? Colors.blue : Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      req.type.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isVideo ? AppColors.primaryMaroon : isVoice ? Colors.blue.shade800 : Colors.green.shade800,
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
              color: AppColors.warmCream,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.help_center_outlined, color: AppColors.deepAmber, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    req.problemTopic,
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textPrimary),
                  ),
                ),
                Text(
                  '₹${req.perMinuteRate.toInt()}/m',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryMaroon,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.lightBorder),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _dismissRequest(req),
                  child: Text(LocaleService().isHindi ? 'छोड़ें' : 'Pass'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryMaroon,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: Icon(isVideo ? Icons.videocam : Icons.call, size: 18),
                  label: Text(
                    isVideo
                        ? (LocaleService().isHindi ? 'वीडियो कॉल स्वीकारें' : 'Accept Video Call')
                        : (LocaleService().isHindi ? 'ऑडियो कॉल स्वीकारें' : 'Accept Audio Call'),
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  onPressed: () => _acceptConsultation(req),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    final isHi = LocaleService().isHindi;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isHi ? 'हाल के परामर्श व समीक्षाएं' : 'Recent Consultations & Reviews',
          style: TextStyle(fontFamily: 'Headway', 
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (_recentHistory.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: Center(
              child: Text(
                isHi ? 'कोई पूर्ण परामर्श उपलब्ध नहीं है' : 'No completed consultations yet',
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ..._recentHistory.map((item) => _buildHistoryCard(item)),
      ],
    );
  }

  Widget _buildHistoryCard(PastConsultation item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
              // Devotee Photo Avatar
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.lightBorder, width: 1),
                ),
                child: ClipOval(
                  child: AppImage.network(
                    item.devoteePhoto,
                    width: 38,
                    height: 38,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.devoteeName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${item.type.capitalize()} • ${item.durationMinutes} mins • ${item.timeAgo}',
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.currency_rupee, color: AppColors.primaryMaroon, size: 14),
                  Text(
                    item.amount.toStringAsFixed(0),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryMaroon,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Spacer(),
              ...List.generate(
                5,
                (i) => Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: i < item.rating.floor() ? AppColors.marigoldGold : AppColors.lightBorder,
                ),
              ),
            ],
          ),
          if (item.feedback.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warmCream,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '“${item.feedback}”',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
