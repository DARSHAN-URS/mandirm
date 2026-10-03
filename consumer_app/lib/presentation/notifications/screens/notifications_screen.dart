import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/api_service.dart';
import '../../bookings/screens/bookings_screen.dart';
import '../../consultations/screens/consultations_screen.dart';
import '../../shop/screens/prasad_orders_screen.dart';
import '../../temples/screens/temples_screen.dart';
import '../../common/widgets/mandirm_header.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedFilterIndex = 0;

  static const Color _primaryMaroon = Color(0xFF7A0C16);
  static const Color _darkCharcoal = Color(0xFF1E1E1E);
  static const Color _cardBorder = Color(0xFFEFE6D8);

  final List<String> _filters = ['All', 'Live Darshan', 'Orders & Prasad', 'Chadava Sankalp'];

  @override
  void initState() {
    super.initState();
    _fetchBackendNotifications();
  }

  Future<void> _fetchBackendNotifications() async {
    try {
      final backendNotifs = await ApiService().getMyNotifications();
      if (backendNotifs.isNotEmpty && mounted) {
        setState(() {
          for (final bn in backendNotifs) {
            final id = bn['id']?.toString() ?? 'NOTIF-${bn.hashCode}';
            if (!_notifications.any((item) => item['id'] == id)) {
              _notifications.insert(0, {
                'id': id,
                'title': bn['title'] ?? 'Sacred Update 🙏',
                'subtitle': bn['message'] ?? bn['body'] ?? 'Mandir Seva update for you',
                'time': 'Just now',
                'category': bn['category'] ?? 'All',
                'isUnread': true,
                'icon': Icons.notifications_active_rounded,
                'iconColor': const Color(0xFFD84315),
                'iconBg': const Color(0xFFFFEBE5),
              });
            }
          }
        });
      }
    } catch (_) {}
  }

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 'NOTIF-01',
      'title': 'Bhasma Aarti Starting in 10 mins 🪔',
      'subtitle': 'Live sanctum streaming from Shree Mahakaleshwar Jyotirlinga, Ujjain is now open.',
      'time': 'Just now',
      'category': 'Live Darshan',
      'isUnread': true,
      'icon': Icons.local_fire_department_rounded,
      'iconColor': const Color(0xFFD84315),
      'iconBg': const Color(0xFFFFEBE5),
    },
    {
      'id': 'NOTIF-02',
      'title': 'Holy Mahakal Pendant Dispatched! 📦',
      'subtitle': 'Consecration completed by temple purohit. Tracking ID: BLUEDART-8492019.',
      'time': '2 hours ago',
      'category': 'Orders & Prasad',
      'isUnread': true,
      'icon': Icons.local_shipping_rounded,
      'iconColor': const Color(0xFF2E7D32),
      'iconBg': const Color(0xFFE8F5E9),
    },
    {
      'id': 'NOTIF-03',
      'title': 'Chadava Sankalp Recited at Kashi 🕉️',
      'subtitle': 'Your Akhand Ghee Diya offering video clip has been generated for Gotra Kashyap.',
      'time': 'Yesterday',
      'category': 'Chadava Sankalp',
      'isUnread': false,
      'icon': Icons.volunteer_activism_rounded,
      'iconColor': _primaryMaroon,
      'iconBg': const Color(0xFFFFF0F1),
    },
    {
      'id': 'NOTIF-04',
      'title': 'Navratri Special Puja Samagri Available 🌺',
      'subtitle': 'Special 28% OFF on authentic Akhand Jyoti kits & Vedic brass idols in Puja Store.',
      'time': '2 days ago',
      'category': 'Orders & Prasad',
      'isUnread': false,
      'icon': Icons.spa_rounded,
      'iconColor': const Color(0xFFE65100),
      'iconBg': const Color(0xFFFFF3E0),
    },
    {
      'id': 'NOTIF-05',
      'title': 'Astrology Consultation Reminder ⭐',
      'subtitle': 'Your 1-on-1 session with Pandit Acharya Rajesh Sharma is confirmed for tomorrow.',
      'time': '3 days ago',
      'category': 'All',
      'isUnread': false,
      'icon': Icons.brightness_7_rounded,
      'iconColor': const Color(0xFFF9A825),
      'iconBg': const Color(0xFFFFFDE7),
    },
  ];

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n['isUnread'] = false;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _notifications.where((n) {
      if (_selectedFilterIndex == 0) return true;
      return n['category'] == _filters[_selectedFilterIndex];
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F3),
      body: Column(
        children: [
          MandirmHeader(
            showNotification: false,
            trailing: GestureDetector(
              onTap: _markAllAsRead,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F1E5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFDECDB4)),
                ),
                child: Text(
                  'Mark Read',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _primaryMaroon,
                  ),
                ),
              ),
            ),
          ),
          // Filter Tabs
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _filters.length,
              itemBuilder: (context, idx) {
                final isSel = _selectedFilterIndex == idx;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilterIndex = idx),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? _primaryMaroon : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSel ? _primaryMaroon : const Color(0xFFE5DDD0),
                      ),
                    ),
                    child: Text(
                      _filters[idx],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        color: isSel ? Colors.white : _darkCharcoal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Notifications List
          Expanded(
            child: filteredNotifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.notifications_none_rounded, size: 54, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'No notifications in this category',
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final item = filteredNotifications[index];
                      final bool isUnread = item['isUnread'] as bool;

                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          setState(() {
                            item['isUnread'] = false;
                          });
                          final cat = item['category']?.toString() ?? '';
                          final title = item['title']?.toString() ?? '';

                          if (cat == 'Live Darshan' || title.contains('Aarti')) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TemplesScreen()),
                            );
                          } else if (cat == 'Orders & Prasad' || title.contains('Dispatched') || title.contains('Pendant')) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const PrasadOrdersScreen()),
                            );
                          } else if (cat == 'Chadava Sankalp' || title.contains('Sankalp')) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const BookingsScreen()),
                            );
                          } else if (title.contains('Astrology') || title.contains('Consultation')) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ConsultationsScreen()),
                            );
                          }
                        },
                        child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isUnread ? const Color(0xFFFFFDF8) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isUnread ? const Color(0xFFFFD54F) : _cardBorder,
                            width: isUnread ? 1.5 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.brown.withAlpha(8),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon Avatar
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: item['iconBg'] as Color,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color: item['iconColor'] as Color,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Content
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
                                            fontSize: 13,
                                            fontWeight:
                                                isUnread ? FontWeight.w700 : FontWeight.w600,
                                            color: _darkCharcoal,
                                          ),
                                        ),
                                      ),
                                      if (isUnread)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFD32F2F),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['subtitle'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.5,
                                      color: Colors.grey.shade700,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item['time'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w500,
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
