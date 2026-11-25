import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/l10n/locale_service.dart';
import '../../../services/devotee_data_service.dart';
import '../../../services/supabase_service.dart';

/// Modal bottom sheet to ask devotee birth details once for Astrologer consultations
class DevoteeBirthDetailsSheet extends StatefulWidget {
  final Map<String, dynamic> astrologer;
  final Function(Map<String, dynamic> details) onSubmitted;

  const DevoteeBirthDetailsSheet({
    super.key,
    required this.astrologer,
    required this.onSubmitted,
  });

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required Map<String, dynamic> astrologer,
    bool forceShow = false,
  }) async {
    // Check if already saved once
    final existing = await DevoteeDataService().loadBirthDetails();
    if (!forceShow &&
        existing != null &&
        (existing['name']?.toString().trim().isNotEmpty ?? false)) {
      return existing;
    }

    if (!context.mounted) return null;

    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DevoteeBirthDetailsSheet(
        astrologer: astrologer,
        onSubmitted: (details) {
          Navigator.pop(ctx, details);
        },
      ),
    );
  }

  @override
  State<DevoteeBirthDetailsSheet> createState() =>
      _DevoteeBirthDetailsSheetState();
}

class _DevoteeBirthDetailsSheetState extends State<DevoteeBirthDetailsSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _pobController;

  String _gender = 'Male';
  DateTime _dob = DateTime.now().subtract(const Duration(days: 365 * 26));
  TimeOfDay _tob = const TimeOfDay(hour: 10, minute: 30);
  bool _unknownTime = false;
  String _concern = 'Career';

  final List<Map<String, String>> _concerns = [
    {'key': 'Career', 'en': 'Career & Job', 'hi': 'करियर व नौकरी'},
    {'key': 'Marriage', 'en': 'Marriage & Love', 'hi': 'विवाह व प्रेम'},
    {'key': 'Business', 'en': 'Business & Wealth', 'hi': 'व्यापार व धन'},
    {'key': 'Kundli', 'en': 'Kundli Dosha', 'hi': 'कुंडली व ग्रह दोष'},
    {'key': 'Health', 'en': 'Health & Peace', 'hi': 'स्वास्थ्य व शांति'},
    {'key': 'Spiritual', 'en': 'Spiritual Sadhana', 'hi': 'आध्यात्मिक साधना'},
  ];

  @override
  void initState() {
    super.initState();
    final user = SupabaseService().currentUser;
    final userMetadata = user?.userMetadata;
    final initialName = (userMetadata?['full_name'] ??
            userMetadata?['name'] ??
            user?.email?.split('@').first ??
            '')
        .toString();

    _nameController = TextEditingController(text: initialName);
    _pobController = TextEditingController(text: 'Varanasi, Uttar Pradesh');

    final existing = DevoteeDataService().birthDetails;
    if (existing != null) {
      if ((existing['name'] ?? '').isNotEmpty) {
        _nameController.text = existing['name'];
      }
      if ((existing['pob'] ?? '').isNotEmpty) {
        _pobController.text = existing['pob'];
      }
      if (existing['gender'] != null) _gender = existing['gender'];
      if (existing['concern'] != null) _concern = existing['concern'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob,
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B1E1E),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2D1810),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dob = picked);
    }
  }

  Future<void> _selectTime() async {
    if (_unknownTime) return;
    final picked = await showTimePicker(
      context: context,
      initialTime: _tob,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B1E1E),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2D1810),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _tob = picked);
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final details = {
      'name': _nameController.text.trim(),
      'gender': _gender,
      'dob': '${_dob.year}-${_dob.month.toString().padLeft(2, '0')}-${_dob.day.toString().padLeft(2, '0')}',
      'dobFormatted': _formatDate(_dob),
      'tob': _unknownTime ? 'Approximate / Unknown' : _tob.format(context),
      'unknownTime': _unknownTime,
      'pob': _pobController.text.trim(),
      'concern': _concern,
      'savedAt': DateTime.now().toIso8601String(),
    };

    DevoteeDataService().saveBirthDetails(details);
    widget.onSubmitted(details);
  }

  @override
  Widget build(BuildContext context) {
    final isHi = LocaleService().isHindi;
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + keyboardPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Header Banner
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B1E1E), Color(0xFFD97706)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text('🕉️', style: TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHi
                              ? 'भक्त जन्म विवरण (कुंडली परामर्श)'
                              : 'Devotee Birth Details (Kundli Chat)',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D1810),
                          ),
                        ),
                        Text(
                          isHi
                              ? 'सटीक गणना हेतु एक बार भरें • स्थायी रूप से सुरक्षित'
                              : 'Ask once • Securely saved for all future chats',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF8B1E1E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Divider(color: Color(0xFFF0E5D8)),
              const SizedBox(height: 10),

              // 1. Full Name
              Text(
                isHi ? 'भक्त का पूरा नाम *' : 'Full Name *',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A3427),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: isHi ? 'उदा. राहुल शर्मा' : 'e.g. Rahul Sharma',
                  prefixIcon: const Icon(Icons.person_outline,
                      color: Color(0xFF8B1E1E), size: 20),
                  filled: true,
                  fillColor: const Color(0xFFFBF8F2),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5D5C5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5D5C5)),
                  ),
                ),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? (isHi ? 'कृपया नाम दर्ज करें' : 'Please enter name')
                    : null,
              ),
              const SizedBox(height: 14),

              // 2. Gender Selector
              Text(
                isHi ? 'लिंग (Gender) *' : 'Gender *',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A3427),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildGenderChip('Male', isHi ? 'पुरुष' : 'Male', '👨'),
                  const SizedBox(width: 8),
                  _buildGenderChip('Female', isHi ? 'महिला' : 'Female', '👩'),
                  const SizedBox(width: 8),
                  _buildGenderChip('Other', isHi ? 'अन्य' : 'Other', '👤'),
                ],
              ),
              const SizedBox(height: 14),

              // 3. Date of Birth & Time of Birth Row
              Row(
                children: [
                  // DOB
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHi ? 'जन्म तिथि *' : 'Date of Birth *',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4A3427),
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _selectDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBF8F2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE5D5C5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined,
                                    size: 18, color: Color(0xFF8B1E1E)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _formatDate(_dob),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF2D1810),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // TOB
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHi ? 'जन्म समय *' : 'Birth Time *',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4A3427),
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _selectTime,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: _unknownTime
                                  ? Colors.grey.shade100
                                  : const Color(0xFFFBF8F2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE5D5C5)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time_outlined,
                                    size: 18,
                                    color: _unknownTime
                                        ? Colors.grey
                                        : const Color(0xFF8B1E1E)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _unknownTime
                                        ? (isHi ? 'अज्ञात' : 'Unknown')
                                        : _tob.format(context),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: _unknownTime
                                          ? Colors.grey
                                          : const Color(0xFF2D1810),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Unknown time checkbox
              Row(
                children: [
                  Checkbox(
                    value: _unknownTime,
                    activeColor: const Color(0xFF8B1E1E),
                    onChanged: (v) => setState(() => _unknownTime = v ?? false),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  Text(
                    isHi
                        ? 'सटीक जन्म समय ज्ञात नहीं है (लगभग अनुमान लगाएं)'
                        : "Don't know exact birth time",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 4. Place of Birth
              Text(
                isHi ? 'जन्म स्थान (शहर / राज्य) *' : 'Place of Birth (City / State) *',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A3427),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _pobController,
                decoration: InputDecoration(
                  hintText: isHi ? 'उदा. वाराणसी, उत्तर प्रदेश' : 'e.g. Varanasi, Uttar Pradesh',
                  prefixIcon: const Icon(Icons.location_on_outlined,
                      color: Color(0xFF8B1E1E), size: 20),
                  filled: true,
                  fillColor: const Color(0xFFFBF8F2),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5D5C5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5D5C5)),
                  ),
                ),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? (isHi ? 'कृपया जन्म स्थान दर्ज करें' : 'Please enter place of birth')
                    : null,
              ),
              const SizedBox(height: 14),

              // 5. Consultation Topic / Concern
              Text(
                isHi ? 'परामर्श का मुख्य विषय (Topic)' : 'Primary Consultation Concern',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A3427),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _concerns.map((c) {
                  final isSelected = _concern == c['key'];
                  return ChoiceChip(
                    label: Text(
                      isHi ? c['hi']! : c['en']!,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF4A3427),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF8B1E1E),
                    backgroundColor: const Color(0xFFFBF8F2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF8B1E1E)
                            : const Color(0xFFE5D5C5),
                      ),
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _concern = c['key']!);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),

              // Confirm and Proceed Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B1E1E),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🕉️', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        isHi
                            ? 'विवरण सुरक्षित करें व चैट शुरू करें'
                            : 'Save Details & Start Consultation',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  isHi
                      ? '🔒 आपका विवरण 100% गोपनीय व सुरक्षित है।'
                      : '🔒 100% Private & Confidential Vedic Consultation.',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderChip(String value, String label, String emoji) {
    final isSelected = _gender == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _gender = value),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF8B1E1E) : const Color(0xFFFBF8F2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF8B1E1E)
                  : const Color(0xFFE5D5C5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF4A3427),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
