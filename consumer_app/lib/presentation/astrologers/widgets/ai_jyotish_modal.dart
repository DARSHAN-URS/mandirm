import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/l10n/locale_service.dart';
import '../../../services/devotee_data_service.dart';
import '../../../services/supabase_service.dart';

/// Interactive AI Jyotish (एआई ज्योतिषी) Modal
/// 24/7 Real-Time Divine Vedic Astrology Assistant powered by AI.
class AiJyotishModal extends StatefulWidget {
  final String? initialQuestion;
  final VoidCallback? onConsultationFinished;

  const AiJyotishModal({
    super.key,
    this.initialQuestion,
    this.onConsultationFinished,
  });

  @override
  State<AiJyotishModal> createState() => _AiJyotishModalState();
}

class _AiJyotishModalState extends State<AiJyotishModal> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  int _sessionQuestionCount = 0;

  // Devotee details
  late final String _devoteeName;
  late final String _gotra;
  late final String _rashi;

  List<String> get _quickPrompts {
    final isHi = LocaleService().isHindi;
    if (isHi) {
      return [
        '🔮 मेरी कुंडली के मुख्य ग्रह दोष और उपाय',
        '💼 नौकरी और करियर में तरक्की कब होगी?',
        '❤️ विवाह योग और मांगलिक दोष निवारण',
        '💰 धन लाभ और व्यापार वृद्धि के उपाय',
        '🪐 शनि साढ़े साती के वैदिक उपाय व मंत्र',
        '💎 मेरी राशि के लिए शुभ रत्न व रुद्राक्ष',
      ];
    }
    return [
      '🔮 What are the primary doshas in my Kundli?',
      '💼 When will my career & job prospects improve?',
      '❤️ Marriage prospects and Manglik dosha remedies',
      '💰 Vedic remedies for financial growth & business',
      '🪐 Shani Sade Sati remedies and pacification',
      '💎 Auspicious gemstone and Rudraksha for my Rashi',
    ];
  }

  @override
  void initState() {
    super.initState();

    final user = SupabaseService().currentUser;
    _devoteeName = user?.userMetadata?['full_name'] as String? ??
        user?.userMetadata?['name'] as String? ??
        'Devotee';
    _gotra = user?.userMetadata?['gotra'] as String? ?? 'Kashyap';
    _rashi = user?.userMetadata?['rashi'] as String? ?? 'Mesha (Aries)';

    // Initial greeting message
    final isHi = LocaleService().isHindi;
    _messages.add({
      'sender': 'ai',
      'time': 'Just now',
      'text': isHi
          ? 'हर हर महादेव! 🙏 प्रणाम $_devoteeName जी (गोत्र: $_gotra, राशि: $_rashi)।\n\nमैं हूँ आपका 24x7 दिव्य **आचार्य एआई ज्योतिषी**। पराशर ज्योतिष और वैदिक ग्रह गोचर के आधार पर आप करियर, कुंडली, विवाह या गृह शांति से संबंधित कोई भी प्रश्न पूछ सकते हैं।'
          : 'Har Har Mahadev! 🙏 Pranam $_devoteeName ji (Gotra: $_gotra, Rashi: $_rashi).\n\nI am your 24x7 divine **Acharya AI Jyotish**. Based on Vedic Parashara astrology and planetary transits, you can ask me any question regarding your Career, Kundli Doshas, Marriage, or Divine Remedies.',
      'mantra': 'ॐ सूर्याय नमः • ॐ नमः शिवाय',
    });

    if (widget.initialQuestion != null && widget.initialQuestion!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleSend(widget.initialQuestion!.trim());
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend([String? presetText]) {
    final query = (presetText ?? _textController.text).trim();
    if (query.isEmpty) return;

    _textController.clear();
    HapticFeedback.lightImpact();

    setState(() {
      _messages.add({
        'sender': 'user',
        'time': 'Just now',
        'text': query,
      });
      _isTyping = true;
      _sessionQuestionCount++;
    });

    _scrollToBottom();

    // Generate Vedic AI response
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      final aiResponse = _generateVedicResponse(query);

      setState(() {
        _isTyping = false;
        _messages.add(aiResponse);
      });

      _scrollToBottom();
      HapticFeedback.mediumImpact();
    });
  }

  Map<String, dynamic> _generateVedicResponse(String query) {
    final q = query.toLowerCase();
    final isHi = LocaleService().isHindi;

    if (q.contains('करियर') ||
        q.contains('नौकरी') ||
        q.contains('व्यापार') ||
        q.contains('career') ||
        q.contains('job') ||
        q.contains('promotion') ||
        q.contains('business')) {
      return {
        'sender': 'ai',
        'time': 'Just now',
        'title': isHi ? 'कर्म भाव व सूर्य ग्रह विश्लेषण' : 'Karma Bhava & Surya Transit Analysis',
        'text': isHi
            ? 'आपकी कुंडली में दशम भाव (कर्म भाव) का स्वामी ग्रह बलवान हो रहा है। आगामी 3 माह में पदोन्नति और नए व्यापारिक अवसरों के शुभ संकेत हैं। वरिष्ठ अधिकारियों व सहकर्मियों का सहयोग मिलेगा।'
            : 'According to Vedic Parashara astrology, your 10th house of Karma is strengthening under the auspicious gaze of Jupiter (Brihaspati). The upcoming 3 months show favorable transits for career progression and business expansion.',
        'mantra': 'ॐ ह्रां ह्रीं ह्रौं सः सूर्याय नमः',
        'remedy': isHi
            ? '1. प्रतिदिन प्रातः तांबे के लोटे में जल, कुमकुम व अक्षत डालकर भगवान सूर्य को अर्घ्य दें।\n2. रविवार को आदित्य हृदय स्तोत्र का पाठ करें।\n3. जरूरतमंदों को गुड़ या चने की दाल का दान करें।'
            : '1. Offer water (Arghya) in a copper vessel to Lord Surya every morning at sunrise with red vermilion.\n2. Chant the Aditya Hridaya Stotram on Sundays.\n3. Donate jaggery and roasted gram to the needy.',
        'suggestedPuja': 'Navgraha Shanti Maha Puja',
      };
    }

    if (q.contains('विवाह') ||
        q.contains('मांगलिक') ||
        q.contains('marriage') ||
        q.contains('love') ||
        q.contains('relationship') ||
        q.contains('partner') ||
        q.contains('wedding')) {
      return {
        'sender': 'ai',
        'time': 'Just now',
        'title': isHi ? 'सप्तम भाव व वैवाहिक योग' : '7th House Kalatra & Marriage Yoga',
        'text': isHi
            ? 'सप्तम भाव वैवाहिक जीवन का प्रतिनिधित्व करता है। यदि कुंडली में मंगल दोष का प्रभाव है, तो भी गुरु की शुभ दृष्टि से दोष शांत होता है। आगामी समय में अनुकूल जीवनसाथी मिलने के प्रबल योग बन रहे हैं।'
            : 'The 7th house governs marriage and partnership. Auspicious Jupiter aspects diminish any minor Manglik afflictions, ushering in matrimonial harmony and promising alliances in the coming quarters.',
        'mantra': 'ॐ कात्यायनि महामाये महायोगिन्यधीश्वरि । नन्दगोपसुतं देवि पतिं मे कुरु ते नमः ॥',
        'remedy': isHi
            ? '1. प्रत्येक मंगलवार को हनुमान चालीसा का 3 बार पाठ करें।\n2. गुरुवार के दिन भगवान विष्णु और मां लक्ष्मी को पीले पुष्प अर्पित करें।\n3. तुलसी के पौधे में नियमित रूप से शाम को घी का दीपक प्रज्वलित करें।'
            : '1. Recite Hanuman Chalisa 3 times every Tuesday.\n2. Offer yellow marigold flowers to Lord Vishnu and Devi Lakshmi on Thursdays.\n3. Light a pure cow ghee lamp near holy Tulsi in the evening.',
        'suggestedPuja': 'Gauri Shankar Vivah Badha Nivaran Puja',
      };
    }

    if (q.contains('शनि') ||
        q.contains('साढ़े साती') ||
        q.contains('राहु') ||
        q.contains('केतु') ||
        q.contains('shani') ||
        q.contains('sade sati') ||
        q.contains('rahu') ||
        q.contains('ketu')) {
      return {
        'sender': 'ai',
        'time': 'Just now',
        'title': isHi ? 'शनि देव व छाया ग्रह शांति' : 'Lord Shani & Shadow Planets Pacification',
        'text': isHi
            ? 'शनि देव कर्मफलदाता हैं। साढ़े साती या ढैय्या जीवन में अनुशासन और कर्म शुद्धि लाती है। सेवा भाव और न्यायप्रिय आचरण रखने पर शनि देव अपार सफलता, स्थिरता और ख्याति प्रदान करते हैं।'
            : 'Lord Saturn is the cosmic lord of justice (Karmaphala-data). Transits of Shani and Rahu cleanse karmic debts and bring long-term maturity and enduring prosperity when approached with humility and seva.',
        'mantra': 'ॐ प्रां प्रीं प्रौं सः शनैश्चराय नमः',
        'remedy': isHi
            ? '1. शनिवार की शाम पीपल के वृक्ष के नीचे सरसों के तेल का चौमुखा दीपक जलाएं।\n2. काले तिल, उड़द की दाल और कंबल का दान करें।\n3. नित्य \'ॐ शं शनैश्चराय नमः\' मंत्र की 1 माला (108 बार) जपें।'
            : '1. Light a mustard oil lamp under a sacred Peepal tree on Saturday evenings.\n2. Donate black sesame seeds, black gram, and blankets to the underprivileged.\n3. Chant the Shani Gayatri Mantra 108 times daily.',
        'suggestedPuja': 'Maha Rudrabhishek with 108 Bilva Patra',
      };
    }

    if (q.contains('दोष') ||
        q.contains('कुंडली') ||
        q.contains('कालसर्प') ||
        q.contains('पितृ') ||
        q.contains('dosha') ||
        q.contains('kundli') ||
        q.contains('horoscope') ||
        q.contains('kalsarp') ||
        q.contains('pitr')) {
      return {
        'sender': 'ai',
        'time': 'Just now',
        'title': isHi ? 'कुंडली दोष व वैदिक निवारण' : 'Kundli Dosha & Planetary Remedies',
        'text': isHi
            ? 'आपकी राशि के अनुसार ग्रह गोचर में कुछ अल्प कालसर्प या पितृ दोष प्रभाव दिख सकते हैं, जिससे कार्यों में अचानक विलंब होता है। भगवान शिव की आराधना से सभी प्रकार के ग्रह दोष स्वतः भस्म हो जाते हैं।'
            : 'Transits indicate mild planetary tension (Pitr or Rahu-Ketu axis), which can cause temporary delays in key endeavors. Chanting Shiva Mahamrityunjaya is the supreme universal Vedic antidote.',
        'mantra': 'ॐ त्र्यम्बकं यजामहे सुगन्धिं पुष्टिवर्धनम् । उर्वारुकमिव बन्धनान्मृत्यchainsोर्मुक्षीय मामृतात् ॥',
        'remedy': isHi
            ? '1. महामृत्युंजय मंत्र का प्रतिदिन 11 बार स्मरण करें।\n2. सोमवार को शिवलिंग पर कच्चा दूध, गंगाजल और बेलपत्र अर्पित करें।\n3. अमावस्या के दिन पितरों के निमित्त अन्न और जल का दान करें।'
            : '1. Chant the sacred Mahamrityunjaya Mantra 11 times every morning.\n2. Perform Jalabhishek with pure water and Bilva leaves on Shiva Lingam on Mondays.\n3. Donate anna (food grains) on Amavasya in memory of ancestors.',
        'suggestedPuja': 'Kashi Vishwanath Rudrabhishek',
      };
    }

    if (q.contains('धन') ||
        q.contains('समृद्धि') ||
        q.contains('लक्ष्मी') ||
        q.contains('wealth') ||
        q.contains('money') ||
        q.contains('finance') ||
        q.contains('prosperity')) {
      return {
        'sender': 'ai',
        'time': 'Just now',
        'title': isHi ? 'धन भाव व महालक्ष्मी योग' : 'Dhana Bhava & Maha Lakshmi Yoga',
        'text': isHi
            ? 'द्वितीय और एकादश भाव (धन व लाभ भाव) आपकी कुंडली में अत्यंत शुभ स्थिति में हैं। धन संचय और संपत्ति वृद्धि के लिए श्री सूक्त का पाठ अमोघ फलदायी होता है।'
            : 'Your 2nd and 11th houses of wealth and cumulative gains reflect auspicious yogas. Worshiping Devi Mahalakshmi aligns cosmic abundance and stabilizes household finances.',
        'mantra': 'ॐ श्रीं ह्रीं क्लीं श्री सिद्ध लक्ष्म्यै नमः',
        'remedy': isHi
            ? '1. शुक्रवार को कनकधारा स्तोत्र या श्री सूक्त का पाठ करें।\n2. घर के ईशान कोण (उत्तर-पूर्व) को सदा स्वच्छ व सुगंधित रखें।\n3. गाय को प्रतिदिन पहली रोटी गुड़ के साथ खिलाएं।'
            : '1. Recite Sri Suktam or Kanakadhara Stotram on Fridays.\n2. Keep the North-East (Ishan Kona) corner clean, lit, and clutter-free.\n3. Feed the first roti of the day to a sacred cow.',
        'suggestedPuja': 'Tirupati Balaji Maha Lakshmi Puja',
      };
    }

    // Default universal Vedic answer
    return {
      'sender': 'ai',
      'time': 'Just now',
      'title': isHi ? 'वैदिक मार्गदर्शन व ग्रह समाधान' : 'Divine Vedic Astrological Guidance',
      'text': isHi
          ? 'प्रिय जातक, आपकी जन्म लग्न कुंडली में बृहस्पति की शुभ दृष्टि सभी संकटों से रक्षा करने में समर्थ है। जब भी मन में संशय या चिंता हो, ईश्वर स्मरण और सत्कर्म से ग्रहों की प्रतिकूलता भी अनुकूल हो जाती है।'
          : 'Dear Devotee, divine Jupiter\'s aspect shields your natal chart from major adversities. Regular daily devotion and right action (Dharma) harmonize planetary energies and unlock boundless peace.',
      'mantra': 'ॐ भूर्भुवः स्वः तत्सवितुर्वरेण्यं भर्गो देवस्य धीमहि धियो यो नः प्रचोदयात् ॥',
      'remedy': isHi
          ? '1. नित्य गायत्री मंत्र का 21 बार जप करें।\n2. माता-पिता व गुरुजनों के चरण स्पर्श कर आशीर्वाद लें।\n3. किसी भी शुभ कार्य से पूर्व भगवान गणेश का स्मरण करें।'
          : '1. Chant Gayatri Mantra 21 times at sunrise.\n2. Seek blessings from elders and spiritual teachers.\n3. Pray to Lord Ganesha with Durva grass before commencing any new venture.',
      'suggestedPuja': 'Navgraha Shanti Maha Puja',
    };
  }

  void _finishSession() {
    if (_sessionQuestionCount > 0) {
      final isHi = LocaleService().isHindi;
      DevoteeDataService().addConsultation({
        'id': 'CNS-AI-${DateTime.now().millisecondsSinceEpoch % 10000}',
        'astrologerName': 'Acharya AI Jyotish (एआई ज्योतिषी)',
        'specialty': 'Instant 24/7 AI Vedic Guidance & Remedies',
        'date': 'Just now',
        'duration': '$_sessionQuestionCount questions',
        'amount': 'FREE (AI Seva)',
        'remedy': isHi
            ? 'दैनिक सूर्य अर्घ्य, गायत्री जप (21x) व महामृत्युंजय मंत्र द्वारा ग्रह शांति।'
            : 'Daily Surya Arghya, Gayatri Mantra (21x) and Shiva worship for planetary peace.',
        'rating': 5.0,
      });
      if (widget.onConsultationFinished != null) {
        widget.onConsultationFinished!();
      }
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isHi = LocaleService().isHindi;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Color(0xFFFBF8F2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // 1. Celestial Header with AI Tag & Devotee Metadata
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF380802),
                  Color(0xFF6B150A),
                  Color(0xFF91240D),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top drag handle
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Row(
                  children: [
                    // Glowing Celestial Avatar
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD54F), Color(0xFFE65100)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFB300).withValues(alpha: 0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🔮', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  isHi ? 'आचार्य एआई ज्योतिषी' : 'Acharya AI Jyotish',
                                  style: TextStyle(fontFamily: 'Headway', 
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFFFF3CD),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD97706),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'AI 24/7',
                                  style: GoogleFonts.poppins(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4ADE80),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                isHi
                                    ? 'उपलब्ध • त्वरित वैदिक उत्तर'
                                    : 'Online • Instant Vedic Insights',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      onPressed: _finishSession,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Devotee Gotra & Rashi Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFFFD54F).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '👤 $_devoteeName',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFFE082),
                        ),
                      ),
                      Text(
                        '☸️ ${isHi ? "गोत्र:" : "Gotra:"} $_gotra • ${isHi ? "राशि:" : "Rashi:"} $_rashi',
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Chat Conversation View
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _buildTypingIndicator();
                }
                final msg = _messages[index];
                final isAi = msg['sender'] == 'ai';
                return isAi ? _buildAiMessageBubble(msg) : _buildUserMessageBubble(msg);
              },
            ),
          ),

          // 3. Horizontal Quick Prompt Pills
          Container(
            height: 38,
            margin: const EdgeInsets.only(bottom: 6),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _quickPrompts.length,
              itemBuilder: (context, i) {
                final prompt = _quickPrompts[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _handleSend(prompt),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE5DDD0),
                          width: 1.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          prompt,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B150A),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 4. Message Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFEDE4D4))),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBF8F2),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                            color: const Color(0xFFE5DDD0), width: 1.1),
                      ),
                      child: TextField(
                        controller: _textController,
                        onSubmitted: (_) => _handleSend(),
                        textInputAction: TextInputAction.send,
                        decoration: InputDecoration(
                          hintText: isHi
                              ? 'कुंडली, करियर, विवाह या उपाय पूछें...'
                              : 'Ask about Kundli, Career, Remedies...',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 12.5,
                            color: const Color(0xFF9CA3AF),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF91240D), Color(0xFFD97706)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF91240D).withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                      onPressed: () => _handleSend(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessageBubble(Map<String, dynamic> msg) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 40),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: const BoxDecoration(
          color: Color(0xFF8B1E1E),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          msg['text'] as String,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.white,
            height: 1.35,
          ),
        ),
      ),
    );
  }

  Widget _buildAiMessageBubble(Map<String, dynamic> msg) {
    final title = msg['title'] as String?;
    final text = msg['text'] as String;
    final mantra = msg['mantra'] as String?;
    final remedy = msg['remedy'] as String?;
    final suggestedPuja = msg['suggestedPuja'] as String?;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14, right: 30),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: const Color(0xFFEDE4D4), width: 1.1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title if present
            if (title != null) ...[
              Row(
                children: [
                  const Text('✨', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(fontFamily: 'Headway', 
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6B150A),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(color: Color(0xFFF4ECE0), height: 16),
            ],

            // Main Answer
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: const Color(0xFF332D29),
                height: 1.45,
              ),
            ),

            // Sacred Vedic Mantra Box
            if (mantra != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9ED),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFBE4BA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🕉️ वैदिक मंत्र (Vedic Mantra)',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mantra,
                      style: GoogleFonts.martel(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF451A03),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Vedic Remedy Box
            if (remedy != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBF4EB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEADBC8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🌸 निवारण उपाय (Prescribed Remedy)',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF7A0C16),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      remedy,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: const Color(0xFF3E332E),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Suggested Temple Puja link
            if (suggestedPuja != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.temple_hindu_rounded,
                      size: 14, color: Color(0xFFB45309)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${LocaleService().isHindi ? "संबंधित पूजा:" : "Recommended Puja:"} $suggestedPuja',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEDE4D4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔮', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Text(
              LocaleService().isHindi
                  ? 'आचार्य जी कुंडली का विश्लेषण कर रहे हैं...'
                  : 'Acharya AI is analyzing planetary transits...',
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                color: const Color(0xFF7A6E65),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
