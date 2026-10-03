import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class GlobalSearchDialog extends StatefulWidget {
  final Function(int tabIndex, String? filter) onSelect;
  const GlobalSearchDialog({super.key, required this.onSelect});

  @override
  State<GlobalSearchDialog> createState() => _GlobalSearchDialogState();
}

class _GlobalSearchDialogState extends State<GlobalSearchDialog> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  final List<Map<String, dynamic>> _catalog = [
    {'title': 'Kashi Vishwanath Mandir', 'subtitle': 'Varanasi • Lord Shiva Jyotirlinga', 'type': 'Mandir', 'icon': '🔱', 'tab': 1},
    {'title': 'Mahakaleshwar Jyotirlinga', 'subtitle': 'Ujjain • Bhasma Aarti', 'type': 'Mandir', 'icon': '🕉️', 'tab': 1},
    {'title': 'Tirupati Balaji Mandir', 'subtitle': 'Tirumala • Lord Venkateswara', 'type': 'Mandir', 'icon': '🪷', 'tab': 1},
    {'title': 'Siddhivinayak Mandir', 'subtitle': 'Mumbai • Lord Ganesha', 'type': 'Mandir', 'icon': '🐘', 'tab': 1},
    {'title': 'Maa Vaishno Devi Shrine', 'subtitle': 'Katra • Pindi Darshan', 'type': 'Mandir', 'icon': '🌸', 'tab': 1},
    {'title': 'Maha Rudrabhishek with 108 Bilva Patra', 'subtitle': '₹1,100 • Kashi Vishwanath', 'type': 'Puja', 'icon': '🔥', 'tab': 2},
    {'title': 'Navchandi Shatru & Graha Shanti Homa', 'subtitle': '₹2,501 • Kamakhya Devi', 'type': 'Puja', 'icon': '🔥', 'tab': 2},
    {'title': 'Kaal Sarp & Rahu-Ketu Shanti Puja', 'subtitle': '₹3,100 • Mahakaleshwar', 'type': 'Puja', 'icon': '🔥', 'tab': 2},
    {'title': 'Mahamrityunjaya 1.25 Lakh Japa', 'subtitle': '₹5,100 • Kedarnath Dham', 'type': 'Puja', 'icon': '🔥', 'tab': 2},
    {'title': 'Pt. Devendra Shastri', 'subtitle': 'Vedic • Kundali • Vastu • ₹25/min', 'type': 'Astrologer', 'icon': '🧘‍♂️', 'tab': 3},
    {'title': 'Acharya Radheshyam', 'subtitle': 'Prashna Kundali • Career • ₹20/min', 'type': 'Astrologer', 'icon': '🔮', 'tab': 3},
    {'title': 'Dr. Gayatri Devi', 'subtitle': 'Numerology • Gemology • ₹30/min', 'type': 'Astrologer', 'icon': '🪷', 'tab': 3},
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _catalog.where((item) {
      final q = _query.toLowerCase();
      if (q.isEmpty) return true;
      return (item['title'] as String).toLowerCase().contains(q) ||
          (item['subtitle'] as String).toLowerCase().contains(q) ||
          (item['type'] as String).toLowerCase().contains(q);
    }).toList();

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Input Field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    onChanged: (val) => setState(() => _query = val),
                    decoration: InputDecoration(
                      hintText: 'Search Mandirs, Pujas, Astrologers...',
                      hintStyle: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMutedLight),
                      prefixIcon: const Icon(Icons.search, color: AppColors.saffronPrimary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Text(
                        'No matching Mandirs or Pujas found',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final r = results[i];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.warmCream,
                            child: Text(r['icon'] as String, style: const TextStyle(fontSize: 20)),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  r['title'] as String,
                                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.saffronLight.withAlpha(50),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  r['type'] as String,
                                  style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.saffronDark),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            r['subtitle'] as String,
                            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 12),
                          onTap: () {
                            Navigator.pop(context);
                            widget.onSelect(r['tab'] as int, r['title'] as String);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
