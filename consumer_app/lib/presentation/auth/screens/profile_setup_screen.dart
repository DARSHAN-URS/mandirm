import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/models/user_profile.dart';
import '../../../services/supabase_service.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();

  String? _selectedGotra;
  String? _selectedRashi;
  DateTime? _selectedBirthDate;

  static const Color _primaryMaroon = Color(0xFF7A0C16);
  static const Color _darkCharcoal = Color(0xFF1E1E1E);
  static const Color _cardBorder = Color(0xFFEFE6D8);
  static const Color _warmCreamBg = Color(0xFFFBF8F3);
  static const Color _accentYellow = Color(0xFFFDCB06);

  final List<String> _gotras = [
    'Kashyap',
    'Bharadwaja',
    'Vashishta',
    'Vishwamitra',
    'Gautama',
    'Jamadagni',
    'Atri',
    'Agastya',
    'Sandilya',
    'Angirasa',
    'Parashara',
    'Not Known / Shiva Gotra',
  ];

  final List<String> _rashis = [
    'Mesh (Aries) ♈',
    'Vrishabha (Taurus) ♉',
    'Mithuna (Gemini) ♊',
    'Karka (Cancer) ♋',
    'Simha (Leo) ♌',
    'Kanya (Virgo) ♍',
    'Tula (Libra) ♎',
    'Vrishchika (Scorpio) ♏',
    'Dhanu (Sagittarius) ♐',
    'Makara (Capricorn) ♑',
    'Kumbha (Aquarius) ♒',
    'Meena (Pisces) ♓',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995, 1, 1),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.saffronPrimary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimaryLight,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedBirthDate = picked);
    }
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final user = SupabaseService().currentUser;
      final userId = user?.id ?? 'user_${DateTime.now().millisecondsSinceEpoch}';

      final profile = UserProfile(
        id: userId,
        fullName: _nameController.text.trim(),
        phoneNumber: user?.phone,
        email: user?.email,
        gotra: _selectedGotra ?? 'Kashyap',
        rashi: _selectedRashi,
        birthDate: _selectedBirthDate,
        birthPlace: _cityController.text.trim(),
        createdAt: DateTime.now(),
      );

      context.read<AuthBloc>().add(SaveProfileEvent(profile));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/home');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.sacredCrimson,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: _warmCreamBg,
          body: SafeArea(
            child: Column(
              children: [
                // Top Custom App Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: _warmCreamBg,
                  child: Row(
                    children: [
                      // Back if can pop
                      if (Navigator.canPop(context))
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: _primaryMaroon,
                              size: 22,
                            ),
                          ),
                        ),

                      // Central Branding
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(shape: BoxShape.circle),
                              child: Image.asset(
                                AppConstants.logoAsset,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.local_fire_department_rounded,
                                  color: Color(0xFFD32F2F),
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Mandirm',
                                  style: GoogleFonts.marcellus(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: _primaryMaroon,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  '— Sacred Devotee Setup —',
                                  style: GoogleFonts.poppins(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w500,
                                    color: _primaryMaroon,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      if (Navigator.canPop(context))
                        const SizedBox(width: 34),
                    ],
                  ),
                ),
                const Divider(height: 1, color: _cardBorder),

                // Form Body
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Devotional Glow Header
                          Center(
                            child: Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFF9ED), Color(0xFFFFF3DB)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(color: _accentYellow, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: _primaryMaroon.withAlpha(20),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text('🕉️', style: TextStyle(fontSize: 32)),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          Center(
                            child: Text(
                              'Devotee Sankalp Profile',
                              style: GoogleFonts.marcellus(
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                                color: _primaryMaroon,
                              ),
                            ),
                          ),

                          const SizedBox(height: 4),

                          Center(
                            child: Text(
                              'These sacred details are chanted during your puja sankalp and personalized horoscope readings.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF6E6E6E),
                                height: 1.4,
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Full Name
                          _buildFieldLabel('Full Name (as per Puja Sankalp) *'),
                          const SizedBox(height: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _cardBorder),
                            ),
                            child: TextFormField(
                              controller: _nameController,
                              style: GoogleFonts.poppins(fontSize: 13, color: _darkCharcoal),
                              decoration: const InputDecoration(
                                hintText: 'e.g. Rajesh Sharma',
                                prefixIcon: Icon(Icons.person_outline_rounded,
                                    color: _primaryMaroon),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Please provide your full name';
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Gotra
                          _buildFieldLabel('Gotra (Ancestral Lineage)'),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _cardBorder),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedGotra,
                                hint: Text('Select your Gotra',
                                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.account_tree_outlined,
                                      color: _primaryMaroon),
                                  border: InputBorder.none,
                                ),
                                items: _gotras.map((gotra) {
                                  return DropdownMenuItem(
                                    value: gotra,
                                    child: Text(gotra,
                                        style: GoogleFonts.poppins(fontSize: 13, color: _darkCharcoal)),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _selectedGotra = val),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Rashi
                          _buildFieldLabel('Rashi (Moon Sign for Astrology)'),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _cardBorder),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedRashi,
                                hint: Text('Select your Rashi',
                                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.auto_awesome_outlined,
                                      color: _primaryMaroon),
                                  border: InputBorder.none,
                                ),
                                items: _rashis.map((rashi) {
                                  return DropdownMenuItem(
                                    value: rashi,
                                    child: Text(rashi,
                                        style: GoogleFonts.poppins(fontSize: 13, color: _darkCharcoal)),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _selectedRashi = val),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Date of Birth
                          _buildFieldLabel('Date of Birth'),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: _pickBirthDate,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _cardBorder),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.cake_outlined, color: _primaryMaroon, size: 22),
                                  const SizedBox(width: 12),
                                  Text(
                                    _selectedBirthDate != null
                                        ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                                        : 'Select Date of Birth',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: _selectedBirthDate != null
                                          ? _darkCharcoal
                                          : Colors.grey,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.calendar_today_rounded,
                                      size: 18, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // City
                          _buildFieldLabel('Current City / Place of Residence'),
                          const SizedBox(height: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _cardBorder),
                            ),
                            child: TextFormField(
                              controller: _cityController,
                              style: GoogleFonts.poppins(fontSize: 13, color: _darkCharcoal),
                              decoration: const InputDecoration(
                                hintText: 'e.g. Varanasi, Uttar Pradesh',
                                prefixIcon: Icon(Icons.location_on_outlined,
                                    color: _primaryMaroon),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Complete Profile Button
                          Container(
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
                              onPressed: isLoading ? null : _onSave,
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Save & Enter Mandirm',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Trust Security Note
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lock_outline_rounded,
                                  size: 13, color: Color(0xFF757575)),
                              const SizedBox(width: 4),
                              Text(
                                '100% Confidential & Secure Sankalp Data',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  color: const Color(0xFF757575),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
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

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _darkCharcoal,
      ),
    );
  }
}
