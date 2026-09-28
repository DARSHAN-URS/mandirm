import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/consultation_model.dart';

class LiveConsultationScreen extends StatefulWidget {
  final DevoteeConsultationRequest consultation;

  const LiveConsultationScreen({
    super.key,
    required this.consultation,
  });

  @override
  State<LiveConsultationScreen> createState() => _LiveConsultationScreenState();
}

class _LiveConsultationScreenState extends State<LiveConsultationScreen> {
  int _callDurationSeconds = 0;
  Timer? _callTimer;
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isFrontCamera = true;

  @override
  void initState() {
    super.initState();
    _startCallTimer();
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDurationSeconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get _currentEarnings {
    final elapsedMinutes = (_callDurationSeconds / 60);
    return elapsedMinutes * widget.consultation.perMinuteRate;
  }

  void _onEndCall() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AstrologerColors.cosmicCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AstrologerColors.borderSubtle),
        ),
        title: Text(
          'End Consultation?',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Total Duration: ${_formatDuration(_callDurationSeconds)}\nEarned: ₹${_currentEarnings.toStringAsFixed(2)}\n\nWould you like to complete and settle this consultation?',
          style: GoogleFonts.poppins(color: AstrologerColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Resume Call', style: TextStyle(color: AstrologerColors.vedicGold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AstrologerColors.statusOffline,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context, {
                'completed': true,
                'duration': _callDurationSeconds,
                'earnings': _currentEarnings,
              });
            },
            child: const Text('End & Settle'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dev = widget.consultation;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulated Remote Devotee Video Background / Consultation Aura
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Color(0xFF2E1065),
                    Color(0xFF0F172A),
                    Colors.black,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AstrologerColors.vedicGold.withOpacity(0.4),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AstrologerColors.vedicGold.withOpacity(0.15),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(dev.devoteePhoto),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      dev.devoteeName,
                      style: GoogleFonts.cinzel(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AstrologerColors.vedicGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AstrologerColors.vedicGold.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Gotra: ${dev.devoteeGotra} • Rashi: ${dev.devoteeRashi}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AstrologerColors.vedicGold,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Top Overlay: Status, Time, and Real-Time Earnings
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AstrologerColors.statusOnline,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDuration(_callDurationSeconds),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AstrologerColors.royalPurple.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AstrologerColors.vedicGold.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.currency_rupee, color: AstrologerColors.vedicGold, size: 14),
                      Text(
                        _currentEarnings.toStringAsFixed(2),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        ' (₹${dev.perMinuteRate.toInt()}/m)',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Self-View Pip (Astrologer Camera Thumbnail)
          Positioned(
            top: 105,
            right: 16,
            child: Container(
              width: 100,
              height: 140,
              decoration: BoxDecoration(
                color: AstrologerColors.cosmicCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AstrologerColors.vedicGold.withOpacity(0.5)),
                boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        color: const Color(0xFF1E1B4B),
                        child: Center(
                          child: Icon(
                            _isVideoOff ? Icons.videocam_off : Icons.face,
                            color: AstrologerColors.vedicGold,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      left: 6,
                      child: Text(
                        'You',
                        style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Topic Banner
          Positioned(
            bottom: 120,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.help_outline, color: AstrologerColors.vedicGold, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Consultation Topic:',
                          style: GoogleFonts.poppins(fontSize: 10, color: Colors.white60),
                        ),
                        Text(
                          dev.problemTopic,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: AstrologerColors.vedicGold.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    icon: const Icon(Icons.auto_graph, color: AstrologerColors.vedicGold, size: 16),
                    label: Text(
                      'Kundli',
                      style: GoogleFonts.poppins(color: AstrologerColors.vedicGold, fontSize: 12),
                    ),
                    onPressed: () {
                      _showKundliModal(context, dev);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Bottom Control Actions
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCallAction(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  color: _isMuted ? Colors.red : Colors.white24,
                  onTap: () => setState(() => _isMuted = !_isMuted),
                ),
                _buildCallAction(
                  icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
                  color: _isVideoOff ? Colors.red : Colors.white24,
                  onTap: () => setState(() => _isVideoOff = !_isVideoOff),
                ),
                _buildCallAction(
                  icon: Icons.flip_camera_ios,
                  color: Colors.white24,
                  onTap: () => setState(() => _isFrontCamera = !_isFrontCamera),
                ),
                _buildCallAction(
                  icon: Icons.call_end,
                  color: AstrologerColors.statusOffline,
                  iconColor: Colors.white,
                  size: 60,
                  onTap: _onEndCall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallAction({
    required IconData icon,
    required Color color,
    Color iconColor = Colors.white,
    double size = 50,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: size * 0.45),
      ),
    );
  }

  void _showKundliModal(BuildContext context, DevoteeConsultationRequest dev) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AstrologerColors.cosmicCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Vedic Birth Chart (Kundli)',
                        style: GoogleFonts.cinzel(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AstrologerColors.vedicGold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AstrologerColors.royalPurple.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          dev.devoteeRashi,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildKundliDataGrid(dev),
                  const SizedBox(height: 20),
                  Text(
                    'Planetary Alignments (Grahas)',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildGrahaCard('Surya (Sun)', '10th House (Digbala)', 'Career peak & public success'),
                  _buildGrahaCard('Brihaspati (Jupiter)', '1st House (Lagna)', 'Strong spiritual & health blessing'),
                  _buildGrahaCard('Shani (Saturn)', '7th House (Retrograde)', 'Delay in business partnership resolution'),
                  _buildGrahaCard('Chandra (Moon)', 'Exalted in Taurus', 'Mental peace & creative intuition'),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildKundliDataGrid(DevoteeConsultationRequest dev) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AstrologerColors.cosmicDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AstrologerColors.borderSubtle),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildDetailItem('Devotee Name', dev.devoteeName)),
              Expanded(child: _buildDetailItem('Gotra', dev.devoteeGotra)),
            ],
          ),
          const Divider(color: Colors.white10, height: 20),
          Row(
            children: [
              Expanded(child: _buildDetailItem('Date of Birth', dev.birthDob)),
              Expanded(child: _buildDetailItem('Birth Time', dev.birthTime)),
            ],
          ),
          const Divider(color: Colors.white10, height: 20),
          Row(
            children: [
              Expanded(child: _buildDetailItem('Birth Place', dev.birthPlace)),
              Expanded(child: _buildDetailItem('Vedic Lagna', 'Mesha (Aries)')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54)),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildGrahaCard(String graha, String position, String effect) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AstrologerColors.cosmicDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AstrologerColors.vedicGold.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wb_sunny_outlined, color: AstrologerColors.vedicGold, size: 16),
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
                      graha,
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    Text(
                      position,
                      style: GoogleFonts.poppins(fontSize: 11, color: AstrologerColors.vedicGold),
                    ),
                  ],
                ),
                Text(
                  effect,
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
