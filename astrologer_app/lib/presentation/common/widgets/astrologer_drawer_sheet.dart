import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/l10n/locale_service.dart';
import '../../../services/auth/auth_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../home/screens/main_hub_screen.dart';
import '../../notifications/screens/notifications_screen.dart';

import 'app_image.dart';

class AstrologerDrawerSheet extends StatelessWidget {
  final Function(int tabIndex)? onSelectTab;

  const AstrologerDrawerSheet({
    super.key,
    this.onSelectTab,
  });

  static Future<void> show(BuildContext context, {Function(int tabIndex)? onSelectTab}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AstrologerDrawerSheet(onSelectTab: onSelectTab),
    );
  }

  static const Color _primaryMaroon = AppColors.primaryMaroon;
  static const Color _cardBorder = AppColors.lightBorder;
  static const Color _warmCreamBg = Color(0xFFFFFDF8);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height * 0.88,
      decoration: const BoxDecoration(
        color: _warmCreamBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            width: 44,
            height: 4.5,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header Branding & Acharya Profile Row
          Builder(
            builder: (context) {
              final profile = AuthService().currentProfile;
              final name = profile?.name ?? 'Pt. Ramachandra Shastri';
              final specializations = (profile != null && profile.specialities != null && profile.specialities!.isNotEmpty)
                  ? '${profile.specialities} • ${profile.experienceYears}+ Yrs Exp'
                  : 'Vedic Astrology & Kundli • 18+ Yrs Exp';
              final rating = profile?.rating ?? 4.92;
              final consultCount = (profile?.consultationsCount != null && profile!.consultationsCount > 0)
                  ? profile.consultationsCount
                  : 1420;
              final String avatar = (profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty)
                  ? profile.avatarUrl!
                  : AppConstants.cdnUrl(AppConstants.astroRajeshAsset);

              return Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: _cardBorder, width: 1)),
                ),
                child: Row(
                  children: [
                    // Flame logo & Acharya Avatar
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
                              avatar,
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
                              color: (profile?.isOnline ?? true)
                                  ? AppColors.statusOnline
                                  : AppColors.statusOffline,
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
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  style: GoogleFonts.cinzel(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.deepAmber.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'VERIFIED',
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.deepAmber,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            specializations,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: AppColors.marigoldGold, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${rating.toStringAsFixed(2)} Rating ($consultCount+ devotees)',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.deepAmber,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.dashboard_rounded,
                  label: AstroStrings.t('drawer_duty_title'),
                  subtitle: AstroStrings.t('drawer_duty_sub'),
                  onTap: () {
                    Navigator.pop(context);
                    if (onSelectTab != null) {
                      onSelectTab!(0);
                    } else {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const AstrologerMainHubScreen(initialIndex: 0)),
                        (r) => false,
                      );
                    }
                  },
                ),
                _buildNavItem(
                  context,
                  icon: Icons.headset_mic_rounded,
                  label: AstroStrings.t('drawer_requests_title'),
                  subtitle: AstroStrings.t('drawer_requests_sub'),
                  onTap: () {
                    Navigator.pop(context);
                    if (onSelectTab != null) {
                      onSelectTab!(1);
                    } else {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const AstrologerMainHubScreen(initialIndex: 1)),
                        (r) => false,
                      );
                    }
                  },
                ),
                _buildNavItem(
                  context,
                  icon: Icons.history_edu_rounded,
                  label: AstroStrings.t('drawer_history_title'),
                  subtitle: AstroStrings.t('drawer_history_sub'),
                  onTap: () {
                    Navigator.pop(context);
                    if (onSelectTab != null) {
                      onSelectTab!(2);
                    } else {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const AstrologerMainHubScreen(initialIndex: 2)),
                        (r) => false,
                      );
                    }
                  },
                ),
                _buildNavItem(
                  context,
                  icon: Icons.account_balance_wallet_rounded,
                  label: AstroStrings.t('drawer_earnings_title'),
                  subtitle: AstroStrings.t('drawer_earnings_sub'),
                  onTap: () {
                    Navigator.pop(context);
                    if (onSelectTab != null) {
                      onSelectTab!(3);
                    } else {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const AstrologerMainHubScreen(initialIndex: 3)),
                        (r) => false,
                      );
                    }
                  },
                ),
                _buildNavItem(
                  context,
                  icon: Icons.person_rounded,
                  label: AstroStrings.t('drawer_profile_title'),
                  subtitle: AstroStrings.t('drawer_profile_sub'),
                  onTap: () {
                    Navigator.pop(context);
                    if (onSelectTab != null) {
                      onSelectTab!(4);
                    } else {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const AstrologerMainHubScreen(initialIndex: 4)),
                        (r) => false,
                      );
                    }
                  },
                ),
                _buildNavItem(
                  context,
                  icon: Icons.notifications_active_rounded,
                  label: AstroStrings.t('drawer_notifications_title'),
                  subtitle: AstroStrings.t('drawer_notifications_sub'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AstrologerNotificationsScreen()),
                    );
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: _cardBorder),
                ),

                _buildNavItem(
                  context,
                  icon: Icons.support_agent_rounded,
                  label: AstroStrings.t('drawer_support_title'),
                  subtitle: AstroStrings.t('drawer_support_sub'),
                  iconColor: AppColors.saffronPrimary,
                  onTap: () {
                    final isHi = LocaleService().isHindi;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isHi
                              ? 'मंदिरम् आचार्य डेस्क से संपर्क हो रहा है: +91 8000 108 108'
                              : 'Connecting to Mandirm Acharya Desk: +91 8000 108 108',
                        ),
                        backgroundColor: _primaryMaroon,
                      ),
                    );
                  },
                ),
                _buildNavItem(
                  context,
                  icon: Icons.logout_rounded,
                  label: AstroStrings.t('drawer_sign_out_title'),
                  subtitle: AstroStrings.t('drawer_sign_out_sub'),
                  iconColor: AppColors.statusOffline,
                  onTap: () async {
                    final isHi = LocaleService().isHindi;
                    Navigator.pop(context);
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Text(
                          isHi ? 'आचार्य पोर्टल से लॉग आउट करें?' : 'Sign Out of Acharya Portal?',
                          style: GoogleFonts.cinzel(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        content: Text(
                          isHi
                              ? 'आपकी स्थिति ऑफलाइन कर दी जाएगी और भक्त आपको परामर्श हेतु कॉल नहीं कर सकेंगे।'
                              : 'Your status will be set to Offline and you will not receive consultation calls.',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(
                              isHi ? 'रद्द करें' : 'Cancel',
                              style: GoogleFonts.poppins(color: AppColors.textSecondary),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.statusOffline,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(isHi ? 'लॉग आउट' : 'Sign Out'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await AuthService().signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const AstrologerLoginScreen()),
                          (route) => false,
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: _cardBorder, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppConstants.flameLogoAsset,
                  width: 18,
                  height: 18,
                  errorBuilder: (_, __, ___) => const Icon(Icons.wb_sunny_rounded, size: 16, color: AppColors.deepAmber),
                ),
                const SizedBox(width: 8),
                Text(
                  '॥ मंदिरम् ज्योतिषाचार्य पोर्टल • v1.0.0 ॥',
                  style: GoogleFonts.cinzel(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder, width: 1),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (iconColor ?? _primaryMaroon).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor ?? _primaryMaroon, size: 22),
        ),
        title: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 11.5,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
