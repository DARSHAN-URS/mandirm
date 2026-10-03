import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/models/user_profile.dart';
import '../../../services/devotee_data_service.dart';
import '../../../services/supabase_service.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../bookings/screens/bookings_screen.dart';
import '../../consultations/screens/consultations_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../shop/screens/prasad_orders_screen.dart';
import '../../common/widgets/mandirm_header.dart';
import '../../../core/l10n/locale_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _devoteeName = '';
  String? _avatarUrl;
  String _gotra = 'Kashyap';
  String _rashi = 'Mesh (Aries)';
  bool _aartiSoundEnabled = true;
  bool _dailyDarshanAlerts = true;

  static const Color _primaryMaroon = Color(0xFF7A0C16);
  static const Color _darkCharcoal = Color(0xFF1E1E1E);
  static const Color _cardBorder = Color(0xFFEFE6D8);
  static const Color _accentYellow = Color(0xFFFDCB06);

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final user = SupabaseService().currentUser;
    if (user != null) {
      final googleAvatar = user.userMetadata?['avatar_url']?.toString() ??
          user.userMetadata?['picture']?.toString();
      final googleName = user.userMetadata?['full_name']?.toString() ??
          user.userMetadata?['name']?.toString();

      setState(() {
        _devoteeName = googleName ?? user.userMetadata?['full_name'] ?? 'Devotee';
        _avatarUrl = googleAvatar;
      });

      try {
        final profile = await SupabaseService().fetchUserProfile(user.id);
        if (profile != null && mounted) {
          setState(() {
            if (profile.fullName != null && profile.fullName!.isNotEmpty) {
              _devoteeName = profile.fullName!;
            }
            if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
              _avatarUrl = profile.avatarUrl;
            }
            if (profile.gotra != null && profile.gotra!.isNotEmpty) {
              _gotra = profile.gotra!;
            }
            if (profile.rashi != null && profile.rashi!.isNotEmpty) {
              _rashi = profile.rashi!;
            }
          });
        }
      } catch (_) {}
    }
  }

  void _editDevoteeProfile() {
    final isHi = LocaleService().isHindi;
    final nameCtrl = TextEditingController(text: _devoteeName);
    final gotraCtrl = TextEditingController(text: _gotra);
    final rashiCtrl = TextEditingController(text: _rashi);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isHi ? 'भक्त प्रोफ़ाइल संपादित करें' : 'Edit Devotee Profile',
          style: GoogleFonts.marcellus(
            fontWeight: FontWeight.w700,
            color: _primaryMaroon,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: isHi ? 'पूरा नाम' : 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline, color: _primaryMaroon),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: gotraCtrl,
                decoration: InputDecoration(
                  labelText: isHi ? 'वैदिक गोत्र' : 'Vedic Gotra',
                  prefixIcon: const Icon(Icons.family_restroom_rounded, color: _primaryMaroon),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: rashiCtrl,
                decoration: InputDecoration(
                  labelText: isHi ? 'राशि' : 'Zodiac / Rashi',
                  prefixIcon: const Icon(Icons.stars_rounded, color: _primaryMaroon),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isHi ? 'रद्द करें' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryMaroon,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final newName = nameCtrl.text.trim().isEmpty ? 'Devotee' : nameCtrl.text.trim();
              final newGotra = gotraCtrl.text.trim().isEmpty ? 'Kashyap' : gotraCtrl.text.trim();
              final newRashi = rashiCtrl.text.trim().isEmpty ? 'Mesh (Aries)' : rashiCtrl.text.trim();

              setState(() {
                _devoteeName = newName;
                _gotra = newGotra;
                _rashi = newRashi;
              });

              final user = SupabaseService().currentUser;
              if (user != null) {
                SupabaseService().saveUserProfile(UserProfile(
                  id: user.id,
                  fullName: newName,
                  gotra: newGotra,
                  rashi: newRashi,
                  avatarUrl: _avatarUrl,
                  email: user.email,
                  phoneNumber: user.phone,
                )).catchError((_) => UserProfile(id: user.id));
              }

              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isHi ? 'प्रोफ़ाइल सफलतापूर्वक अपडेट की गई!' : 'Devotee profile updated successfully!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(isHi ? 'विवरण सहेजें' : 'Save Details'),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut() {
    final isHi = LocaleService().isHindi;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isHi ? '${AppConstants.appName} से लॉग आउट करें?' : 'Sign Out from ${AppConstants.appName}?',
          style: GoogleFonts.marcellus(
            fontWeight: FontWeight.w700,
            color: _primaryMaroon,
          ),
        ),
        content: Text(
          isHi
              ? 'अपनी पूजा, बुकिंग और पवित्र आदेशों तक पहुंचने के लिए आपको पुनः लॉगिन करना होगा।'
              : 'You will need to sign in again to access your live pujas, bookings and sacred orders.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isHi ? 'लॉग इन रहें' : 'Stay Signed In'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryMaroon,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              context.read<AuthBloc>().add(const SignOutEvent());
              context.go('/login');
            },
            child: Text(isHi ? 'लॉग आउट' : 'Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseService().currentUser;
    final data = DevoteeDataService();
    final isHi = LocaleService().isHindi;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F3),
      body: Column(
        children: [
          MandirmHeader(
            trailing: IconButton(
              icon: const Icon(Icons.edit_outlined, color: _primaryMaroon, size: 21),
              tooltip: isHi ? 'प्रोफ़ाइल संपादित करें' : 'Edit Profile',
              onPressed: _editDevoteeProfile,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Devotee Profile Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withAlpha(10),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF8B2B2B),
                          border: Border.all(color: _accentYellow, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(20),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                              ? Image.network(
                                  _avatarUrl!,
                                  width: 84,
                                  height: 84,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(
                                      Icons.person,
                                      color: Color(0xFFFFE0B2),
                                      size: 48,
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.person,
                                    color: Color(0xFFFFE0B2),
                                    size: 48,
                                  ),
                                ),
                        ),
                      ),
                      InkWell(
                        onTap: _editDevoteeProfile,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: _primaryMaroon,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _devoteeName,
                    style: GoogleFonts.marcellus(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _darkCharcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (user?.email != null)
                    Text(user!.email!, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
                  if (user?.phone != null)
                    Text(user!.phone!, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 14),

                  // Gotra & Rashi Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9ED),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFFE0B2)),
                        ),
                        child: Row(
                          children: [
                            const Text('🕉️', style: TextStyle(fontSize: 11)),
                            const SizedBox(width: 4),
                            Text(
                              isHi ? 'गोत्र: $_gotra' : 'Gotra: $_gotra',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF7A4A00),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFFCC80)),
                        ),
                        child: Row(
                          children: [
                            const Text('⭐', style: TextStyle(fontSize: 11)),
                            const SizedBox(width: 4),
                            Text(
                              isHi ? 'राशि: $_rashi' : 'Rashi: $_rashi',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFC65100),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Devotional Activity Quick Stats (Pujas, Astro, Orders)
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const BookingsScreen())),
                    child: _buildStatCard(
                      isHi ? 'पूजा' : 'Pujas',
                      '${data.bookings.length}',
                      isHi ? 'बुक की गई' : 'Booked',
                      Icons.spa_outlined,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ConsultationsScreen())),
                    child: _buildStatCard(
                      isHi ? 'ज्योतिष' : 'Astro',
                      '${data.consultations.length}',
                      isHi ? 'परामर्श' : 'Sessions',
                      Icons.brightness_7_outlined,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const PrasadOrdersScreen())),
                    child: _buildStatCard(
                      isHi ? 'ऑर्डर' : 'Orders',
                      '${data.prasadOrders.length}',
                      isHi ? 'पवित्र' : 'Sacred',
                      Icons.shopping_bag_outlined,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Navigation Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _cardBorder),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.spa_rounded, color: _primaryMaroon),
                    title: Text(
                      isHi ? 'मेरी पूजा बुकिंग' : 'My Puja Bookings',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13.5),
                    ),
                    subtitle: Text(
                      isHi ? 'सक्रिय संकल्प, प्रमाण पत्र एवं रिकॉर्डिंग' : 'Active sankalps, certificates & recordings',
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const BookingsScreen())),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.brightness_7_rounded, color: _primaryMaroon),
                    title: Text(
                      isHi ? 'ज्योतिष परामर्श' : 'Astrology Consultations',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13.5),
                    ),
                    subtitle: Text(
                      isHi ? 'पिछले सत्र, उपाय एवं कॉल रिकॉर्डिंग' : 'Past sessions, remedies & call recordings',
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ConsultationsScreen())),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.local_shipping_outlined, color: _primaryMaroon),
                    title: Text(
                      isHi ? 'मेरे पवित्र ऑर्डर एवं चढ़ावा' : 'My Sacred Orders & Chadava',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13.5),
                    ),
                    subtitle: Text(
                      isHi ? 'प्रसाद डिलीवरी और वीडियो क्लिप ट्रैक करें' : 'Track BlueDart courier delivery & clips',
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const PrasadOrdersScreen())),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.notifications_none_rounded, color: _primaryMaroon),
                    title: Text(
                      isHi ? 'दिव्य सूचनाएं' : 'Divine Notifications',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13.5),
                    ),
                    subtitle: Text(
                      isHi ? 'आरती अलर्ट, ऑर्डर स्थिति और लाइव दर्शन' : 'Aarti alerts, order status & live streams',
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.edit_outlined, color: _primaryMaroon),
                    title: Text(
                      isHi ? 'भक्त विवरण बदलें' : 'Edit Devotee Details',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13.5),
                    ),
                    subtitle: Text(
                      isHi ? 'नाम, गोत्र और पारिवारिक संकल्प नाम बदलें' : 'Change name, gotra and family sankalp names',
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: _editDevoteeProfile,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Preferences Section
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _cardBorder),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      isHi ? 'आरती घंटी व शंख ध्वनि' : 'Aarti Bell & Shankh Sound',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    subtitle: Text(
                      isHi ? 'लाइव दर्शन के दौरान मधुर ध्वनियां' : 'Devotional chimes during live darshan',
                      style: const TextStyle(fontSize: 11),
                    ),
                    secondary: const Icon(Icons.notifications_active_outlined, color: _primaryMaroon),
                    value: _aartiSoundEnabled,
                    activeThumbColor: _primaryMaroon,
                    onChanged: (val) => setState(() => _aartiSoundEnabled = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(
                      isHi ? 'दैनिक प्रातः दर्शन अलर्ट' : 'Daily Morning Darshan Alert',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    subtitle: Text(
                      isHi ? 'सुबह 6:00 बजे लाइव दर्शन शुरू होने पर सूचना पाएं' : 'Get notified when live darshan starts at 06:00 AM',
                      style: const TextStyle(fontSize: 11),
                    ),
                    secondary: const Icon(Icons.alarm_on_outlined, color: _primaryMaroon),
                    value: _dailyDarshanAlerts,
                    activeThumbColor: _primaryMaroon,
                    onChanged: (val) => setState(() => _dailyDarshanAlerts = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryMaroon,
                  side: const BorderSide(color: _primaryMaroon, width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: Text(
                  isHi ? '${AppConstants.appName} से लॉग आउट करें' : 'Sign Out from ${AppConstants.appName}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13.5),
                ),
                onPressed: _confirmSignOut,
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

  Widget _buildStatCard(String title, String count, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withAlpha(8),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: _primaryMaroon, size: 22),
          const SizedBox(height: 6),
          Text(
            count,
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: _darkCharcoal),
          ),
          Text(
            '$title $label',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
