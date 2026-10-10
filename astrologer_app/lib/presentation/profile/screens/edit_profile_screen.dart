import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/models/astrologer_profile.dart';
import '../../../services/api/api_service.dart';
import '../../../services/auth/auth_service.dart';
import '../../common/widgets/app_image.dart';
import '../../common/widgets/mandirm_header.dart';

class EditAstrologerProfileScreen extends StatefulWidget {
  final AstrologerProfile profile;

  const EditAstrologerProfileScreen({
    super.key,
    required this.profile,
  });

  @override
  State<EditAstrologerProfileScreen> createState() => _EditAstrologerProfileScreenState();
}

class _EditAstrologerProfileScreenState extends State<EditAstrologerProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _expController;
  late TextEditingController _workingHoursController;
  late TextEditingController _bioController;

  late double _videoRate;
  late double _voiceRate;
  late double _chatRate;

  late List<String> _selectedSpecialities;
  late List<String> _selectedLanguages;
  bool _isSaving = false;

  final List<String> _allSpecialities = [
    'Vedic Astrology',
    'Kundli Matching',
    'Vastu Shastra',
    'Prashna Kundli',
    'Numerology',
    'Palmistry',
    'Gemology',
    'Lal Kitab',
    'Tarot Guidance',
    'Mahadasha Remedy',
    'Muhurat Jyotish',
  ];

  final List<String> _allLanguages = [
    'Hindi',
    'English',
    'Sanskrit',
    'Gujarati',
    'Marathi',
    'Bengali',
    'Tamil',
    'Telugu',
    'Punjabi',
    'Kannada',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nameController = TextEditingController(text: p.name);
    _titleController = TextEditingController(
      text: p.title ?? 'Senior Vedic Astrologer & Kundli Expert',
    );
    _expController = TextEditingController(text: p.experienceYears.toString());
    _workingHoursController = TextEditingController(
      text: p.workingHours ?? '08:00 AM - 10:00 PM',
    );
    _bioController = TextEditingController(
      text: p.bio ??
          'Guided by centuries-old Vedic traditions, offering astrological clarity, horoscope charts, and sacred Sanatan remedies for career, relationships, and spiritual wellness.',
    );

    _videoRate = p.perMinuteVideoRate;
    _voiceRate = p.perMinuteCallRate;
    _chatRate = p.perMinuteChatRate;

    // Parse existing specialities & languages
    _selectedSpecialities = (p.specialities ?? 'Vedic Astrology, Kundli Matching')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    _selectedLanguages = (p.languages ?? 'Hindi, English, Sanskrit')
        .split(',')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _expController.dispose();
    _workingHoursController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final expYears = int.tryParse(_expController.text.trim()) ?? widget.profile.experienceYears;
    final specialitiesStr = _selectedSpecialities.join(', ');
    final languagesStr = _selectedLanguages.join(', ');

    final payload = {
      'name': _nameController.text.trim(),
      'title': _titleController.text.trim(),
      'experience_years': expYears,
      'working_hours': _workingHoursController.text.trim(),
      'bio': _bioController.text.trim(),
      'specialities': specialitiesStr,
      'languages': languagesStr,
      'per_minute_video_rate': _videoRate,
      'per_minute_call_rate': _voiceRate,
      'per_minute_chat_rate': _chatRate,
    };

    final astroId = widget.profile.id;

    // 1. Dispatch update to Backend & Supabase
    await ApiService().updateAstrologerProfile(astroId, payload);

    // 2. Create updated in-memory profile model
    final updated = widget.profile.copyWith(
      name: _nameController.text.trim(),
      title: _titleController.text.trim(),
      experienceYears: expYears,
      workingHours: _workingHoursController.text.trim(),
      bio: _bioController.text.trim(),
      specialities: specialitiesStr,
      languages: languagesStr,
      perMinuteVideoRate: _videoRate,
      perMinuteCallRate: _voiceRate,
      perMinuteChatRate: _chatRate,
    );

    // 3. Persist into local session
    await AuthService().updateLocalProfile(updated);

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Acharya profile updated successfully on Mandirm network!',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        backgroundColor: AppColors.statusOnline,
        duration: const Duration(seconds: 3),
      ),
    );

    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // Unified Header
          const MandirmHeader(),

          // Title Bar with Back Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.headerBg,
              border: Border(bottom: BorderSide(color: AppColors.lightBorder, width: 1)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  color: AppColors.primaryMaroon,
                  tooltip: 'Back',
                ),
                const SizedBox(width: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Acharya Profile',
                      style: GoogleFonts.cinzel(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Update your Vedic credentials, Dakshina rates & bio',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Scrollable Form
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Avatar Section
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.marigoldGold, width: 2.5),
                            boxShadow: const [
                              BoxShadow(color: Color(0x14000000), blurRadius: 10, offset: Offset(0, 4)),
                            ],
                          ),
                          child: ClipOval(
                            child: AppImage.network(
                              AppConstants.cdnUrl(AppConstants.astroRajeshAsset),
                              fallbackAsset: AppConstants.logoAsset,
                              width: 88,
                              height: 88,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryMaroon,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Basic Information Card
                  _buildSectionCard(
                    title: 'Basic Credentials',
                    icon: Icons.person_outline_rounded,
                    children: [
                      _buildTextField(
                        controller: _nameController,
                        label: 'Acharya Full Name',
                        hint: 'e.g. Acharya Ramanuj Shastri',
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _titleController,
                        label: 'Professional Vedic Title',
                        hint: 'e.g. Senior Vedic Astrologer & Kundli Expert',
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your title' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _expController,
                              label: 'Experience (Years)',
                              hint: '15',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: _workingHoursController,
                              label: 'Duty Working Hours',
                              hint: '08:00 AM - 10:00 PM',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Consultation Rates Card
                  _buildSectionCard(
                    title: 'Dakshina Per-Minute Rates (₹)',
                    icon: Icons.currency_rupee_rounded,
                    children: [
                      _buildRateSlider(
                        label: 'Video Consultation',
                        value: _videoRate,
                        icon: Icons.videocam,
                        color: AppColors.primaryMaroon,
                        onChanged: (v) => setState(() => _videoRate = v),
                      ),
                      const SizedBox(height: 10),
                      _buildRateSlider(
                        label: 'Voice Call Consultation',
                        value: _voiceRate,
                        icon: Icons.phone_in_talk,
                        color: AppColors.deepAmber,
                        onChanged: (v) => setState(() => _voiceRate = v),
                      ),
                      const SizedBox(height: 10),
                      _buildRateSlider(
                        label: 'Live Vedic Chat',
                        value: _chatRate,
                        icon: Icons.chat_bubble_outline_rounded,
                        color: AppColors.statusOnline,
                        onChanged: (v) => setState(() => _chatRate = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Specializations Card
                  _buildSectionCard(
                    title: 'Vedic Specializations',
                    icon: Icons.auto_awesome,
                    children: [
                      Text(
                        'Select the astrology disciplines you specialize in for devotees:',
                        style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _allSpecialities.map((spec) {
                          final isSelected = _selectedSpecialities.contains(spec);
                          return FilterChip(
                            label: Text(spec),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedSpecialities.add(spec);
                                } else {
                                  _selectedSpecialities.remove(spec);
                                }
                              });
                            },
                            selectedColor: AppColors.primaryMaroon,
                            checkmarkColor: Colors.white,
                            labelStyle: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? AppColors.primaryMaroon : AppColors.lightBorder,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Languages Spoken Card
                  _buildSectionCard(
                    title: 'Languages Spoken',
                    icon: Icons.translate_rounded,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _allLanguages.map((lang) {
                          final isSelected = _selectedLanguages.contains(lang);
                          return FilterChip(
                            label: Text(lang),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedLanguages.add(lang);
                                } else {
                                  _selectedLanguages.remove(lang);
                                }
                              });
                            },
                            selectedColor: AppColors.deepAmber,
                            checkmarkColor: Colors.white,
                            labelStyle: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? AppColors.deepAmber : AppColors.lightBorder,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Sacred Bio & Ashram / Tradition
                  _buildSectionCard(
                    title: 'Sacred Bio & Guru Parampara',
                    icon: Icons.menu_book_rounded,
                    children: [
                      TextFormField(
                        controller: _bioController,
                        maxLines: 4,
                        style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Share your astrological lineage, education, and philosophical approach...',
                          hintStyle: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
                          filled: true,
                          fillColor: AppColors.backgroundLight,
                          contentPadding: const EdgeInsets.all(12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.lightBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.lightBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primaryMaroon, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryMaroon,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Save Profile Changes',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.lightBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryMaroon, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.cinzel(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(fontSize: 12, color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.backgroundLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.lightBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.lightBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primaryMaroon, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRateSlider({
    required String label,
    required double value,
    required IconData icon,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warmCream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.4)),
                ),
                child: Text(
                  '₹${value.toStringAsFixed(0)} / min',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              thumbColor: color,
              inactiveTrackColor: color.withOpacity(0.2),
              trackHeight: 3,
            ),
            child: Slider(
              value: value,
              min: 10,
              max: 150,
              divisions: 28,
              onChanged: (v) => onChanged((v / 5).round() * 5.0),
            ),
          ),
        ],
      ),
    );
  }
}
