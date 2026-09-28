import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../earnings/screens/earnings_screen.dart';
import '../../profile/screens/profile_screen.dart';

class AstrologerMainHubScreen extends StatefulWidget {
  const AstrologerMainHubScreen({super.key});

  @override
  State<AstrologerMainHubScreen> createState() => _AstrologerMainHubScreenState();
}

class _AstrologerMainHubScreenState extends State<AstrologerMainHubScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AstrologerDashboardScreen(),
    AstrologerEarningsScreen(),
    AstrologerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AstrologerColors.cosmicCard,
          border: Border(
            top: BorderSide(color: AstrologerColors.borderSubtle, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: AstrologerColors.cosmicCard,
          selectedItemColor: AstrologerColors.vedicGold,
          unselectedItemColor: AstrologerColors.textMuted,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Earnings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Acharya Profile',
            ),
          ],
        ),
      ),
    );
  }
}
