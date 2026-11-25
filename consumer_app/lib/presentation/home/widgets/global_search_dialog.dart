import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/locale_service.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../services/api_service.dart';

class GlobalSearchDialog extends StatefulWidget {
  final Function(int tabIndex, String? filter) onSelect;
  const GlobalSearchDialog({super.key, required this.onSelect});

  @override
  State<GlobalSearchDialog> createState() => _GlobalSearchDialogState();
}

class _GlobalSearchDialogState extends State<GlobalSearchDialog> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  final List<Map<String, dynamic>> _catalog = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLiveCatalog();
  }

  Future<void> _loadLiveCatalog() async {
    try {
      final futures = await Future.wait([
        ApiService().getTemples(limit: 60),
        ApiService().getPujas(limit: 60),
        ApiService().getAstrologers(limit: 60),
      ]);
      final temples = futures[0];
      final pujas = futures[1];
      final astros = futures[2];

      final List<Map<String, dynamic>> items = [];
      for (final t in temples) {
        items.add({
          'title': t['name'] ?? 'Sacred Mandir',
          'subtitle': '${t['city'] ?? ''} • ${t['deity'] ?? 'Devotion'}',
          'type': 'Mandir',
          'icon': '🛕',
          'tab': 1,
        });
      }
      for (final p in pujas) {
        items.add({
          'title': p['title'] ?? 'Vedic Puja Ritual',
          'subtitle': '₹${p['price'] ?? 1100} • ${p['temple_name'] ?? 'Temple Sanctum'}',
          'type': 'Puja',
          'icon': '🔥',
          'tab': 1,
        });
      }
      for (final a in astros) {
        items.add({
          'title': a['name'] ?? 'Vedic Astrologer',
          'subtitle': '${a['specialties'] ?? a['specialities'] ?? 'Vedic Astrology'} • ₹${a['per_minute_chat_rate'] ?? 25}/min',
          'type': 'Astrologer',
          'icon': '🧘‍♂️',
          'tab': 2,
        });
      }

      if (mounted) {
        setState(() {
          _catalog.clear();
          _catalog.addAll(items);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LocaleService().locale,
      builder: (context, locale, _) {
        final isHi = locale == LocaleService.hi;
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
                          hintText: isHi ? 'मंदिर, पूजा, ज्योतिषी खोजें...' : 'Search Mandirs, Pujas, Astrologers...',
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
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.saffronPrimary,
                          ),
                        )
                      : results.isEmpty
                          ? Center(
                              child: Text(
                                isHi ? 'कोई मंदिर, पूजा या ज्योतिषी नहीं मिला' : 'No matching Mandirs, Pujas or Astrologers found',
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
      },
    );
  }
}
