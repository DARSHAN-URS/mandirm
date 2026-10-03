import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/locale_service.dart';
import '../../home/widgets/devotional_drawer_sheet.dart';
import '../../notifications/screens/notifications_screen.dart';

/// Interactive dual-capsule language toggle button (EN | हि)
class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LocaleService().locale,
      builder: (context, currentLocale, _) {
        final isHi = currentLocale == LocaleService.hi;

        return GestureDetector(
          onTap: () {
            LocaleService().toggle();
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F2E8),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFDECDB4),
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // English Capsule
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: !isHi ? const Color(0xFF7A0C16) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'EN',
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      fontWeight: !isHi ? FontWeight.w700 : FontWeight.w500,
                      color: !isHi ? const Color(0xFFFFF6E5) : const Color(0xFF8C7B70),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                // Hindi Capsule
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: isHi ? const Color(0xFF7A0C16) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'हि',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: isHi ? FontWeight.w700 : FontWeight.w500,
                      color: isHi ? const Color(0xFFFFF6E5) : const Color(0xFF8C7B70),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Unified Mandirm App Header used across the entire application.
/// Provides identical branding, navigation (Menu or Back), Language Toggle,
/// and Notification Bell on every screen.
class MandirmHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool? showBackButton;
  final VoidCallback? onBackTap;
  final VoidCallback? onMenuTap;
  final Widget? trailing;
  final bool showLanguageToggle;
  final bool showNotification;
  final Color? backgroundColor;
  final bool showBottomBorder;
  final bool isAppBar;
  final Widget? titleOverride;

  const MandirmHeader({
    super.key,
    this.showBackButton,
    this.onBackTap,
    this.onMenuTap,
    this.trailing,
    this.showLanguageToggle = true,
    this.showNotification = true,
    this.backgroundColor,
    this.showBottomBorder = true,
    this.isAppBar = false,
    this.titleOverride,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  static const Color _primaryMaroon = Color(0xFF7A0C16);
  static const Color _headerBg = Color(0xFFFFFDF9);
  static const Color _borderColor = Color(0xFFEDE4D4);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final shouldShowBack = showBackButton ?? canPop;
    final topPadding = isAppBar ? 0.0 : MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14, topPadding + 6, 14, 10),
      decoration: BoxDecoration(
        color: backgroundColor ?? _headerBg,
        border: showBottomBorder
            ? const Border(
                bottom: BorderSide(
                  color: _borderColor,
                  width: 1.0,
                ),
              )
            : null,
        boxShadow: showBottomBorder
            ? const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 4,
                  offset: Offset(0, 1.5),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Navigation Action (Back arrow or Hamburger menu)
          if (shouldShowBack)
            GestureDetector(
              onTap: onBackTap ?? () => Navigator.pop(context),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: _primaryMaroon,
                  size: 22,
                ),
              ),
            )
          else
            GestureDetector(
              onTap: onMenuTap ?? () => DevotionalDrawerSheet.show(context),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.menu_rounded,
                  color: _primaryMaroon,
                  size: 25,
                ),
              ),
            ),

          const SizedBox(width: 8),

          // 2. Central Mandirm Emblem Branding (Flame + ॥ मंदिरम् ॥ + Tagline)
          Expanded(
            child: titleOverride ??
                GestureDetector(
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.popUntil(context, (r) => r.isFirst);
                    } else {
                      DevotionalDrawerSheet.show(context);
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Mandirm Flame Diya Logo
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: Image.asset(
                          AppConstants.flameLogoAsset,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.local_fire_department_rounded,
                            color: Color(0xFFD64D18),
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Mandirm Typography with dynamically localized tagline
                      ValueListenableBuilder<String>(
                        valueListenable: LocaleService().locale,
                        builder: (context, _, __) {
                          final isHindi = LocaleService().isHindi;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '॥ मंदिरम् ॥',
                                style: GoogleFonts.rozhaOne(
                                  fontSize: 19.5,
                                  fontWeight: FontWeight.w700,
                                  color: _primaryMaroon,
                                  letterSpacing: 0.5,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                isHindi
                                    ? '• आस्था • आनंद • अध्यात्म •'
                                    : '• Aastha • Anand • Adhyatm •',
                                style: GoogleFonts.poppins(
                                  fontSize: 7.2,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF8B2510),
                                  letterSpacing: 0.6,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
          ),

          // 3. Right Action Area: Language Toggle + Optional Trailing + Notification Bell
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Language Switcher (EN | हि)
              if (showLanguageToggle) ...[
                const LanguageToggleButton(),
                const SizedBox(width: 8),
              ],

              // Optional Trailing Widget (e.g., QR Scanner, Search, Cart)
              if (trailing != null) ...[
                trailing!,
                const SizedBox(width: 8),
              ],

              // Notification Bell with Badge Dot
              if (showNotification)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFDECDB4),
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0C000000),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_none_rounded,
                          color: _primaryMaroon,
                          size: 19,
                        ),
                        Positioned(
                          top: 7,
                          right: 7,
                          child: Container(
                            width: 6.5,
                            height: 6.5,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD32F2F),
                              shape: BoxShape.circle,
                            ),
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
    );
  }
}
