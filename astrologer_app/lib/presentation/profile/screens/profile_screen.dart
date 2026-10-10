import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/models/astrologer_profile.dart';
import '../../../services/api/api_service.dart';
import '../../../services/auth/auth_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../common/widgets/app_image.dart';
import '../../common/widgets/mandirm_header.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import 'edit_profile_screen.dart';

class AstrologerProfileScreen extends StatefulWidget {
  const AstrologerProfileScreen({super.key});

  @override
  State<AstrologerProfileScreen> createState() => _AstrologerProfileScreenState();
}

class _AstrologerProfileScreenState extends State<AstrologerProfileScreen> {
  AstrologerProfile? _profile;
  double _videoRate = 35.0;
  double _voiceRate = 30.0;
  double _chatRate = 25.0;
  bool _isSavingRates = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final p = AuthService().currentProfile;
    if (p != null) {
      setState(() {
        _profile = p;
        _videoRate = p.perMinuteVideoRate;
        _voiceRate = p.perMinuteCallRate;
        _chatRate = p.perMinuteChatRate;
      });
    }
    try {
      final me = await ApiService().getMe();
      if (me != null && mounted) {
        setState(() {
          _profile = AstrologerProfile.fromJson(me);
          _videoRate = _profile!.perMinuteVideoRate;
          _voiceRate = _profile!.perMinuteCallRate;
          _chatRate = _profile!.perMinuteChatRate;
        });
      }
    } catch (_) {}
  }

  void _openEditProfile() async {
    final current = _profile ??
        AstrologerProfile(
          id: AuthService().currentProfile?.id ?? 'astro_1',
          name: 'Acharya Ramanuj Shastri',
          title: 'Senior Vedic Astrologer & Kundli Expert',
          perMinuteVideoRate: _videoRate,
          perMinuteCallRate: _voiceRate,
          perMinuteChatRate: _chatRate,
        );

    final updated = await Navigator.push<AstrologerProfile>(
      context,
      MaterialPageRoute(
        builder: (_) => EditAstrologerProfileScreen(profile: current),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        _profile = updated;
        _videoRate = updated.perMinuteVideoRate;
        _voiceRate = updated.perMinuteCallRate;
        _chatRate = updated.perMinuteChatRate;
      });
    }
  }

  void _saveRates() async {
    setState(() => _isSavingRates = true);
    final astroId = _profile?.id ?? 'astro_1';
    final ok = await ApiService().updateAstrologerProfile(
      astroId,
      {
        'per_minute_chat_rate': _chatRate,
        'per_minute_call_rate': _voiceRate,
        'per_minute_video_rate': _videoRate,
      },
    );
    if (!mounted) return;
    setState(() => _isSavingRates = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Rates updated on Mandirm backend! Devotees will see the new pricing immediately.'
              : 'Rates updated locally.',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: AppColors.statusOnline,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // Unified Mandirm Header (same as consumer app)
          const MandirmHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Card with Verification Badge & Acharya Image
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.marigoldGold, width: 2.2),
                                  ),
                                  child: ClipOval(
                                    child: AppImage.network(
                                      AppConstants.cdnUrl(AppConstants.astroRajeshAsset),
                                      fallbackAsset: AppConstants.logoAsset,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _openEditProfile,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryMaroon,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_rounded,
                                        size: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _profile?.name ?? 'Acharya Ramanuj Shastri',
                                          style: GoogleFonts.cinzel(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.verified, color: AppColors.primaryMaroon, size: 16),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _profile?.phone != null && _profile!.phone!.isNotEmpty
                                        ? '${_profile!.phone} • ${_profile?.specialities ?? 'Vedic Jyotish'}'
                                        : (_profile?.title ?? 'Senior Vedic Astrologer & Kundli Expert'),
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: AppColors.deepAmber,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.statusOnline.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'KYC VERIFIED',
                                          style: GoogleFonts.poppins(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.statusOnline,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      InkWell(
                                        onTap: _openEditProfile,
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryMaroon.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: AppColors.primaryMaroon.withOpacity(0.3)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.edit_rounded, size: 12, color: AppColors.primaryMaroon),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Edit Profile',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.primaryMaroon,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (_profile?.bio != null && _profile!.bio!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(color: AppColors.lightBorder, height: 1),
                          const SizedBox(height: 10),
                          Text(
                            _profile!.bio!,
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Secondary Full Width Edit Profile Action
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _openEditProfile,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryMaroon,
                        side: const BorderSide(color: AppColors.primaryMaroon, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.edit_note_rounded, size: 20),
                      label: Text(
                        'Edit Acharya Profile & Vedic Details',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Rate Settings Section
                  Text(
                    'Manage Consultation Rates (Per Minute)',
                    style: GoogleFonts.cinzel(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRateCard('Video Consultation', _videoRate, Icons.videocam, AppColors.primaryMaroon, (val) {
                    setState(() => _videoRate = val);
                  }),
                  _buildRateCard('Voice Call Consultation', _voiceRate, Icons.phone, AppColors.deepAmber, (val) {
                    setState(() => _voiceRate = val);
                  }),
                  _buildRateCard('Live Vedic Chat', _chatRate, Icons.chat, AppColors.statusOnline, (val) {
                    setState(() => _chatRate = val);
                  }),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSavingRates ? null : _saveRates,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryMaroon,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSavingRates
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Save & Update Rates',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Expertise Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Vedic Specializations',
                        style: GoogleFonts.cinzel(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      InkWell(
                        onTap: _openEditProfile,
                        child: Text(
                          'Modify',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryMaroon,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (_profile?.specialities != null && _profile!.specialities!.isNotEmpty)
                        ? _profile!.specialities!
                            .split(',')
                            .map((s) => s.trim())
                            .where((s) => s.isNotEmpty)
                            .map((spec) => _buildBadge(spec))
                            .toList()
                        : [
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Consultation Languages',
                        style: GoogleFonts.cinzel(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      InkWell(
                        onTap: _openEditProfile,
                        child: Text(
                          'Modify',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryMaroon,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (_profile?.languages != null && _profile!.languages!.isNotEmpty)
                        ? _profile!.languages!
                            .split(',')
                            .map((l) => l.trim())
                            .where((l) => l.isNotEmpty)
                            .map((lang) => _buildBadge(lang))
                            .toList()
                        : [
                            _buildBadge('Hindi (Native)'),
                            _buildBadge('Sanskrit'),
                            _buildBadge('English'),
                            _buildBadge('Gujarati'),
                          ],
                  ),
                  const SizedBox(height: 24),

                  // Ashram & Vedic Certifications Gallery with Images
                  _buildCertificationsGallery(),
                  const SizedBox(height: 20),

                  // Mandirm Partner Trust Badge
                  _buildTrustBadge(),
                  const SizedBox(height: 24),

                  // Platform Tour & Onboarding Guide Action
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AstrologerOnboardingScreen(isTourMode: true),
                          ),
                        );
                      },
                      icon: const Icon(Icons.menu_book_rounded, color: AppColors.primaryMaroon),
                      label: Text(
                        'Acharya Onboarding & Platform Tour',
                        style: GoogleFonts.poppins(
                          color: AppColors.primaryMaroon,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warmCream,
                        elevation: 0,
                        side: BorderSide(color: AppColors.marigoldGold.withOpacity(0.6)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Sign Out Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: Text(
                              'Sign Out of Acharya Portal?',
                              style: GoogleFonts.cinzel(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: Text(
                              'Your status will be set to Offline and you will not receive incoming consultation calls.',
                              style: GoogleFonts.poppins(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.pop(ctx);
                                  await AuthService().signOut();
                                  if (!context.mounted) return;
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (_) => const AstrologerLoginScreen()),
                                    (route) => false,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.statusOffline,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Sign Out'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.logout_rounded, color: AppColors.statusOffline),
                      label: Text(
                        'Sign Out from Console',
                        style: GoogleFonts.poppins(
                          color: AppColors.statusOffline,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.statusOffline),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateCard(String title, double currentVal, IconData icon, Color color, ValueChanged<double> onChanged) {
    return Container(
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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                '₹${currentVal.toInt()} / min',
                style: GoogleFonts.poppins(
                  color: AppColors.primaryMaroon,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Slider(
            value: currentVal,
            min: 15.0,
            max: 100.0,
            divisions: 17,
            activeColor: AppColors.primaryMaroon,
            inactiveColor: AppColors.lightBorder,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warmCream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildCertificationsGallery() {
    final certificates = [
      {
        'title': 'Vedic Jyotish Gold Medal',
        'sub': 'Banaras Hindu University',
        'image': AppConstants.catBooksAsset,
      },
      {
        'title': 'Kashi Vishwanath Pratiṣṭhā',
        'sub': 'Auspicious Ritual Degree',
        'image': AppConstants.pujaGangaDiyaAsset,
      },
      {
        'title': 'Vedic Yantra Certification',
        'sub': 'All India Jyotish Mahasabha',
        'image': AppConstants.catYantraAsset,
      },
      {
        'title': 'Certified Ratna Kendra',
        'sub': 'Authentic Gemology Seal',
        'image': AppConstants.deityRudrakshaAsset,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ashram & Vedic Certifications',
              style: GoogleFonts.cinzel(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Verified Credentials',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.statusOnline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: certificates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final c = certificates[i];
              return Container(
                width: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.lightBorder),
                  boxShadow: const [
                    BoxShadow(color: Color(0x06000000), blurRadius: 4, offset: Offset(0, 1.5)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      child: SizedBox(
                        height: 75,
                        width: double.infinity,
                        child: AppImage.network(
                          AppConstants.cdnUrl(c['image']!),
                          fallbackAsset: AppConstants.logoAsset,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c['title']!,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            c['sub']!,
                            style: GoogleFonts.poppins(
                              fontSize: 9.5,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrustBadge() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warmCream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.marigoldGold.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(6),
            child: Image.asset(
              AppConstants.flameLogoAsset,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.security, color: AppColors.primaryMaroon),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mandirm Verified Acharya Seal',
                  style: GoogleFonts.cinzel(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'KYC Verified • ISO 9001:2015 Vedic Standard • 100% Confidential',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
