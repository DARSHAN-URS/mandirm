import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/supabase_service.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Sign Out?',
          style: GoogleFonts.cinzel(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to end this sacred session?',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sacredCrimson,
              minimumSize: const Size(90, 40),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(const SignOutEvent());
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: _buildAppBar(),
        body: IndexedStack(
          index: _currentTabIndex,
          children: [
            _buildHomeTab(),
            _buildTemplesPlaceholder(),
            _buildPujasPlaceholder(),
            _buildAstrologersPlaceholder(),
            _buildProfileTab(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentTabIndex,
          onDestinationSelected: (index) {
            setState(() => _currentTabIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: AppColors.saffronPrimary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.temple_hindu_outlined),
              selectedIcon: Icon(Icons.temple_hindu, color: AppColors.saffronPrimary),
              label: 'Temples',
            ),
            NavigationDestination(
              icon: Icon(Icons.local_fire_department_outlined),
              selectedIcon:
                  Icon(Icons.local_fire_department, color: AppColors.saffronPrimary),
              label: 'Pujas',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon:
                  Icon(Icons.auto_awesome, color: AppColors.saffronPrimary),
              label: 'Astrology',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: AppColors.saffronPrimary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final supabase = SupabaseService();
    final user = supabase.currentUser;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.marigoldGold, width: 1.5),
            ),
            child: ClipOval(
              child: Image.asset(
                AppConstants.logoAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.temple_hindu,
                  size: 24,
                  color: AppColors.saffronPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Namaste, ${user?.userMetadata?['full_name'] ?? 'Devotee'} 🙏',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Online • Supabase Connected',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No new notifications'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: AppColors.sacredCrimson),
          onPressed: _confirmSignOut,
        ),
      ],
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Panchang & Auspicious Muhurat Card
          _buildPanchangCard(),

          const SizedBox(height: 16),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.saffronPrimary),
                  const SizedBox(width: 10),
                  Text(
                    'Search Mandirs, Pujas, Astrologers...',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Quick Devotional Actions
          _buildQuickActionGrid(),

          const SizedBox(height: 24),

          // Featured Mandirs Section
          _buildSectionHeader('Sacred Mandirs', 'View All 108', () {
            setState(() => _currentTabIndex = 1);
          }),
          _buildMandirsHorizontalList(),

          const SizedBox(height: 24),

          // Upcoming Special Pujas
          _buildSectionHeader('Live & Special Pujas', 'Explore', () {
            setState(() => _currentTabIndex = 2);
          }),
          _buildPujaCards(),

          const SizedBox(height: 24),

          // Top Astrologers
          _buildSectionHeader('Vedic Astrologers', 'Consult Now', () {
            setState(() => _currentTabIndex = 3);
          }),
          _buildAstrologersHorizontalList(),
        ],
      ),
    );
  }

  Widget _buildPanchangCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6B1D0E),
            Color(0xFFB91C1C),
            Color(0xFFFF6B35),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.saffronPrimary.withAlpha(50),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withAlpha(100)),
                ),
                child: Row(
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      'TODAY\'S PANCHANG',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.amber.shade200,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Text('🚩', style: TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Shukla Paksha • Navami Tithi',
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Auspicious Muhurat: Abhijit Muhurat 11:45 AM - 12:35 PM • Rahu Kaal 04:30 PM',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFFFDE68A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionGrid() {
    final actions = [
      {'icon': '🛕', 'title': 'Mandirs', 'subtitle': 'Live Darshan', 'tab': 1},
      {'icon': '🔥', 'title': 'Book Puja', 'subtitle': 'Sankalp Online', 'tab': 2},
      {'icon': '🌸', 'title': 'Chadhawa', 'subtitle': 'Direct Prasad', 'tab': 2},
      {'icon': '🔮', 'title': 'Astrology', 'subtitle': 'Call & Chat', 'tab': 3},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: actions.map((item) {
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _currentTabIndex = item['tab'] as int);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(6),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(item['icon'] as String, style: const TextStyle(fontSize: 26)),
                    const SizedBox(height: 8),
                    Text(
                      item['title'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      item['subtitle'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String actionText, VoidCallback onAction) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.cinzel(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionText,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.saffronPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMandirsHorizontalList() {
    final mandirs = [
      {
        'name': 'Kashi Vishwanath Mandir',
        'city': 'Varanasi, UP',
        'deity': 'Lord Shiva',
        'status': 'Live Darshan Open',
      },
      {
        'name': 'Mahakaleshwar Jyotirlinga',
        'city': 'Ujjain, MP',
        'deity': 'Mahakal',
        'status': 'Bhasma Aarti Available',
      },
      {
        'name': 'Tirupati Balaji Mandir',
        'city': 'Tirumala, AP',
        'deity': 'Lord Venkateswara',
        'status': 'Seva Booking Open',
      },
    ];

    return SizedBox(
      height: 160,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: mandirs.length,
        itemBuilder: (context, i) {
          final m = mandirs[i];
          return Container(
            width: 240,
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(6),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warmCream,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        m['deity']!,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.deepAmber,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: AppColors.saffronPrimary),
                  ],
                ),
                const Spacer(),
                Text(
                  m['name']!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '📍 ${m['city']!}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      m['status']!,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPujaCards() {
    final pujas = [
      {
        'title': 'Maha Rudrabhishek with 108 Bilva Patra',
        'mandir': 'Kashi Vishwanath, Varanasi',
        'date': 'Tomorrow, 08:00 AM',
        'price': '₹ 1,100',
      },
      {
        'title': 'Navchandi Shatru & Graha Shanti Homa',
        'mandir': 'Kamakhya Devi, Guwahati',
        'date': 'Coming Sunday',
        'price': '₹ 2,501',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: pujas.map((p) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('🔥', style: TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p['title']!,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${p['mandir']} • ${p['date']}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p['price']!,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.saffronDark,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Selected: ${p['title']}')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(64, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text('Book', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAstrologersHorizontalList() {
    final astrologers = [
      {
        'name': 'Pt. Devendra Shastri',
        'specialty': 'Vedic • Kundali • Vastu',
        'exp': '18+ yrs',
        'rating': '4.9 ★',
        'rate': '₹25/min',
      },
      {
        'name': 'Acharya Radheshyam',
        'specialty': 'Prashna Kundali • Career',
        'exp': '12+ yrs',
        'rating': '4.8 ★',
        'rate': '₹20/min',
      },
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: astrologers.length,
        itemBuilder: (context, i) {
          final a = astrologers[i];
          return Container(
            width: 260,
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.warmCream,
                  child: Text('🧘‍♂️', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        a['name']!,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        a['specialty']!,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            a['rating']!,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.deepAmber,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            a['rate']!,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.saffronDark,
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
    );
  }

  Widget _buildTemplesPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🛕', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'Explore 108 Sacred Mandirs',
            style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Live Darshan, History & Seva Booking',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondaryLight),
          ),
        ],
      ),
    );
  }

  Widget _buildPujasPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'Vedic Puja & Chadhawa Offerings',
            style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Personalized Sankalp conducted in your name',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondaryLight),
          ),
        ],
      ),
    );
  }

  Widget _buildAstrologersPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔮', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'Talk with Certified Astrologers',
            style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Call, Chat & Kundali Analysis with Vedic Acharyas',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondaryLight),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    final user = SupabaseService().currentUser;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.warmCream,
            child: Text('🕉️', style: TextStyle(fontSize: 34)),
          ),
          const SizedBox(height: 12),
          Text(
            user?.userMetadata?['full_name'] ?? 'Devotee',
            style: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          if (user?.email != null)
            Text(user!.email!, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
          if (user?.phone != null)
            Text(user!.phone!, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined, color: AppColors.saffronPrimary),
            title: const Text('My Puja Bookings'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline, color: AppColors.saffronPrimary),
            title: const Text('Astrology Consultations'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shopping_bag_outlined, color: AppColors.saffronPrimary),
            title: const Text('My Prasad & Shop Orders'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.sacredCrimson),
            title: const Text('Sign Out', style: TextStyle(color: AppColors.sacredCrimson)),
            onTap: _confirmSignOut,
          ),
        ],
      ),
    );
  }
}
