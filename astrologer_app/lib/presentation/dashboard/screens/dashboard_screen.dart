import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/consultation_model.dart';
import '../../calls/screens/live_consultation_screen.dart';

class AstrologerDashboardScreen extends StatefulWidget {
  const AstrologerDashboardScreen({super.key});

  @override
  State<AstrologerDashboardScreen> createState() => _AstrologerDashboardScreenState();
}

class _AstrologerDashboardScreenState extends State<AstrologerDashboardScreen> {
  String _astrologerStatus = 'online'; // online, busy, offline
  final List<DevoteeConsultationRequest> _queue = List.from(DevoteeConsultationRequest.mockQueue);
  final EarningsSummary _earnings = EarningsSummary.mockData;
  final List<PastConsultation> _recentHistory = List.from(PastConsultation.mockHistory);

  void _acceptConsultation(DevoteeConsultationRequest request) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LiveConsultationScreen(consultation: request),
      ),
    );

    if (result != null && result['completed'] == true) {
      setState(() {
        _queue.removeWhere((r) => r.id == request.id);
        _recentHistory.insert(
          0,
          PastConsultation(
            id: 'hist_${DateTime.now().millisecondsSinceEpoch}',
            devoteeName: request.devoteeName,
            type: request.type,
            durationMinutes: ((result['duration'] as int) ~/ 60) + 1,
            amount: (result['earnings'] as double),
            timeAgo: 'Just now',
            rating: 5.0,
            feedback: 'Thank you Guruji for the auspicious remedies.',
          ),
        );
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Consultation completed with ${request.devoteeName}! ₹${(result['earnings'] as double).toStringAsFixed(2)} added to wallet.',
          ),
          backgroundColor: AstrologerColors.statusOnline,
        ),
      );
    }
  }

  void _dismissRequest(DevoteeConsultationRequest request) {
    setState(() {
      _queue.removeWhere((r) => r.id == request.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Request from ${request.devoteeName} passed.'),
        backgroundColor: AstrologerColors.cosmicSurface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AstrologerColors.cosmicDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Profile & Status Bar
              _buildHeader(),
              const SizedBox(height: 20),

              // Today's Earnings & Performance Hub
              _buildEarningsCard(),
              const SizedBox(height: 24),

              // Incoming Queue Section
              _buildQueueSection(),
              const SizedBox(height: 24),

              // Recent Consultations & Reviews
              _buildHistorySection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AstrologerColors.cosmicCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AstrologerColors.borderSubtle),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
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
                        border: Border.all(color: AstrologerColors.cosmicCard, width: 2),
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
                      'Acharya Devavrat Shastri',
                      style: GoogleFonts.cinzel(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Jyotish Praveen • Vedic & Vastu Expert',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AstrologerColors.vedicGold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AstrologerColors.vedicGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AstrologerColors.vedicGold.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: AstrologerColors.vedicGold, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '4.92',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AstrologerColors.vedicGold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AstrologerColors.borderSubtle, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Duty Status:',
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
              ),
              _buildStatusPill('online', 'Online (Accepting Calls)', AstrologerColors.statusOnline),
              _buildStatusPill('busy', 'Busy', AstrologerColors.statusBusy),
              _buildStatusPill('offline', 'Offline', AstrologerColors.statusOffline),
            ],
          ),
        ],
      ),
    );
  }

  Color get _statusColor {
    switch (_astrologerStatus) {
      case 'online':
        return AstrologerColors.statusOnline;
      case 'busy':
        return AstrologerColors.statusBusy;
      default:
        return AstrologerColors.statusOffline;
    }
  }

  Widget _buildStatusPill(String statusKey, String label, Color color) {
    final isSelected = _astrologerStatus == statusKey;
    return GestureDetector(
      onTap: () => setState(() => _astrologerStatus = statusKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.transparent),
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
              statusKey.capitalize(),
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4C1D95),
            Color(0xFF2E1065),
            Color(0xFF1E1B4B),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AstrologerColors.royalPurple.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: AstrologerColors.royalPurple.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Consultation Earnings",
                    style: GoogleFonts.poppins(fontSize: 12, color: AstrologerColors.amberGlow),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.currency_rupee, color: AstrologerColors.vedicGold, size: 26),
                      Text(
                        _earnings.todayEarnings.toStringAsFixed(0),
                        style: GoogleFonts.cinzel(
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
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  children: [
                    Text(
                      'Wallet',
                      style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70),
                    ),
                    Text(
                      '₹${_earnings.walletBalance.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AstrologerColors.vedicGold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric('Consultations', '${_earnings.todayConsultations} devotees', Icons.people_outline),
              _buildMetric('Spoken Time', '${_earnings.todayMinutes} mins', Icons.timer_outlined),
              _buildMetric('Call Rate', '₹35 / min', Icons.call_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AstrologerColors.vedicGold, size: 18),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white60)),
      ],
    );
  }

  Widget _buildQueueSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Live Devotee Queue',
                  style: GoogleFonts.cinzel(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AstrologerColors.vedicGold,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_queue.length}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E1B4B),
                    ),
                  ),
                ),
              ],
            ),
            if (_queue.isNotEmpty)
              Text(
                'Instant Call Connect',
                style: GoogleFonts.poppins(fontSize: 11, color: AstrologerColors.statusOnline),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_queue.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AstrologerColors.cosmicCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AstrologerColors.borderSubtle),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.self_improvement, color: AstrologerColors.vedicGold, size: 40),
                  const SizedBox(height: 10),
                  Text(
                    'Queue is clear 🙏',
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  Text(
                    'Keep your status Online. Devotees seeking guidance will appear here automatically.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 12, color: AstrologerColors.textMuted),
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
        color: AstrologerColors.cosmicCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AstrologerColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(req.devoteePhoto),
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
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Gotra: ${req.devoteeGotra} • Rashi: ${req.devoteeRashi}',
                      style: GoogleFonts.poppins(fontSize: 11, color: AstrologerColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isVideo
                      ? AstrologerColors.royalPurple.withOpacity(0.2)
                      : isVoice
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVideo ? Icons.videocam : isVoice ? Icons.phone : Icons.chat,
                      size: 13,
                      color: isVideo ? AstrologerColors.mysticalViolet : isVoice ? Colors.lightBlue : Colors.greenAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      req.type.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
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
              color: AstrologerColors.cosmicDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.help_center_outlined, color: AstrologerColors.vedicGold, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    req.problemTopic,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
                  ),
                ),
                Text(
                  '₹${req.perMinuteRate.toInt()}/m',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AstrologerColors.vedicGold),
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
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _dismissRequest(req),
                  child: const Text('Pass'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AstrologerColors.vedicGold,
                    foregroundColor: const Color(0xFF1E1B4B),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: Icon(isVideo ? Icons.videocam : Icons.call, size: 18),
                  label: Text(
                    isVideo ? 'Accept Video Call' : 'Accept Audio Call',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Consultations & Reviews',
          style: GoogleFonts.cinzel(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ..._recentHistory.map((item) => _buildHistoryCard(item)),
      ],
    );
  }

  Widget _buildHistoryCard(PastConsultation item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AstrologerColors.cosmicCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AstrologerColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.devoteeName,
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              Row(
                children: [
                  const Icon(Icons.currency_rupee, color: AstrologerColors.vedicGold, size: 14),
                  Text(
                    item.amount.toStringAsFixed(0),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AstrologerColors.vedicGold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${item.type.capitalize()} • ${item.durationMinutes} mins • ${item.timeAgo}',
                style: GoogleFonts.poppins(fontSize: 11, color: AstrologerColors.textMuted),
              ),
              const Spacer(),
              ...List.generate(
                5,
                (i) => Icon(
                  Icons.star,
                  size: 11,
                  color: i < item.rating.floor() ? AstrologerColors.vedicGold : Colors.white24,
                ),
              ),
            ],
          ),
          if (item.feedback.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '“${item.feedback}”',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: Colors.white70,
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
