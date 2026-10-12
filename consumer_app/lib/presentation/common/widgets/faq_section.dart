import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/l10n/locale_service.dart';
import '../../../services/api_service.dart';

/// Expandable Bilingual FAQ section widget, used across Puja Listing, Puja Detail,
/// and Sacred Chadhawa screens.
///
/// Fetches FAQs from the backend by [serviceType] ('puja' or 'chadhawa')
/// and optionally a specific [serviceId]. Falls back to comprehensive built-in
/// bilingual FAQs (English & Hindi) matching devotee requirements.
class FaqSection extends StatefulWidget {
  /// 'puja', 'chadhawa', or 'general'
  final String serviceType;

  /// Specific puja_id or chadhawa offering_id (optional)
  final String? serviceId;

  /// Optional section title override (if null, bilingual default is used)
  final String? title;

  const FaqSection({
    super.key,
    required this.serviceType,
    this.serviceId,
    this.title,
  });

  @override
  State<FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<FaqSection> {
  List<Map<String, dynamic>> _faqs = [];
  bool _loading = true;
  String? _expandedId;

  // ─── Bilingual Built-in Fallback FAQs (English & Hindi) ──────────────────────

  static final List<Map<String, dynamic>> _pujaFallback = [
    {
      'id': 'pf1',
      'question': 'Do I need to be physically present at the temple?',
      'question_hi': 'क्या मुझे पूजा के लिए मंदिर में शारीरिक रूप से उपस्थित होना होगा?',
      'answer':
          'No. Our verified Vedic pandits perform the ritual on your behalf at the temple sanctum with your personalized Sankalp (name & Gotra). You can attend via a private live video stream link sent to you.',
      'answer_hi':
          'नहीं। हमारे सत्यापित वैदिक पंडित आपके नाम और गोत्र से विशेष संकल्प लेकर गर्भगृह में पूजा संपन्न करते हैं। आप अपने घर बैठे निजी लाइव वीडियो लिंक के माध्यम से पूजा में सम्मिलित हो सकते हैं।',
    },
    {
      'id': 'pf2',
      'question': 'How and when will I receive the sacred Prasad?',
      'question_hi': 'पवित्र प्रसाद मुझे कैसे और कब प्राप्त होगा?',
      'answer':
          'Consecrated Prasad — sacred Gangajal, dry fruits, sanctum Bhasma, Raksha Sutra, and Kumkum — is carefully packed and couriered to your doorstep within 4–7 working days with live parcel tracking.',
      'answer_hi':
          'पूजा के उपरांत अभिमंत्रित प्रसाद—गंगाजल, पंचमेवा, भस्म, रक्षा सूत्र व कुमकुम—पवित्रता से पैक करके 4–7 कार्य दिवसों में आपके पते पर स्पीड पोस्ट/कूरियर द्वारा भेज दिया जाता है। आप ऐप में लाइव ट्रैकिंग देख सकते हैं।',
    },
    {
      'id': 'pf3',
      'question': 'What is Sankalp and why is it important in Puja?',
      'question_hi': 'संकल्प क्या है और पूजा में इसका क्या महत्व है?',
      'answer':
          'Sankalp is the sacred Vedic declaration recited by the Acharya invoking your Name, Gotra, and wish before the deity, directing the spiritual merit and divine blessings of the ritual directly to you and your family.',
      'answer_hi':
          'संकल्प एक पवित्र वैदिक प्रतिज्ञा है जो आचार्य पूजा के आरंभ में आपके नाम, गोत्र और कुल का उच्चारण कर ईश्वर के समक्ष लेते हैं। इससे अनुष्ठान का संपूर्ण पुण्य फल सीधे आपको और आपके परिवार को प्राप्त होता है।',
    },
    {
      'id': 'pf4',
      'question': 'Can I watch the puja live and receive video proof?',
      'question_hi': 'क्या मुझे पूजा का लाइव दर्शन और वीडियो रिकॉर्डिंग मिलेगी?',
      'answer':
          'Yes! A private live-stream link is shared 30 minutes before the ceremony. After completion, a personalized recording of your name & Gotra Sankalp is uploaded to your "My Bookings" section.',
      'answer_hi':
          'हाँ! पूजा शुरू होने से 30 मिनट पहले आपको लाइव वीडियो का लिंक भेजा जाता है। पूजा संपन्न होने के बाद आपके नाम व गोत्र के संकल्प का वीडियो "मेरी बुकिंग" सेक्शन में हमेशा के लिए उपलब्ध रहता है।',
    },
    {
      'id': 'pf5',
      'question': 'Can I book a puja on behalf of my family members?',
      'question_hi': 'क्या मैं अपने माता-पिता या परिवार के सदस्यों के नाम से पूजा करवा सकता हूँ?',
      'answer':
          'Yes, absolutely! During booking, you can add up to 6 family members with their names and Gotra to be included in the sacred priest Sankalp.',
      'answer_hi':
          'हाँ, बिल्कुल! बुकिंग के समय आप अपने माता-पिता, जीवनसाथी व बच्चों सहित 6 परिजनों के नाम और गोत्र जोड़ सकते हैं। पंडित जी सभी के लिए सामूहिक कल्याण का संकल्प लेंगे।',
    },
    {
      'id': 'pf6',
      'question': 'Can I download a verified Puja Participation Certificate?',
      'question_hi': 'क्या मुझे पूजा का आधिकारिक सहभागिता प्रमाण पत्र मिलेगा?',
      'answer':
          'Yes! Once completed, you can instantly download a personalized digital Certificate of Participation featuring temple sanctum seal, your Gotra, and ritual date from "My Bookings".',
      'answer_hi':
          'हाँ! पूजा पूर्ण होने के बाद आप "मेरी बुकिंग" में जाकर मंदिर की सील, अपने नाम और गोत्र के साथ आधिकारिक डिजिटल सहभागिता प्रमाण पत्र डाउनलोड कर सकते हैं।',
    },
    {
      'id': 'pf7',
      'question': 'Are the pandits verified and qualified?',
      'question_hi': 'मंदिर के पंडित कितने अनुभवी और प्रामाणिक हैं?',
      'answer':
          'Every puja is conducted strictly by traditional Vedic scholars and Matha-certified Purohits with a minimum of 10–15 years of ritual priesthood experience at renowned pilgrimage shrines.',
      'answer_hi':
          'सभी पूजाएं 10-15 वर्षों से अधिक अनुभव वाले पारंपरिक वैदिक विद्वानों और तीर्थ पुरोहितों द्वारा संपन्न कराई जाती हैं। हमारे सभी पंडित पृष्ठभूमि सत्यापित और शास्त्र सम्मत हैं।',
    },
    {
      'id': 'pf8',
      'question': 'What is the cancellation and rescheduling policy?',
      'question_hi': 'पूजा रद्द या पुनर्निर्धारित (Reschedule) करने के क्या नियम हैं?',
      'answer':
          'You can reschedule or cancel with 100% refund up to 24 hours prior to the scheduled Muhurat. Within 24 hours, samagri and priest dakshina are already dedicated.',
      'answer_hi':
          'पूजा के निर्धारित मुहूर्त से 24 घंटे पहले तक आप इसे निःशुल्क पुनर्निर्धारित या 100% रिफंड के साथ रद्द कर सकते हैं। 24 घंटे के भीतर सामग्री और दक्षिणा समर्पित हो जाने के कारण बदलाव संभव नहीं होता।',
    },
  ];

  static final List<Map<String, dynamic>> _chadhawaFallback = [
    {
      'id': 'cf1',
      'question': 'What is sacred Chadhawa offering?',
      'question_hi': 'पवित्र चढ़ावा सेवा क्या है?',
      'answer':
          'Chadhawa is the sacred Hindu tradition of offering pure devotional items — such as Chunri, flowers, dry fruits, silver articles, mustard oil, or Gau Seva — directly at the sanctum sanctorum of holy temples on your behalf.',
      'answer_hi':
          'चढ़ावा हिंदू धर्म की पावन परंपरा है जिसमें भक्त की ओर से चुनरी, फल, मेवे, दीप, रजत आभूषण या गौ ग्रास सीधे मंदिर के गर्भगृह में विग्रह के चरणों में अर्पित किए जाते हैं।',
    },
    {
      'id': 'cf2',
      'question': 'How is the Chadhawa offered at the deity\'s feet?',
      'question_hi': 'चढ़ावा मंदिर के विग्रह के चरणों में कैसे अर्पित किया जाता है?',
      'answer':
          'The temple Sewadar and authorized priest take your offering directly to the deity\'s sanctum, recite your name and Gotra with prayer, and gently place the items at the holy feet.',
      'answer_hi':
          'मंदिर के अधिकृत पुजारी जी आपकी ओर से अर्पित सामग्री को गर्भगृह में ले जाकर आपके नाम और गोत्र का उच्चारण करते हैं और श्रद्धापूर्वक विग्रह के पावन चरणों में भेंट करते हैं।',
    },
    {
      'id': 'cf3',
      'question': 'Will I receive photo and video proof of my offering?',
      'question_hi': 'क्या मुझे चढ़ावा अर्पण का फोटो और वीडियो प्रमाण मिलेगा?',
      'answer':
          'Yes! Within 12–24 hours of offering, high-resolution photos and video proof showing your offering at the deity\'s sanctum with time-stamp are delivered to your Mandirm app.',
      'answer_hi':
          'हाँ! चढ़ावा अर्पित होने के 12 से 24 घंटे के भीतर गर्भगृह का फोटो व वीडियो प्रमाण (समय और मंदिर विवरण सहित) आपके मंदिरम् ऐप के "मेरी बुकिंग" में उपलब्ध करा दिया जाता है।',
    },
    {
      'id': 'cf4',
      'question': 'Can I download a digital certificate for my Chadhawa?',
      'question_hi': 'क्या मैं चढ़ावा अर्पण का डिजिटल प्रमाण पत्र डाउनलोड कर सकता हूँ?',
      'answer':
          'Yes! Every offering comes with a beautiful Sacred Chadhawa Certificate bearing your name, Gotra, offering type, and sacred temple seal, downloadable from "My Bookings".',
      'answer_hi':
          'हाँ! प्रत्येक चढ़ावा सेवा के बाद आपको आपके नाम, गोत्र और मंदिर की पावन मुहर के साथ एक सुंदर डिजिटल प्रमाण पत्र प्राप्त होता है, जिसे आप सीधे डाउनलोड कर सकते हैं।',
    },
    {
      'id': 'cf5',
      'question': 'Can I schedule my offering for specific festivals or tithis?',
      'question_hi': 'क्या मैं किसी विशेष तिथि या त्यौहार (जैसे एकादशी, शिवरात्रि, नवरात्रि) पर चढ़ावा करा सकता हूँ?',
      'answer':
          'Yes! You can select any upcoming auspicious tithi — Somwar, Shaniwar, Ekadashi, Amavasya, or Navratri — during booking to align your offering with maximum cosmic merit.',
      'answer_hi':
          'हाँ! आप बुकिंग करते समय अपनी इच्छानुसार शुभ तिथि (जैसे सोमवार, प्रदोष, एकादशी, अमावस्या, पूर्णिमा या नवरात्रि) चुन सकते हैं ताकि उस पावन पर्व पर ही आपका चढ़ावा अर्पित हो।',
    },
    {
      'id': 'cf6',
      'question': 'Which temples are currently available for Chadhawa?',
      'question_hi': 'किन-किन पवित्र मंदिरों में चढ़ावा सेवा उपलब्ध है?',
      'answer':
          'Mandirm facilitates Chadhawa across 108+ revered shrines including Mahakaleshwar (Ujjain), Kashi Vishwanath (Varanasi), Tirupati Balaji, Siddhivinayak (Mumbai), Kamakhya Devi, and Hanuman Garhi (Ayodhya).',
      'answer_hi':
          'मंदिरम् पर महाकालेश्वर (उज्जैन), काशी विश्वनाथ (वाराणसी), तिरुपति बालाजी, सिद्धि विनायक (मुंबई), कामाख्या देवी और हनुमान गढ़ी (अयोध्या) सहित 108+ प्रमुख धामों में चढ़ावा सेवा उपलब्ध है।',
    },
    {
      'id': 'cf7',
      'question': 'Do I receive blessed Prasad at home after offering Chadhawa?',
      'question_hi': 'क्या चढ़ावा अर्पित होने के बाद प्रसाद घर भेजा जाता है?',
      'answer':
          'For items that include consecrated return elements (such as Raksha Sutra, sacred Bhasma, or dry fruit boxes), the prasad is safely dispatched to your residential address.',
      'answer_hi':
          'जिन चढ़ावा पैकेज में प्रसाद शामिल है (जैसे रक्षा सूत्र, महाकाल भस्म, या पंचमेवा प्रसाद), वह प्रसाद सेवा के उपरांत कूरियर द्वारा आपके घर पर पहुंचा दिया जाता है।',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadFaqs();
  }

  Future<void> _loadFaqs() async {
    setState(() => _loading = true);
    try {
      final faqs = await ApiService().getFAQs(
        serviceType: widget.serviceType,
        serviceId: widget.serviceId,
        limit: 20,
      );
      if (mounted) {
        setState(() {
          _faqs = faqs.isNotEmpty ? faqs : _getFallback();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _faqs = _getFallback();
          _loading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getFallback() {
    if (widget.serviceType == 'chadhawa') return _chadhawaFallback;
    return _pujaFallback;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LocaleService().locale,
      builder: (context, currentLocale, _) {
        final isHi = currentLocale == LocaleService.hi;

        final displayTitle = widget.title ??
            (isHi ? 'अक्सर पूछे जाने वाले प्रश्न' : 'Frequently Asked Questions');
        final displaySubtitle = isHi
            ? (widget.serviceType == 'chadhawa'
                ? 'पवित्र चढ़ावा सेवा से जुड़ी संपूर्ण जानकारी'
                : 'वैदिक पूजा व अनुष्ठान से जुड़ी संपूर्ण जानकारी')
            : (widget.serviceType == 'chadhawa'
                ? 'Everything you need to know about sacred Chadhawa'
                : 'Everything you need to know about Vedic Pujas');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Text(
              displayTitle,
              style: TextStyle(fontFamily: 'Headway', 
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4A1005),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              displaySubtitle,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                color: const Color(0xFF7A5C3A),
              ),
            ),
            const SizedBox(height: 12),

            if (_loading)
              _buildShimmer()
            else if (_faqs.isEmpty)
              _buildEmpty(isHi)
            else
              ..._faqs.map((faq) => _buildFaqItem(faq, isHi)),
          ],
        );
      },
    );
  }

  Widget _buildFaqItem(Map<String, dynamic> faq, bool isHi) {
    final id = faq['id']?.toString() ?? faq['question'].toString();
    final isExpanded = _expandedId == id;

    // Bilingual resolution
    final question = isHi
        ? (faq['question_hi']?.toString() ?? faq['question']?.toString() ?? '')
        : (faq['question']?.toString() ?? '');
    final answer = isHi
        ? (faq['answer_hi']?.toString() ?? faq['answer']?.toString() ?? '')
        : (faq['answer']?.toString() ?? '');

    return GestureDetector(
      onTap: () => setState(() => _expandedId = isExpanded ? null : id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isExpanded ? const Color(0xFFFFF8F0) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isExpanded
                ? const Color(0xFFD4A017).withValues(alpha: 0.5)
                : const Color(0xFFEFE4D2),
            width: isExpanded ? 1.5 : 1,
          ),
          boxShadow: isExpanded
              ? [
                  BoxShadow(
                    color: const Color(0xFFD4A017).withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Q badge
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isExpanded
                          ? const Color(0xFFD4A017)
                          : const Color(0xFFF5E6C8),
                    ),
                    child: Center(
                      child: Text(
                        isHi ? 'प्र' : 'Q',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isExpanded
                              ? Colors.white
                              : const Color(0xFF7A5C3A),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      question,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF231E1B),
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isExpanded
                          ? const Color(0xFFD4A017)
                          : const Color(0xFF9E8E7A),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Answer (animated)
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE8F5E9),
                      ),
                      child: Center(
                        child: Text(
                          isHi ? 'उ' : 'A',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        answer,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF4A3E38),
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Column(
      children: List.generate(
        4,
        (i) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFF5EEE3),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(bool isHi) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          isHi
              ? 'वर्तमान में कोई प्रश्न उपलब्ध नहीं है।'
              : 'No FAQs available at the moment.',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF9E8E7A),
          ),
        ),
      ),
    );
  }
}
