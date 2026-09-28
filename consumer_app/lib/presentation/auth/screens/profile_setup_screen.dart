import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
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
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              'Sacred Profile Setup',
              style: GoogleFonts.cinzel(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Spiritual Header
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warmCream,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.marigoldGold.withAlpha(80),
                          width: 2,
                        ),
                      ),
                      child: const Text('🕉️', style: TextStyle(fontSize: 32)),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Center(
                    child: Text(
                      'Sankalp & Devotee Details',
                      style: GoogleFonts.cinzel(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Center(
                    child: Text(
                      'These sacred details are used when performing Puja Sankalp and personalized Astrology consultations.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Full Name
                  Text(
                    'Full Name (as per Puja Sankalp) *',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Rajesh Sharma',
                      prefixIcon: Icon(Icons.person_outline,
                          color: AppColors.saffronPrimary),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please provide your full name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  // Gotra
                  Text(
                    'Gotra (Ancestral Lineage)',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedGotra,
                    hint: const Text('Select your Gotra'),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.account_tree_outlined,
                          color: AppColors.saffronPrimary),
                    ),
                    items: _gotras.map((gotra) {
                      return DropdownMenuItem(
                        value: gotra,
                        child: Text(gotra, style: GoogleFonts.poppins(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedGotra = val),
                  ),

                  const SizedBox(height: 18),

                  // Rashi (Zodiac)
                  Text(
                    'Rashi (Moon Sign for Astrology)',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedRashi,
                    hint: const Text('Select your Rashi'),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.auto_awesome_outlined,
                          color: AppColors.saffronPrimary),
                    ),
                    items: _rashis.map((rashi) {
                      return DropdownMenuItem(
                        value: rashi,
                        child: Text(rashi, style: GoogleFonts.poppins(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedRashi = val),
                  ),

                  const SizedBox(height: 18),

                  // Date of Birth
                  Text(
                    'Date of Birth',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: _pickBirthDate,
                    borderRadius: BorderRadius.circular(14),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.cake_outlined,
                            color: AppColors.saffronPrimary),
                        suffixIcon: Icon(Icons.calendar_today_rounded, size: 20),
                      ),
                      child: Text(
                        _selectedBirthDate != null
                            ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                            : 'Select Date of Birth',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: _selectedBirthDate != null
                              ? AppColors.textPrimaryLight
                              : AppColors.textMutedLight,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // City
                  Text(
                    'Current City / Place of Residence',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Varanasi, Uttar Pradesh',
                      prefixIcon: Icon(Icons.location_on_outlined,
                          color: AppColors.saffronPrimary),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Complete Profile Button
                  ElevatedButton(
                    onPressed: isLoading ? null : _onSave,
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Save & Enter Mandiram',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
