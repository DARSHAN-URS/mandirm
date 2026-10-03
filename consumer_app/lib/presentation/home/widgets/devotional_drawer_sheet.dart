import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/supabase_service.dart';
import '../../bookings/screens/bookings_screen.dart';
import '../../consultations/screens/consultations_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../shop/screens/prasad_orders_screen.dart';
import '../../temples/screens/temples_screen.dart';
import '../../../core/l10n/locale_service.dart';
import '../../../core/l10n/app_strings.dart';
import '../../common/widgets/mandirm_header.dart';

/// Unified Devotional Navigation Drawer / Bottom Sheet for the Mandirm App.
/// Solves all navigation dead-ends when tapping the Hamburger icon anywhere in the app.
class DevotionalDrawerSheet extends StatelessWidget {
  final Function(int tabIndex)? onSelectTab;

  const DevotionalDrawerSheet({
    super.key,
    this.onSelectTab,
  });

  static Future<void> show(BuildContext context, {Function(int tabIndex)? onSelectTab}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DevotionalDrawerSheet(onSelectTab: onSelectTab),
    );
  }

  static const Color _primaryMaroon = Color(0xFF7A0C16);
  static const Color _darkCharcoal = Color(0xFF2C2420);
  static const Color _cardBorder = Color(0xFFEDE4D4);
  static const Color _warmCreamBg = Color(0xFFFFFDF8);

  @override
  Widget build(BuildContext context) {
    final user = SupabaseService().currentUser;
    final bool isLoggedIn = user != null;
    final userName = user?.userMetadata?['full_name'] as String? ??
        user?.userMetadata?['name'] as String? ??
        'Devotee';
    final userAvatar = user?.userMetadata?['avatar_url'] as String? ??
        user?.userMetadata?['picture'] as String?;
    final userEmail = user?.email ?? 'devotee@mandirm.in';

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
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

          // Header Branding & Profile Row
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _cardBorder, width: 1)),
            ),
            child: Row(
              children: [
                // Devotee Avatar or Flame Logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: (isLoggedIn && userAvatar != null && userAvatar.isNotEmpty)
                      ? Image.network(
                          userAvatar,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            AppConstants.flameLogoAsset,
                            width: 44,
                            height: 44,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.local_fire_department_rounded,
                              color: Color(0xFFD64D18),
                              size: 38,
                            ),
                          ),
                        )
                      : Image.asset(
                          AppConstants.flameLogoAsset,
                          width: 44,
                          height: 44,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.local_fire_department_rounded,
                            color: Color(0xFFD64D18),
                            size: 38,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '॥ मंदिरम् ॥',
                        style: GoogleFonts.rozhaOne(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: _primaryMaroon,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        LocaleService().isHindi
                            ? '• आस्था • आनंद • अध्यात्म •'
                            : '• Faith • Peace • Spirituality •',
                        style: GoogleFonts.poppins(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF8B2510),
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${AppStrings.t('namaste')}, $userName 🙏',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: _darkCharcoal,
                        ),
                      ),
                      Text(
                        userEmail,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: _darkCharcoal),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Language Quick Selector in Drawer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF9F5EC),
              border: Border(bottom: BorderSide(color: _cardBorder, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.language_rounded, size: 18, color: _primaryMaroon),
                    const SizedBox(width: 8),
                    ValueListenableBuilder<String>(
                      valueListenable: LocaleService().locale,
                      builder: (context, _, __) {
                        return Text(
                          AppStrings.t('language_selector_label'),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _darkCharcoal,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const LanguageToggleButton(),
              ],
            ),
          ),

          // Scrollable Navigation Links
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Group 1: Core Sanatan Sevas
                _buildSectionHeader(AppStrings.t('drawer_sevas_header')),
                _buildMenuItem(
                  icon: Icons.home_rounded,
                  iconColor: const Color(0xFFD84315),
                  title: AppStrings.t('drawer_home_title'),
                  subtitle: AppStrings.t('drawer_home_sub'),
                  onTap: () {
                    Navigator.pop(context);
                    if (onSelectTab != null) {
                      onSelectTab!(0);
                    } else if (Navigator.canPop(context)) {
                      Navigator.popUntil(context, (r) => r.isFirst);
                    }
                  },
                ),
                _buildMenuItem(
                  icon: Icons.temple_hindu_rounded,
                  iconColor: const Color(0xFF7A0C16),
                  title: AppStrings.t('drawer_temples_title'),
                  subtitle: AppStrings.t('drawer_temples_sub'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TemplesScreen()),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.spa_rounded,
                  iconColor: const Color(0xFFD64D18),
                  title: AppStrings.t('drawer_pujas_title'),
                  subtitle: AppStrings.t('drawer_pujas_sub'),
                  onTap: () {
                    Navigator.pop(context);
                    if (onSelectTab != null) {
                      onSelectTab!(1);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BookingsScreen()),
                      );
                    }
                  },
                ),
                _buildMenuItem(
                  icon: Icons.brightness_7_rounded,
                  iconColor: const Color(0xFFE65100),
                  title: AppStrings.t('drawer_astro_title'),
                  subtitle: AppStrings.t('drawer_astro_sub'),
                  onTap: () {
                    Navigator.pop(context);
                    if (onSelectTab != null) {
                      onSelectTab!(2);
                    }
                  },
                ),
                _buildMenuItem(
                  icon: Icons.volunteer_activism_rounded,
                  iconColor: const Color(0xFF8B1E1E),
                  title: AppStrings.t('drawer_chadhawa_title'),
                  subtitle: AppStrings.t('drawer_chadhawa_sub'),
                  onTap: () {
                    Navigator.pop(context);
                    if (onSelectTab != null) {
                      onSelectTab!(3);
                    }
                  },
                ),
                _buildMenuItem(
                  icon: Icons.shopping_bag_rounded,
                  iconColor: const Color(0xFF5D4037),
                  title: AppStrings.t('drawer_store_title'),
                  subtitle: AppStrings.t('drawer_store_sub'),
                  onTap: () {
                    Navigator.pop(context);
                    if (onSelectTab != null) {
                      onSelectTab!(4);
                    }
                  },
                ),

                const Divider(height: 24, color: _cardBorder),

                // Group 2: My Devotional Records
                _buildSectionHeader(AppStrings.t('drawer_devotee_corner')),
                _buildMenuItem(
                  icon: Icons.receipt_long_rounded,
                  iconColor: const Color(0xFF7A0C16),
                  title: AppStrings.t('drawer_bookings_title'),
                  subtitle: AppStrings.t('drawer_bookings_sub'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BookingsScreen()),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.history_edu_rounded,
                  iconColor: const Color(0xFFD64D18),
                  title: AppStrings.t('drawer_consultations_title'),
                  subtitle: AppStrings.t('drawer_consultations_sub'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ConsultationsScreen()),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.local_shipping_rounded,
                  iconColor: const Color(0xFF2E7D32),
                  title: AppStrings.t('drawer_prasad_title'),
                  subtitle: AppStrings.t('drawer_prasad_sub'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PrasadOrdersScreen()),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.notifications_active_rounded,
                  iconColor: const Color(0xFFF57C00),
                  title: AppStrings.t('drawer_notifications_title'),
                  subtitle: AppStrings.t('drawer_notifications_sub'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.person_pin_rounded,
                  iconColor: const Color(0xFF455A64),
                  title: AppStrings.t('drawer_profile_title'),
                  subtitle: AppStrings.t('drawer_profile_sub'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                ),

                const Divider(height: 24, color: _cardBorder),

                // Group 3: Auth Action (Sign In / Sign Out)
                if (isLoggedIn)
                  _buildMenuItem(
                    icon: Icons.logout_rounded,
                    iconColor: const Color(0xFFC62828),
                    title: AppStrings.t('drawer_sign_out_title'),
                    subtitle: AppStrings.t('drawer_sign_out_sub'),
                    onTap: () async {
                      Navigator.pop(context);
                      await SupabaseService().signOut();
                    },
                  )
                else
                  _buildMenuItem(
                    icon: Icons.login_rounded,
                    iconColor: _primaryMaroon,
                    title: AppStrings.t('drawer_sign_in_title'),
                    subtitle: AppStrings.t('drawer_sign_in_sub'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/login');
                    },
                  ),

                const SizedBox(height: 16),

                // Seva Kendra Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFD54F)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFF25D366),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.t('help_support'),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: const Color(0xFF7A0C16),
                              ),
                            ),
                            Text(
                              LocaleService().isHindi
                                  ? 'संकल्प या पंडित जी से सहायता चाहिए? संपर्क करें।'
                                  : 'Need help with Sankalp or Pandit Ji? Call or WhatsApp anytime.',
                              style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF5D4037)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF8C7B70),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder.withValues(alpha: 0.8)),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _darkCharcoal,
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 10.5,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Color(0xFFBCAAA4)),
      ),
    );
  }
}
