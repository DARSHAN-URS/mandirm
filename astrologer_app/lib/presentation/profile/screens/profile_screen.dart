import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class AstrologerProfileScreen extends StatefulWidget {
  const AstrologerProfileScreen({super.key});

  @override
  State<AstrologerProfileScreen> createState() => _AstrologerProfileScreenState();
}

class _AstrologerProfileScreenState extends State<AstrologerProfileScreen> {
  double _videoRate = 35.0;
  double _voiceRate = 30.0;
  double _chatRate = 25.0;

  void _saveRates() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Consultation rates updated successfully! Devotees will see the new pricing immediately.'),
        backgroundColor: AstrologerColors.statusOnline,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AstrologerColors.cosmicDark,
      appBar: AppBar(
        backgroundColor: AstrologerColors.cosmicDark,
        elevation: 0,
        title: Text(
          'Acharya Profile & Rates',
          style: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card with Verification Badge
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AstrologerColors.cosmicCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AstrologerColors.borderSubtle),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 34,
                    backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Acharya Devavrat',
                              style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.verified, color: Colors.blueAccent, size: 16),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Gold Medalist • Banaras Hindu University',
                          style: GoogleFonts.poppins(fontSize: 11, color: AstrologerColors.vedicGold),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AstrologerColors.statusOnline.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'KYC VERIFIED & CERTIFIED',
                            style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: AstrologerColors.statusOnline),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Rate Settings Section
            Text(
              'Manage Consultation Rates (Per Minute)',
              style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 12),
            _buildRateCard('Video Consultation', _videoRate, Icons.videocam, AstrologerColors.mysticalViolet, (val) {
              setState(() => _videoRate = val);
            }),
            _buildRateCard('Voice Call Consultation', _voiceRate, Icons.phone, Colors.lightBlue, (val) {
              setState(() => _voiceRate = val);
            }),
            _buildRateCard('Live Vedic Chat', _chatRate, Icons.chat, Colors.greenAccent, (val) {
              setState(() => _chatRate = val);
            }),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveRates,
                child: const Text('Save & Update Rates'),
              ),
            ),
            const SizedBox(height: 24),

            // Expertise Badges
            Text(
              'Vedic Specializations',
              style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildBadge('Vedic Astrology'),
                _buildBadge('Kundli Milan'),
                _buildBadge('Vastu Shastra'),
                _buildBadge('Prashna Jyotish'),
                _buildBadge('Gemology (Ratna)'),
                _buildBadge('Numerology'),
                _buildBadge('Career & Finance Kundli'),
              ],
            ),
            const SizedBox(height: 24),

            // Languages
            Text(
              'Consultation Languages',
              style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildBadge('Hindi (Native)'),
                _buildBadge('Sanskrit'),
                _buildBadge('English'),
                _buildBadge('Gujarati'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRateCard(String title, double currentVal, IconData icon, Color color, ValueChanged<double> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AstrologerColors.cosmicCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AstrologerColors.borderSubtle),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
              Text(
                '₹${currentVal.toInt()} / min',
                style: GoogleFonts.poppins(color: AstrologerColors.vedicGold, fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ],
          ),
          Slider(
            value: currentVal,
            min: 15.0,
            max: 100.0,
            divisions: 17,
            activeColor: AstrologerColors.vedicGold,
            inactiveColor: Colors.white12,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AstrologerColors.cosmicSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
      ),
    );
  }
}
