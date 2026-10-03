import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/api_service.dart';
import '../../puja/screens/pujas_screen.dart';
import '../../shop/screens/prasad_orders_screen.dart';
import '../../common/widgets/mandirm_header.dart';

class TemplesScreen extends StatefulWidget {
  final Function(String mandirName)? onBookPuja;
  const TemplesScreen({super.key, this.onBookPuja});

  @override
  State<TemplesScreen> createState() => _TemplesScreenState();
}

class _TemplesScreenState extends State<TemplesScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const Color _primaryMaroon = Color(0xFF7A0C16);
  static const Color _darkCharcoal = Color(0xFF1E1E1E);
  static const Color _cardBorder = Color(0xFFEFE6D8);
  static const Color _warmCreamBg = Color(0xFFFBF8F3);
  static const Color _accentYellow = Color(0xFFFDCB06);

  void _openMyOrders() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PrasadOrdersScreen(),
      ),
    );
  }

  final List<String> _categories = [
    'All',
    'Lord Shiva',
    'Vishnu / Krishna',
    'Maa Durga / Devi',
    'Hanuman Ji',
    'Lord Ganesha',
  ];

  final List<Map<String, dynamic>> _allTemples = [
    {
      'name': 'Kashi Vishwanath Mandir',
      'city': 'Varanasi, Uttar Pradesh',
      'deity': 'Lord Shiva',
      'category': 'Lord Shiva',
      'icon': '🔱',
      'status': 'Live Darshan Streaming',
      'live': true,
      'viewers': '4,821',
      'timings': '03:00 AM - 11:00 PM',
      'description': 'One of the twelve Jyotirlingas, situated on the sacred banks of the Ganges. Devotees receive salvation and immense blessings here.',
      'aartis': [
        {'name': 'Mangala Aarti', 'time': '03:00 AM'},
        {'name': 'Bhog Aarti', 'time': '11:15 AM'},
        {'name': 'Sandhya Aarti', 'time': '07:00 PM'},
        {'name': 'Shayan Aarti', 'time': '10:30 PM'},
      ],
    },
    {
      'name': 'Mahakaleshwar Jyotirlinga',
      'city': 'Ujjain, Madhya Pradesh',
      'deity': 'Mahakal',
      'category': 'Lord Shiva',
      'icon': '🕉️',
      'status': 'Bhasma Aarti Available',
      'live': true,
      'viewers': '6,230',
      'timings': '04:00 AM - 11:00 PM',
      'description': 'Renowned Dakshinmukhi Jyotirlinga on the banks of Shipra river. Famous for its world-renowned divine morning Bhasma Aarti.',
      'aartis': [
        {'name': 'Bhasma Aarti', 'time': '04:00 AM'},
        {'name': 'Naivedya Aarti', 'time': '10:30 AM'},
        {'name': 'Sandhya Aarti', 'time': '05:00 PM'},
        {'name': 'Shayan Aarti', 'time': '10:30 PM'},
      ],
    },
    {
      'name': 'Tirupati Balaji Mandir',
      'city': 'Tirumala, Andhra Pradesh',
      'deity': 'Lord Venkateswara',
      'category': 'Vishnu / Krishna',
      'icon': '🪷',
      'status': 'Suprabhatam & Darshan Open',
      'live': true,
      'viewers': '12,490',
      'timings': '02:30 AM - 01:30 AM',
      'description': 'The abode of Sri Venkateswara on the sacred Seshachalam hills. Devotees pray for boundless prosperity and spiritual liberation.',
      'aartis': [
        {'name': 'Suprabhatam', 'time': '03:00 AM'},
        {'name': 'Thomala Seva', 'time': '03:45 AM'},
        {'name': 'Archana', 'time': '04:30 AM'},
        {'name': 'Ekanta Seva', 'time': '01:30 AM'},
      ],
    },
    {
      'name': 'Siddhivinayak Mandir',
      'city': 'Prabhadevi, Mumbai',
      'deity': 'Lord Ganesha',
      'category': 'Lord Ganesha',
      'icon': '🐘',
      'status': 'Live Darshan Streaming',
      'live': true,
      'viewers': '3,105',
      'timings': '05:30 AM - 10:00 PM',
      'description': 'Sacred two-century-old shrine fulfilling all noble wishes. Devotees offer Modaks and Durva grass to remove all life obstacles.',
      'aartis': [
        {'name': 'Kakad Aarti', 'time': '05:30 AM'},
        {'name': 'Shree Darshan', 'time': '06:00 AM'},
        {'name': 'Noon Aarti', 'time': '12:05 PM'},
        {'name': 'Shejaarti', 'time': '09:50 PM'},
      ],
    },
    {
      'name': 'Maa Vaishno Devi Shrine',
      'city': 'Katra, Jammu & Kashmir',
      'deity': 'Maa Vaishno Devi',
      'category': 'Maa Durga / Devi',
      'icon': '🌸',
      'status': 'Pindi Darshan Open',
      'live': true,
      'viewers': '5,800',
      'timings': '05:00 AM - 10:00 PM',
      'description': 'Holy cave shrine nestled in the Trikuta hills housing the three sacred natural rock formations (Pindis) representing Mahakali, Mahalakshmi, and Mahasaraswati.',
      'aartis': [
        {'name': 'Pratah Aarti', 'time': '06:00 AM'},
        {'name': 'Madhyahna Darshan', 'time': '12:00 PM'},
        {'name': 'Sandhya Aarti', 'time': '07:00 PM'},
      ],
    },
    {
      'name': 'Hanuman Garhi Mandir',
      'city': 'Ayodhya, Uttar Pradesh',
      'deity': 'Hanuman Ji',
      'category': 'Hanuman Ji',
      'icon': '🚩',
      'status': 'Live Aarti Live',
      'live': true,
      'viewers': '2,980',
      'timings': '04:00 AM - 10:00 PM',
      'description': '10th-century temple in the form of a 4-sided fort with 76 steps. Believed that visiting Hanuman Garhi is essential before visiting Ram Janmabhoomi.',
      'aartis': [
        {'name': 'Mangala Aarti', 'time': '04:00 AM'},
        {'name': 'Shringar Aarti', 'time': '09:00 AM'},
        {'name': 'Sandhya Aarti', 'time': '07:00 PM'},
      ],
    },
    {
      'name': 'Somnath Jyotirlinga',
      'city': 'Prabhas Patan, Gujarat',
      'deity': 'Lord Shiva',
      'category': 'Lord Shiva',
      'icon': '🔱',
      'status': 'Triveni Sangam Darshan',
      'live': true,
      'viewers': '3,450',
      'timings': '06:00 AM - 09:30 PM',
      'description': 'The eternal shrine and first among the 12 holy Jyotirlingas, located on the Arabian Sea coast.',
      'aartis': [
        {'name': 'Pratah Aarti', 'time': '07:00 AM'},
        {'name': 'Madhyahna Aarti', 'time': '12:00 PM'},
        {'name': 'Sandhya Aarti', 'time': '07:00 PM'},
      ],
    },
    {
      'name': 'Banke Bihari Mandir',
      'city': 'Vrindavan, Uttar Pradesh',
      'deity': 'Radha Krishna',
      'category': 'Vishnu / Krishna',
      'icon': '🪈',
      'status': 'Darshan Open (Parda Darshan)',
      'live': false,
      'viewers': '1,920',
      'timings': '07:45 AM - 12:00 PM, 05:30 PM - 09:30 PM',
      'description': 'Iconic shrine established by Swami Haridas where Thakur Ji is adorned with charming eyes and joyful presence.',
      'aartis': [
        {'name': 'Shringar Aarti', 'time': '08:00 AM'},
        {'name': 'Rajbhog Aarti', 'time': '12:00 PM'},
        {'name': 'Shayan Aarti', 'time': '09:30 PM'},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchBackendTemples();
  }

  Future<void> _fetchBackendTemples() async {
    try {
      final backendTemples = await ApiService().getTemples();
      if (backendTemples.isNotEmpty && mounted) {
        setState(() {
          for (final bt in backendTemples) {
            final name = bt['name'] as String?;
            if (name != null && !_allTemples.any((t) => t['name'] == name)) {
              _allTemples.add(bt);
            }
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredTemples {
    return _allTemples.where((t) {
      final matchesCategory = _selectedCategory == 'All' || t['category'] == _selectedCategory;
      final query = _searchQuery.toLowerCase();
      final matchesSearch = query.isEmpty ||
          (t['name']?.toString() ?? '').toLowerCase().contains(query) ||
          (t['city']?.toString() ?? '').toLowerCase().contains(query) ||
          (t['deity']?.toString() ?? '').toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _openLiveDarshanModal(Map<String, dynamic> temple) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LiveDarshanSheet(
        temple: temple,
        onBookPuja: () {
          Navigator.pop(ctx);
          if (widget.onBookPuja != null) {
            widget.onBookPuja!(temple['name'] as String);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PujasScreen(initialMandirFilter: temple['name'] as String),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final temples = _filteredTemples;

    return Scaffold(
      backgroundColor: _warmCreamBg,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Custom App Bar
            _buildTopAppBar(),

            // 2. Scrollable Body
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Hero Banner & Search
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Devotional Hero Card
                          _buildHeroDarshanBanner(),

                          const SizedBox(height: 12),

                          // Search Bar
                          _buildSearchBar(),

                          const SizedBox(height: 12),

                          // Category Chips
                          _buildCategoryChips(),

                          const SizedBox(height: 12),

                          // Section Title
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sacred Mandirs (${temples.length})',
                                style: GoogleFonts.marcellus(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: _primaryMaroon,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFD32F2F),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Garbhagriha Live',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFD32F2F),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Temples List
                  if (temples.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🛕', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            Text(
                              'No Mandirs Found',
                              style: GoogleFonts.marcellus(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: _primaryMaroon,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Try searching for another deity, city, or reset filters.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF757575),
                              ),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryMaroon,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedCategory = 'All';
                                  _searchQuery = '';
                                  _searchController.clear();
                                });
                              },
                              child: Text(
                                'Show All Mandirs',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final temple = temples[index];
                            return _buildTempleCard(temple);
                          },
                          childCount: temples.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 1. Unified Mandirm Header (same header across entire app)
  Widget _buildTopAppBar() {
    return MandirmHeader(
      trailing: GestureDetector(
        onTap: _openMyOrders,
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
          child: const Center(
            child: Icon(
              Icons.shopping_cart_outlined,
              color: _primaryMaroon,
              size: 19,
            ),
          ),
        ),
      ),
    );
  }

  /// Devotional Hero Banner
  Widget _buildHeroDarshanBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF9ED), Color(0xFFFFF2D6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B1E1E).withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _accentYellow,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '🕉️ 100% VERIFIED GARBHAGRIHA',
                  style: GoogleFonts.poppins(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: _primaryMaroon,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              const Text('🪔', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                'Direct Aarti Feeds',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _primaryMaroon,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Sacred Mandirs & Live Darshan',
            style: GoogleFonts.marcellus(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: _primaryMaroon,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Experience morning & sandhya aartis live, offer bilva patra & flowers from home, and book official temple sevas.',
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              color: const Color(0xFF5A4A42),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Search Bar
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: GoogleFonts.poppins(fontSize: 13, color: _darkCharcoal),
        decoration: InputDecoration(
          hintText: 'Search by mandir, deity, or holy city...',
          hintStyle: GoogleFonts.poppins(fontSize: 12.5, color: const Color(0xFF9E9E9E)),
          prefixIcon: const Icon(Icons.search_rounded, color: _primaryMaroon, size: 22),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  /// Category Filter Chips
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        itemBuilder: (context, i) {
          final cat = _categories[i];
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? _primaryMaroon : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? _primaryMaroon : _cardBorder,
                    width: 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _primaryMaroon.withAlpha(40),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    cat,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? Colors.white : _darkCharcoal,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Temple Card
  Widget _buildTempleCard(Map<String, dynamic> temple) {
    final aartis = (temple['aartis'] as List<dynamic>? ?? []);
    final nextAarti = aartis.isNotEmpty ? aartis.first : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openLiveDarshanModal(temple),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Icon + Temple Name + Live Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B1E1E), Color(0xFF500609)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFF3E5D8), width: 1.2),
                      ),
                      child: Center(
                        child: Text(
                          temple['icon'] as String,
                          style: const TextStyle(fontSize: 25),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3E0),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFFFE0B2)),
                                ),
                                child: Text(
                                  temple['deity'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: _primaryMaroon,
                                  ),
                                ),
                              ),
                              if (temple['live'] == true)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEBEE),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFFFCDD2)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFFD32F2F),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'LIVE',
                                        style: GoogleFonts.poppins(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFFD32F2F),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            temple['name'] as String,
                            style: GoogleFonts.marcellus(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _darkCharcoal,
                            ),
                          ),
                          Text(
                            '📍 ${temple['city']}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF6E6E6E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  temple['description'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: const Color(0xFF555555),
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 10),

                // Next Aarti Pill
                if (nextAarti != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBF8F3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _cardBorder),
                    ),
                    child: Row(
                      children: [
                        const Text('🪔', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 6),
                        Text(
                          'Upcoming Aarti: ',
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6E6E6E),
                          ),
                        ),
                        Text(
                          '${nextAarti['name']} (${nextAarti['time']})',
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: _primaryMaroon,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFEFE6D8)),
                const SizedBox(height: 10),

                // Bottom Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Color(0xFF757575)),
                        const SizedBox(width: 4),
                        Text(
                          temple['timings'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: const Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Watch Live Darshan Button
                        OutlinedButton.icon(
                          onPressed: () => _openLiveDarshanModal(temple),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(88, 32),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            side: const BorderSide(color: _primaryMaroon, width: 1.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(
                            Icons.remove_red_eye_outlined,
                            size: 14,
                            color: _primaryMaroon,
                          ),
                          label: Text(
                            'Darshan',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _primaryMaroon,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Book Seva Button
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7A0C16), Color(0xFF9E1B26)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              if (widget.onBookPuja != null) {
                                widget.onBookPuja!(temple['name'] as String);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              minimumSize: const Size(88, 32),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Book Puja',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveDarshanSheet extends StatefulWidget {
  final Map<String, dynamic> temple;
  final VoidCallback onBookPuja;

  const _LiveDarshanSheet({
    required this.temple,
    required this.onBookPuja,
  });

  @override
  State<_LiveDarshanSheet> createState() => _LiveDarshanSheetState();
}

class _LiveDarshanSheetState extends State<_LiveDarshanSheet> {
  bool _diyaLighted = false;
  int _flowersOffered = 0;
  int _bellsRung = 0;

  static const Color _primaryMaroon = Color(0xFF7A0C16);
  static const Color _cardBorder = Color(0xFFEFE6D8);

  void _ringBell() {
    setState(() => _bellsRung++);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🔔 Temple bell rung at ${widget.temple['name']}! Har Har Mahadev!',
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF8B1E1E),
      ),
    );
  }

  void _offerFlowers() {
    setState(() => _flowersOffered++);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🌸 Bilva Patra & Fresh Flowers offered to ${widget.temple['deity']}!',
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.pink.shade700,
      ),
    );
  }

  void _toggleDiya() {
    setState(() => _diyaLighted = !_diyaLighted);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _diyaLighted
              ? '🪔 Sacred Aarti Diya lighted before ${widget.temple['deity']}!'
              : 'Aarti completed with devotion.',
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFFD64D18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aartis = (widget.temple['aartis'] as List<dynamic>? ?? []);

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFDF9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD7CCC8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.temple['name'] as String,
                        style: GoogleFonts.marcellus(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _primaryMaroon,
                        ),
                      ),
                      Text(
                        '📍 ${widget.temple['city']}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF6E6E6E),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF5A4A42)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: _cardBorder),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Live Stream Viewer Box
                  Container(
                    width: double.infinity,
                    height: 210,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E0802), Color(0xFF5A1408), Color(0xFF1A0401)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFDCB06), width: 1.8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B1E1E).withAlpha(50),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.temple['icon'] as String,
                              style: const TextStyle(fontSize: 54),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Garbhagriha Live Stream',
                              style: GoogleFonts.marcellus(
                                color: Colors.amber.shade200,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Direct Sanctum Sanctorum of ${widget.temple['deity']}',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),

                        // Live badge
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD32F2F),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.fiber_manual_record, color: Colors.white, size: 9),
                                const SizedBox(width: 4),
                                Text(
                                  'LIVE • ${widget.temple['viewers']} devotees watching',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // HD audio/video indicator
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.volume_up, color: Colors.white, size: 13),
                                const SizedBox(width: 4),
                                Text(
                                  'Aarti Audio ON',
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Interactive Devotional Ritual Actions
                  Text(
                    'Sacred Devotional Actions',
                    style: GoogleFonts.marcellus(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _primaryMaroon,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionItem(
                        icon: '🔔',
                        label: 'Ring Bell',
                        count: _bellsRung,
                        onTap: _ringBell,
                      ),
                      _buildActionItem(
                        icon: '🌸',
                        label: 'Offer Flowers',
                        count: _flowersOffered,
                        onTap: _offerFlowers,
                      ),
                      _buildActionItem(
                        icon: '🪔',
                        label: _diyaLighted ? 'Diya Lit' : 'Light Diya',
                        isActive: _diyaLighted,
                        onTap: _toggleDiya,
                      ),
                      _buildActionItem(
                        icon: '🥥',
                        label: 'Offer Shriphal',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '🥥 Shriphal (Coconut) offered for health & prosperity!',
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                              backgroundColor: const Color(0xFFD64D18),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Daily Aarti Timetable
                  Text(
                    'Daily Aarti & Darshan Schedule',
                    style: GoogleFonts.marcellus(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _primaryMaroon,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBF8F3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _cardBorder),
                    ),
                    child: Column(
                      children: aartis.map((a) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Text('🕉️', style: TextStyle(fontSize: 12)),
                                  const SizedBox(width: 8),
                                  Text(
                                    a['name'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1E1E1E),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                a['time'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _primaryMaroon,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Temple History
                  Text(
                    'Spiritual Significance',
                    style: GoogleFonts.marcellus(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _primaryMaroon,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.temple['description'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF555555),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Book Seva Button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7A0C16), Color(0xFF9E1B26)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryMaroon.withAlpha(50),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: widget.onBookPuja,
                      child: Text(
                        'Book Puja / Seva at ${widget.temple['name']}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required String icon,
    required String label,
    required VoidCallback onTap,
    int? count,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFFDCB06) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? const Color(0xFFFFB300) : _cardBorder,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E1E1E),
            ),
          ),
          if (count != null && count > 0)
            Text(
              '($count)',
              style: GoogleFonts.poppins(
                fontSize: 9.5,
                color: _primaryMaroon,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}
