import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../common/widgets/app_image.dart';
import '../../common/widgets/mandirm_header.dart';

class AstrologerNotificationsScreen extends StatefulWidget {
  const AstrologerNotificationsScreen({super.key});

  @override
  State<AstrologerNotificationsScreen> createState() => _AstrologerNotificationsScreenState();
}

class _AstrologerNotificationsScreenState extends State<AstrologerNotificationsScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', 'Live Queue', 'Earnings', 'Reviews'];

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 'NOTIF-01',
      'title': 'New Devotee in Waiting Queue 🔔',
      'subtitle': 'Aarav Sharma has entered the queue for Vedic Kundli Consultation.',
      'time': 'Just now',
      'category': 'Live Queue',
      'isUnread': true,
      'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      'icon': Icons.headset_mic_rounded,
      'iconColor': AppColors.saffronPrimary,
      'iconBg': const Color(0xFFFFEBE5),
    },
    {
      'id': 'NOTIF-02',
      'title': 'Earnings Credited 💰',
      'subtitle': '₹1,450.00 for 35 min video consultation with Priya Sharma deposited to wallet.',
      'time': '12m ago',
      'category': 'Earnings',
      'isUnread': true,
      'image': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
      'icon': Icons.account_balance_wallet_rounded,
      'iconColor': AppColors.statusOnline,
      'iconBg': const Color(0xFFE8F5E9),
    },
    {
      'id': 'NOTIF-03',
      'title': '5-Star Review Received ⭐',
      'subtitle': '"Pandit ji gave very accurate horoscope predictions and simple remedies. Highly blessed!"',
      'time': '1h ago',
      'category': 'Reviews',
      'isUnread': false,
      'image': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      'icon': Icons.star_rounded,
      'iconColor': AppColors.marigoldGold,
      'iconBg': const Color(0xFFFFF8E1),
    },
    {
      'id': 'NOTIF-04',
      'title': 'Scheduled Puja Consultation',
      'subtitle': 'Upcoming session tomorrow at 09:30 AM with Vikramaditya for Mahamrityunjaya Puja.',
      'time': '3h ago',
      'category': 'Live Queue',
      'isUnread': false,
      'image': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
      'icon': Icons.calendar_month_rounded,
      'iconColor': AppColors.primaryMaroon,
      'iconBg': const Color(0xFFFBE9E7),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedFilterIndex == 0
        ? _notifications
        : _notifications.where((n) => n['category'] == _filters[_selectedFilterIndex]).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // Unified Mandirm Header with back button
          const MandirmHeader(
            showBackButton: true,
            showNotification: false,
          ),

          // Title & Filter Chips
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            decoration: const BoxDecoration(
              color: AppColors.headerBg,
              border: Border(bottom: BorderSide(color: AppColors.lightBorder, width: 1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Acharya Notifications',
                      style: GoogleFonts.cinzel(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          for (var item in _notifications) {
                            item['isUnread'] = false;
                          }
                        });
                      },
                      child: Text(
                        'Mark all read',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryMaroon,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_filters.length, (index) {
                      final isSelected = _selectedFilterIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: isSelected,
                          showCheckmark: false,
                          label: Text(_filters[index]),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                          backgroundColor: Colors.white,
                          selectedColor: AppColors.primaryMaroon,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppColors.primaryMaroon : AppColors.lightBorder,
                            ),
                          ),
                          onSelected: (selected) {
                            setState(() => _selectedFilterIndex = index);
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // Notifications List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.warmCream,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.marigoldGold.withOpacity(0.4)),
                          ),
                          child: Image.asset(
                            AppConstants.flameLogoAsset,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(Icons.notifications_none, color: AppColors.textMuted),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'No notifications in this category.',
                          style: GoogleFonts.poppins(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = filtered[index];
                final isUnread = item['isUnread'] as bool;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      item['isUnread'] = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Notice "${item['title']}" marked as read.'),
                        duration: const Duration(seconds: 1),
                        backgroundColor: AppColors.primaryMaroon,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUnread ? const Color(0xFFFFF9ED) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isUnread ? AppColors.marigoldGold.withOpacity(0.5) : AppColors.lightBorder,
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x06000000),
                          blurRadius: 4,
                          offset: Offset(0, 1.5),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Stack(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.lightBorder, width: 1.2),
                            ),
                            child: ClipOval(
                              child: item['image'] != null
                                  ? AppImage.network(
                                      item['image'] as String,
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: item['iconBg'] as Color,
                                      child: Icon(
                                        item['icon'] as IconData,
                                        color: item['iconColor'] as Color,
                                        size: 22,
                                      ),
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                color: item['iconColor'] as Color,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color: Colors.white,
                                size: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item['title'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.5,
                                      fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Text(
                                  item['time'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['subtitle'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            ),
          ),
        ],
      ),
    );
  }
}
