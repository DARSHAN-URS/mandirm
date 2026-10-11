import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/app_strings.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../consultations/screens/consultations_screen.dart';
import '../../history/screens/history_screen.dart';
import '../../earnings/screens/earnings_screen.dart';
import '../../profile/screens/profile_screen.dart';

class AstrologerMainHubScreen extends StatefulWidget {
  final int initialIndex;
  const AstrologerMainHubScreen({super.key, this.initialIndex = 0});

  @override
  State<AstrologerMainHubScreen> createState() => _AstrologerMainHubScreenState();
}

class _AstrologerMainHubScreenState extends State<AstrologerMainHubScreen> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    AstrologerDashboardScreen(),
    AstrologerConsultationsScreen(),
    AstrologerHistoryScreen(),
    AstrologerEarningsScreen(),
    AstrologerProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.headerBg,
          border: Border(
            top: BorderSide(color: AppColors.lightBorder, width: 1.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard_rounded,
                  label: AstroStrings.t('nav_duty'),
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.headset_mic_outlined,
                  activeIcon: Icons.headset_mic_rounded,
                  label: AstroStrings.t('nav_requests'),
                  badgeCount: 3, // Live devotees waiting in queue
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.history_edu_outlined,
                  activeIcon: Icons.history_edu_rounded,
                  label: AstroStrings.t('nav_history'),
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.account_balance_wallet_outlined,
                  activeIcon: Icons.account_balance_wallet_rounded,
                  label: AstroStrings.t('nav_earnings'),
                ),
                _buildNavItem(
                  index: 4,
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: AstroStrings.t('nav_profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    int? badgeCount,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (_currentIndex != index) {
            setState(() => _currentIndex = index);
          }
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected
                ? AppColors.primaryMaroon.withOpacity(0.08)
                : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    isSelected ? activeIcon : icon,
                    size: 23,
                    color: isSelected
                        ? AppColors.primaryMaroon
                        : const Color(0xFF8C7B70),
                  ),
                  if (badgeCount != null && badgeCount > 0)
                    Positioned(
                      top: -4,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryMaroon,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primaryMaroon
                      : const Color(0xFF8C7B70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
