/// Central Entity Localizer for Mandirm Consumer App.
/// Transforms temples, pujas, astrologers, chadhawa offerings, and products
/// between English and authentic Hindi so no mixed language appears on screen.
class EntityLocalizer {
  EntityLocalizer._();

  // ─────────────────────────────────────────────────────────────────────────
  // DEITY MAP
  // ─────────────────────────────────────────────────────────────────────────
  static const Map<String, String> deityMapHi = {
    'Lord Shiva': 'भगवान शिव',
    'Lord Shiva (Mahakal)': 'भगवान शिव (महाकाल)',
    'Lord Ganesha': 'भगवान श्री गणेश',
    'Lord Venkateswara (Vishnu)': 'भगवान वेंकटेश्वर (विष्णु)',
    'Lord Venkateswara': 'भगवान वेंकटेश्वर',
    'Lord Balaji': 'भगवान तिरुपति बालाजी',
    'Maa Vaishno Devi': 'माँ वैष्णो देवी',
    'Maa Durga': 'माँ भगवती दुर्गा',
    'Maa Durga / Devi': 'माँ दुर्गा / शक्तिपीठ',
    'Maa Durga / Shakti': 'माँ दुर्गा / शक्तिपीठ',
    'Navgrah Devatas': 'नवग्रह देवता',
    'Lord Hanuman': 'हनुमान जी',
    'Hanuman Ji': 'हनुमान जी',
    'Lord Krishna': 'भगवान श्रीकृष्ण',
    'Lord Ram': 'प्रभु श्रीराम',
    'Lord Vishnu': 'भगवान श्रीहरि विष्णु',
    'Vishnu / Krishna': 'विष्णु / कृष्ण',
    'Shri Baglamukhi Mata Ji': 'श्री बगलामुखी माता जी',
    'Maa Baglamukhi': 'माँ बगलामुखी',
    'Baglamukhi': 'श्री बगलामुखी माता जी',
    'Shri Baglamukhi': 'श्री बगलामुखी',
    'Lord Jagannath': 'भगवान श्री जगन्नाथ',
    'Shiva': 'भगवान शिव',
    'Ganesha': 'भगवान गणेश',
    'Durga': 'माँ दुर्गा',
  };

  static String localizeDeity(String deity, bool isHi) {
    if (!isHi) return deity;
    if (deityMapHi.containsKey(deity)) return deityMapHi[deity]!;
    for (final entry in deityMapHi.entries) {
      if (deity.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return deity;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CITY / LOCATION MAP
  // ─────────────────────────────────────────────────────────────────────────
  static const Map<String, String> cityMapHi = {
    'Varanasi': 'वाराणसी',
    'Tirupati': 'तिरुपति',
    'Mumbai': 'मुंबई',
    'Ujjain': 'उज्जैन',
    'Katra': 'कटरा',
    'Prabhas Patan': 'प्रभास पाटन',
    'Veraval': 'वेरावल',
    'Bagli, Pandoh': 'बागली, पंडोह',
    'Bagli': 'बागली',
    'Pandoh': 'पंडोह',
    'Mandi': 'मंडी',
    'Haridwar': 'हरिद्वार',
    'Rishikesh': 'ऋषिकेश',
    'Ayodhya': 'अयोध्या',
    'Mathura': 'मथुरा',
    'Vrindavan': 'वृंदावन',
    'Puri': 'पुरी',
    'Rameswaram': 'रामेश्वरम',
    'Kedarnath': 'केदारनाथ',
    'Badrinath': 'बद्रीनाथ',
    'Uttar Pradesh': 'उत्तर प्रदेश',
    'Andhra Pradesh': 'आंध्र प्रदेश',
    'Maharashtra': 'महाराष्ट्र',
    'Madhya Pradesh': 'मध्य प्रदेश',
    'Jammu & Kashmir': 'जम्मू और कश्मीर',
    'Gujarat': 'गुजरात',
    'Himachal Pradesh': 'हिमाचल प्रदेश',
    'Uttarakhand': 'उत्तराखंड',
    'Odisha': 'ओडिशा',
    'Tamil Nadu': 'तमिलनाडु',
    'Rajasthan': 'राजस्थान',
  };

  static String localizeLocation(String loc, bool isHi) {
    if (!isHi) return loc;
    String res = loc;
    for (final entry in cityMapHi.entries) {
      res = res.replaceAll(entry.key, entry.value);
    }
    return res;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TEMPLES LOCALIZER
  // ─────────────────────────────────────────────────────────────────────────
  static Map<String, dynamic> localizeTemple(Map<String, dynamic> raw, bool isHi) {
    final rawName = raw['name']?.toString() ?? 'Sacred Mandir';
    final rawDeity = raw['deity']?.toString() ?? 'Lord Shiva';
    final rawCity = raw['city']?.toString() ?? 'Holy City';
    final rawState = raw['state']?.toString() ?? '';
    final combinedCity = rawState.isNotEmpty && !rawCity.contains(rawState)
        ? '$rawCity, $rawState'
        : rawCity;
    final rawDesc = raw['description']?.toString() ?? '';
    final rawAartis = raw['aartis'] as List<dynamic>? ?? [];

    if (!isHi) {
      // English cleanup
      return {
        ...raw,
        'name': rawName,
        'deity': rawDeity,
        'city': combinedCity,
        'description': rawDesc,
      };
    }

    final lower = (rawName + ' ' + rawDeity).toLowerCase();

    String nameHi = raw['name_hi']?.toString() ?? '';
    String deityHi = raw['deity_hi']?.toString() ?? '';
    String cityHi = raw['city_hi']?.toString() ?? '';
    String descHi = raw['description_hi']?.toString() ?? '';

    if (lower.contains('kashi') || lower.contains('vishwanath')) {
      nameHi = 'श्री काशी विश्वनाथ ज्योतिर्लिंग मंदिर';
      deityHi = 'भगवान शिव';
      cityHi = 'वाराणसी, उत्तर प्रदेश';
      descHi = 'द्वादश ज्योतिर्लिंगों में से एक परम पावन धाम, जो मोक्षदायिनी पुण्यसलिला माँ गंगा के पश्चिमी तट पर प्रतिष्ठित है।';
    } else if (lower.contains('tirupati') || lower.contains('balaji') || lower.contains('venkateswara')) {
      nameHi = 'श्री तिरुपति बालाजी (श्री वेंकटेश्वर स्वामी)';
      deityHi = 'भगवान वेंकटेश्वर (विष्णु)';
      cityHi = 'तिरुपति, आंध्र प्रदेश';
      descHi = 'कलयुग का साक्षात वैकुंठ, जो तिरुमाला की पवित्र शेषाचलम सप्तगिरि पहाड़ियों पर स्थापित विश्वविख्यात दिव्य धाम है।';
    } else if (lower.contains('siddhivinayak') || lower.contains('siddhi vinayak')) {
      nameHi = 'श्री सिद्धिविनायक मंदिर';
      deityHi = 'भगवान श्री गणेश';
      cityHi = 'मुंबई, महाराष्ट्र';
      descHi = 'नवसाचा गणपति का पावन सिद्ध पीठ, जहाँ भक्तों की समस्त मनोकामनाएं पूर्ण होती हैं और सब विघ्न दूर होते हैं।';
    } else if (lower.contains('mahakal') || lower.contains('ujjain')) {
      nameHi = 'श्री महाकालेश्वर ज्योतिर्लिंग';
      deityHi = 'भगवान शिव (महाकाल)';
      cityHi = 'उज्जैन, मध्य प्रदेश';
      descHi = 'विश्व का अद्वितीय दक्षिणमुखी ज्योतिर्लिंग, जो भस्म आरती और काल के अधिपति महाकाल के रूप में विश्वप्रसिद्ध है।';
    } else if (lower.contains('vaishno') || lower.contains('katra')) {
      nameHi = 'माँ वैष्णो देवी मंदिर';
      deityHi = 'माँ वैष्णो देवी';
      cityHi = 'कटरा, जम्मू और कश्मीर';
      descHi = 'त्रिकूट पर्वत की पवित्र प्राकृतिक गुफा में स्थित महाकाली, महालक्ष्मी और महासरस्वती का साक्षात दिव्य संगम धाम।';
    } else if (lower.contains('somnath') || lower.contains('patan') || lower.contains('veraval')) {
      nameHi = 'श्री सोमनाथ ज्योतिर्लिंग मंदिर';
      deityHi = 'भगवान शिव';
      cityHi = 'प्रभात पाटन, गुजरात';
      descHi = 'द्वादश ज्योतिर्लिंगों में सर्वप्रथम प्रतिष्ठित पावन धाम, जो अरब सागर के तट पर अनादि काल से सुशोभित है।';
    } else if (lower.contains('baglamukhi') || lower.contains('बगलामुखी')) {
      nameHi = 'सिद्धपीठ श्री बगलामुखी मंदिर';
      deityHi = 'श्री बगलामुखी माता जी';
      cityHi = 'बागली, पंडोह, हिमाचल प्रदेश';
      descHi = 'माँ पीतांबरा बगलामुखी का सिद्ध धाम, जहाँ पूजन से शत्रु बाधा, कानूनी विवाद एवं असाध्य संकटों का शमन होता है।';
    } else {
      if (nameHi.isEmpty) nameHi = rawName;
      if (deityHi.isEmpty) deityHi = localizeDeity(rawDeity, true);
      if (cityHi.isEmpty) cityHi = localizeLocation(combinedCity, true);
      if (descHi.isEmpty) descHi = rawDesc;
    }

    // Localize Aartis
    final localizedAartis = rawAartis.map((a) {
      if (a is Map) {
        final aName = a['name']?.toString() ?? '';
        String localizedName = aName;
        if (aName.toLowerCase().contains('mangala')) localizedName = 'मंगला';
        else if (aName.toLowerCase().contains('suprabhatam')) localizedName = 'सुप्रभातम्';
        else if (aName.toLowerCase().contains('kakad')) localizedName = 'काकड़ आरती';
        else if (aName.toLowerCase().contains('bhasma')) localizedName = 'भस्म आरती';
        else if (aName.toLowerCase().contains('bhog')) localizedName = 'भोग आरती';
        else if (aName.toLowerCase().contains('sandhya')) localizedName = 'संध्या आरती';
        else if (aName.toLowerCase().contains('shringar')) localizedName = 'श्रृंगार आरती';
        else if (aName.toLowerCase().contains('shejarati')) localizedName = 'शेजारती';
        else if (aName.toLowerCase().contains('morning')) localizedName = 'प्रातः आरती';
        return {
          ...a,
          'name': localizedName,
        };
      }
      return a;
    }).toList();

    return {
      ...raw,
      'name': nameHi,
      'deity': deityHi,
      'city': cityHi,
      'description': descHi,
      'aartis': localizedAartis,
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PUJAS LOCALIZER
  // ─────────────────────────────────────────────────────────────────────────
  static Map<String, dynamic> localizePuja(Map<String, dynamic> raw, bool isHi) {
    final rawTitle = raw['title']?.toString() ?? raw['name']?.toString() ?? 'Vedic Puja';
    final rawMandir = raw['temple_name']?.toString() ?? raw['mandir']?.toString() ?? 'Temple Sanctum';
    final rawDesc = raw['description']?.toString() ?? raw['subtitle']?.toString() ?? '';
    final rawCat = raw['category']?.toString() ?? 'All';

    if (!isHi) {
      return {
        ...raw,
        'title': rawTitle,
        'subtitle': rawDesc,
        'mandir': rawMandir,
        'date': raw['date'] ?? 'Daily Auspicious Muhurat',
        'badge': raw['badge'] ?? (raw['is_popular'] == true ? 'Most Popular' : 'Special Seva'),
      };
    }

    final lower = (rawTitle + ' ' + rawMandir).toLowerCase();

    String titleHi = '';
    String descHi = '';
    String mandirHi = '';
    String catHi = '';

    if (lower.contains('rudrabhishek') || lower.contains('rudra')) {
      titleHi = 'गंगाजल से महा रुद्राभिषेक';
      descHi = 'गंगाजल, गाय के दूध, शहद, पंचामृत और बेलपत्र से शिवलिंग का निरंतर अभिषेक करते हुए श्री रुद्रम का पावन वैदिक पाठ।';
      mandirHi = 'श्री काशी विश्वनाथ मंदिर';
      catHi = 'रुद्र व स्वास्थ्य';
    } else if (lower.contains('siddhivinayak') || lower.contains('sankashti') || lower.contains('ganesha') || lower.contains('homam')) {
      titleHi = 'सिद्धिविनायक संकष्टी होम';
      descHi = 'व्यापार, शिक्षा और करियर की बाधाओं को दूर करने हेतु 108 मोदक, दूर्वा और नारियल के साथ भगवान गणेश का पावन हवन।';
      mandirHi = 'श्री सिद्धिविनायक मंदिर';
      catHi = 'विघ्नहर्ता पूजा';
    } else if (lower.contains('kalyanotsavam') || lower.contains('sahasranama') || lower.contains('balaji') || lower.contains('venkateswara')) {
      titleHi = 'सहस्रनाम अर्चना एवं कल्याणोत्सवम्';
      descHi = 'सुगंधित तुलसी व कमल पुष्पों से 1000 दिव्य नामों का अर्चना पाठ तथा पारिवारिक समृद्धि हेतु भगवान वेंकटेश्वर का कल्याणोत्सव।';
      mandirHi = 'श्री तिरुपति बालाजी';
      catHi = 'सुख-समृद्धि';
    } else if (lower.contains('kaal sarp') || lower.contains('kalsarp') || lower.contains('dosha')) {
      titleHi = 'कालसर्प दोष निवारण एवं शांति महापूजा';
      descHi = 'चांदी के नाग-नागिन जोड़े, विशेष नवग्रह आहुति और मंत्र जाप द्वारा राहु-केतु व कालसर्प दोष का वैदिक शमन।';
      mandirHi = 'श्री महाकालेश्वर ज्योतिर्लिंग';
      catHi = 'दोष निवारण';
    } else if (lower.contains('chandi') || lower.contains('durga') || lower.contains('vaishno')) {
      titleHi = 'चंडी पाठ एवं शतचंडी महायज्ञ';
      descHi = 'दुर्गा सप्तशती के 700 श्लोकों का संपूर्ण पाठ एवं नकारात्मक ऊर्जा तथा शत्रुओं से सुरक्षा हेतु शतचंडी महायज्ञ।';
      mandirHi = 'माँ वैष्णो देवी मंदिर';
      catHi = 'रक्षा व विजय';
    } else if (lower.contains('navgrah') || lower.contains('navagraha') || lower.contains('somnath')) {
      titleHi = 'नवग्रह शांति महाहवन एवं जाप';
      descHi = 'जीवन में शांति, सफलता, मानसिक संतुलन और आध्यात्मिक प्रगति हेतु नवों ग्रहों का वैदिक शांति हवन।';
      mandirHi = 'श्री सोमनाथ ज्योतिर्लिंग मंदिर';
      catHi = 'नवग्रह शांति';
    } else if (lower.contains('baglamukhi') || lower.contains('बगलामुखी')) {
      titleHi = 'श्री बगलामुखी शत्रु बाधा विनाशक महायज्ञ';
      descHi = 'कोर्ट-कचहरी, शत्रु बाधा, कानूनी विवाद व नज़र दोष से मुक्ति हेतु माँ बगलामुखी का पीतांबरा महायज्ञ।';
      mandirHi = 'सिद्धपीठ श्री बगलामुखी मंदिर';
      catHi = 'शत्रु बाधा निवारण';
    } else {
      titleHi = raw['title_hi']?.toString() ?? rawTitle;
      descHi = raw['subtitle_hi']?.toString() ?? raw['description_hi']?.toString() ?? rawDesc;
      mandirHi = raw['mandir_hi']?.toString() ?? localizeLocation(rawMandir, true);
      catHi = rawCat;
    }

    return {
      ...raw,
      'title': titleHi,
      'title_hi': titleHi,
      'subtitle': descHi,
      'subtitle_hi': descHi,
      'mandir': mandirHi,
      'mandir_hi': mandirHi,
      'category': catHi,
      'date': 'दैनिक शुभ मुहूर्त',
      'date_hi': 'दैनिक शुभ मुहूर्त',
      'badge': raw['is_popular'] == true ? 'सर्वाधिक लोकप्रिय' : 'विशेष सेवा',
      'badge_hi': raw['is_popular'] == true ? 'सर्वाधिक लोकप्रिय' : 'विशेष सेवा',
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ASTROLOGERS LOCALIZER
  // ─────────────────────────────────────────────────────────────────────────
  static Map<String, dynamic> localizeAstrologer(Map<String, dynamic> raw, bool isHi) {
    var rawName = raw['name']?.toString() ?? 'Vedic Astrologer';
    rawName = rawName.replaceAll(RegExp(r'\bAI\b', caseSensitive: false), 'Vedic').trim();
    final rawSpecialties = raw['specialties']?.toString() ?? raw['specialities']?.toString() ?? 'Vedic Astrology';
    final rawLanguages = raw['languages']?.toString() ?? 'Hindi, English';
    final expNum = raw['expNumeric'] ?? 10;
    final reviewsCount = raw['reviews_count'] ?? raw['consultations_count'] ?? 1250;

    final id = raw['id']?.toString() ?? 'ast_${rawName.hashCode}';
    final num? rawRateNum = (raw['per_minute_chat_rate'] is num)
        ? (raw['per_minute_chat_rate'] as num)
        : num.tryParse(raw['per_minute_chat_rate']?.toString() ?? '');
    final int chatRate = (rawRateNum != null && rawRateNum >= 12 && rawRateNum <= 20)
        ? rawRateNum.toInt()
        : ((id.hashCode.abs() % 9) + 12);

    if (!isHi) {
      return {
        ...raw,
        'name': rawName,
        'badge': 'Top Rated',
        'specialties': rawSpecialties,
        'experience': '$expNum+ Years Experience',
        'languages': rawLanguages,
        'reviews': '($reviewsCount+ reviews)',
        'onlineText': 'Online',
        'guidanceText': '₹$chatRate/min',
        'price': '₹$chatRate/min',
        'priceNumeric': chatRate,
        'chatRate': chatRate,
        'chatText': 'Chat',
      };
    }

    final lower = rawName.toLowerCase();

    String nameHi = rawName;
    String specHi = rawSpecialties;
    String langHi = rawLanguages;

    if (lower.contains('jagannath rath')) {
      nameHi = 'पं. जगन्नाथ रथ';
      specHi = 'वैदिक रत्न विज्ञान, रत्न प्राण प्रतिष्ठा, नवग्रह स्तोत्र';
      langHi = 'उड़िया, हिन्दी, अंग्रेज़ी';
    } else if (lower.contains('prakash chandra')) {
      nameHi = 'आचार्य प्रकाश चंद्र शर्मा';
      specHi = 'राज योग, विपरीत राज योग, पंच महापुरुष योग';
      langHi = 'हिन्दी, राजस्थानी, अंग्रेज़ी';
    } else if (lower.contains('omprakash chaubey') || lower.contains('chaubey')) {
      nameHi = 'पं. ओमप्रकाश चौबे';
      specHi = 'वराहमिहिर संहिता, मौसम व विवाह ज्योतिष';
      langHi = 'हिन्दी, संस्कृत, अंग्रेज़ी';
    } else if (lower.contains('pranavananda')) {
      nameHi = 'स्वामी प्रणवानंद';
      specHi = 'मानसिक शांति, आध्यात्मिक जागृति, ध्यान साधना';
      langHi = 'हिन्दी, अंग्रेज़ी, संस्कृत';
    } else if (lower.contains('ramanuj')) {
      nameHi = 'आचार्य रामानुज शास्त्री';
      specHi = 'वैदिक ज्योतिष, कुंडली मिलान, करियर ज्योतिष, रत्न परामर्श';
      langHi = 'हिन्दी, संस्कृत, अंग्रेज़ी';
    } else if (lower.contains('radhika')) {
      nameHi = 'डॉ. राधिका वशिष्ठ';
      specHi = 'टैरो रीडिंग, संबंध मार्गदर्शन, अंक ज्योतिष, एंजल हीलिंग';
      langHi = 'अंग्रेज़ी, हिन्दी, पंजाबी';
    } else if (lower.contains('brijesh')) {
      nameHi = 'पं. बृजेश नारायण शुक्ल';
      specHi = 'प्रश्न कुंडली, नाड़ी ज्योतिष, मुहूर्त चयन, कालसर्प दोष';
      langHi = 'हिन्दी, गुजराती, मराठी';
    } else if (lower.contains('ananya')) {
      nameHi = 'श्रीमती अनन्या मुखर्जी';
      specHi = 'वास्तु शास्त्र, हस्तरेखा, व्यावसायिक वास्तु';
      langHi = 'बंगाली, हिन्दी, अंग्रेज़ी';
    } else if (lower.contains('devanand')) {
      nameHi = 'स्वामी देवानंद सरस्वती';
      specHi = 'आध्यात्मिक परामर्श, मंत्र साधना, ध्यान साधना';
      langHi = 'हिन्दी, अंग्रेज़ी';
    } else if (lower.contains('devavrat')) {
      nameHi = 'आचार्य देवव्रत उपाध्याय';
      specHi = 'केपी ज्योतिष, शुभ मुहूर्त, गृह प्रवेश';
      langHi = 'हिन्दी, अंग्रेज़ी, मैथिली';
    } else if (lower.contains('harishchandra')) {
      nameHi = 'डॉ. हरिश्चंद्र जोशी';
      specHi = 'वैदिक ज्योतिष, अंक ज्योतिष, करियर मार्गदर्शन';
      langHi = 'हिन्दी, अंग्रेज़ी, मराठी';
    } else if (lower.contains('kameshwar')) {
      nameHi = 'पं. कामेश्वर नाथ त्रिपाठी';
      specHi = 'चिकित्सा ज्योतिष, आयुर्-ज्योतिष, दोष निवारण';
      langHi = 'हिन्दी, संस्कृत, भोजपुरी';
    } else if (lower.contains('chandrashekhar')) {
      nameHi = 'डॉ. चंद्रशेखर अय्यर';
      specHi = 'नाड़ी ज्योतिष, अगस्त्य नाड़ी, पूर्व जन्म कर्म';
      langHi = 'तमिल, अंग्रेज़ी, हिन्दी';
    } else {
      // General name prefixes
      nameHi = nameHi
          .replaceAll('Pt.', 'पं.')
          .replaceAll('Dr.', 'डॉ.')
          .replaceAll('Acharya', 'आचार्य')
          .replaceAll('Swami', 'स्वामी')
          .replaceAll('Smt.', 'श्रीमती');

      // General specialty translations
      specHi = specHi
          .replaceAll('Vedic Astrology', 'वैदिक ज्योतिष')
          .replaceAll('Kundli Matching', 'कुंडली मिलान')
          .replaceAll('Kundli Analysis', 'कुंडली विश्लेषण')
          .replaceAll('Career Astrology', 'करियर ज्योतिष')
          .replaceAll('Gemstone Consultation', 'रत्न परामर्श')
          .replaceAll('Tarot Reading', 'टैरो रीडिंग')
          .replaceAll('Numerology', 'अंक ज्योतिष')
          .replaceAll('Vastu Shastra', 'वास्तु शास्त्र')
          .replaceAll('Prashna Kundli', 'प्रश्न कुंडली')
          .replaceAll('Palmistry', 'हस्तरेखा')
          .replaceAll('Meditation', 'ध्यान साधना')
          .replaceAll('Spiritual Counseling', 'आध्यात्मिक परामर्श')
          .replaceAll('Spiritual Awakening', 'आध्यात्मिक जागृति')
          .replaceAll('Mind Detoxification', 'मानसिक शांति')
          .replaceAll('Horary Astrology', 'प्रश्न शास्त्र')
          .replaceAll('Muhurat Selection', 'मुहूर्त चयन')
          .replaceAll('Vedic Gemology', 'वैदिक रत्न विज्ञान')
          .replaceAll('Ratna Prana Pratishtha', 'रत्न प्राण प्रतिष्ठा')
          .replaceAll('Raj Yoga', 'राज योग')
          .replaceAll('Vipreet Raj Yoga', 'विपरीत राज योग')
          .replaceAll('Pancha Mahapurusha', 'पंच महापुरुष योग')
          .replaceAll('Varahamihira Samhita', 'वराहमिहिर संहिता');

      // General language translations
      langHi = langHi
          .replaceAll('Hindi', 'हिन्दी')
          .replaceAll('English', 'अंग्रेज़ी')
          .replaceAll('Sanskrit', 'संस्कृत')
          .replaceAll('Odia', 'उड़िया')
          .replaceAll('Punjabi', 'पंजाबी')
          .replaceAll('Gujarati', 'गुजराती')
          .replaceAll('Marathi', 'मराठी')
          .replaceAll('Bengali', 'बंगाली')
          .replaceAll('Tamil', 'तमिल')
          .replaceAll('Telugu', 'तेलुगू')
          .replaceAll('Bhojpuri', 'भोजपुरी')
          .replaceAll('Maithili', 'मैथिली')
          .replaceAll('Rajasthani', 'राजस्थानी');
    }

    return {
      ...raw,
      'name': nameHi,
      'badge': 'शीर्ष ज्योतिषी',
      'specialties': specHi,
      'experience': '$expNum+ वर्ष अनुभव',
      'languages': langHi,
      'reviews': '($reviewsCount+ समीक्षाएं)',
      'onlineText': 'ऑनलाइन',
      'guidanceText': '₹$chatRate/मिनट',
      'price': '₹$chatRate/मिनट',
      'priceNumeric': chatRate,
      'chatRate': chatRate,
      'chatText': 'चैट',
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CHADHAWA OFFERINGS LOCALIZER
  // ─────────────────────────────────────────────────────────────────────────
  static Map<String, dynamic> localizeChadhawa(Map<String, dynamic> raw, bool isHi) {
    final rawTitle = raw['title']?.toString() ?? 'Divine Chadava Offering';
    final rawLoc = raw['temple_name']?.toString() ?? raw['location']?.toString() ?? 'Sacred Temple';

    if (!isHi) {
      return {
        ...raw,
        'title': rawTitle,
        'location': rawLoc,
        'badge': 'Most Popular',
      };
    }

    final lower = (rawTitle + ' ' + rawLoc).toLowerCase();

    String titleHi = '';
    String locHi = '';

    if (lower.contains('bilva') || lower.contains('silver')) {
      titleHi = 'शुद्ध चांदी का बेलपत्र (शिव अर्पण)';
      locHi = 'श्री काशी विश्वनाथ मंदिर';
    } else if (lower.contains('laddu') || lower.contains('tirupati') || lower.contains('mahapra')) {
      titleHi = 'तिरुपति लड्डू महाप्रसाद (श्रीवारी प्रसादम)';
      locHi = 'श्री तिरुपति बालाजी';
    } else if (lower.contains('modak') || lower.contains('garland')) {
      titleHi = '108 मोदक माला सेवा (गणपति अर्पण)';
      locHi = 'श्री सिद्धिविनायक मंदिर';
    } else if (lower.contains('jyoti') || lower.contains('ghee') || lower.contains('bhasma') || lower.contains('mahakal')) {
      titleHi = 'अखंड ज्योति एवं भस्म अर्पण';
      locHi = 'श्री महाकालेश्वर ज्योतिर्लिंग';
    } else if (lower.contains('chunri') || lower.contains('vaishno') || lower.contains('shringar')) {
      titleHi = 'पावन चुनरी एवं श्रृंगार भेंट';
      locHi = 'माँ वैष्णो देवी मंदिर';
    } else if (lower.contains('dhwaja') || lower.contains('somnath')) {
      titleHi = 'सोमनाथ महादेव ध्वजारोहण सेवा';
      locHi = 'श्री सोमनाथ ज्योतिर्लिंग मंदिर';
    } else if (lower.contains('baglamukhi') || lower.contains('बगलामुखी')) {
      titleHi = 'पीतांबरा पुष्प व पीत वस्त्र अर्पण';
      locHi = 'सिद्धपीठ श्री बगलामुखी मंदिर';
    } else {
      titleHi = raw['title_hi']?.toString() ?? rawTitle;
      locHi = raw['location_hi']?.toString() ?? localizeLocation(rawLoc, true);
    }

    return {
      ...raw,
      'title': titleHi,
      'title_hi': titleHi,
      'location': locHi,
      'location_hi': locHi,
      'badge': 'सर्वाधिक लोकप्रिय',
      'badge_hi': 'सर्वाधिक लोकप्रिय',
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STORE PRODUCTS LOCALIZER
  // ─────────────────────────────────────────────────────────────────────────
  static Map<String, dynamic> localizeProduct(Map<String, dynamic> raw, bool isHi) {
    final rawTitle = raw['name']?.toString() ?? raw['title']?.toString() ?? 'Sacred Item';
    final rawSub = raw['material']?.toString() ?? raw['subtitle']?.toString() ?? raw['category']?.toString() ?? 'Spiritual Item';
    final rawDesc = raw['description']?.toString() ?? '';

    if (!isHi) {
      return {
        ...raw,
        'title': rawTitle,
        'subtitle': rawSub,
        'description': rawDesc,
        'badge': raw['is_featured'] == true || raw['badge'] != null ? 'Bestseller' : null,
      };
    }

    final lower = (rawTitle + ' ' + rawSub).toLowerCase();

    String titleHi = '';
    String subHi = '';
    String descHi = '';

    if (lower.contains('sphatik') || lower.contains('shivling') || lower.contains('pran-pratishthit')) {
      titleHi = 'प्राण-प्रतिष्ठित स्फटिक शिवलिंग';
      subHi = '100% प्राकृतिक शुद्ध स्फटिक, मंत्र सिद्ध';
      descHi = '100% प्राकृतिक शुद्ध स्फटिक से निर्मित, वैदिक मंत्रों द्वारा अभिमंत्रित शिवलिंग। गृह शांति और सकारात्मक ऊर्जा हेतु सर्वोत्तम।';
    } else if (lower.contains('akhand') || lower.contains('diya') || lower.contains('brass')) {
      titleHi = 'रॉयल ब्रास अखंड दीया (कांच आवरण)';
      subHi = 'शुद्ध पीतल, नक्काशीदार व अखंड ज्योति';
      descHi = 'पारंपरिक नक्काशीदार भारी पीतल का अखंड दीया। काँच के आवरण सहित, जो निरंतर ज्योति प्रज्वलित रखने के लिए आदर्श है।';
    } else if (lower.contains('rudraksha') || lower.contains('mala') || lower.contains('5 mukhi')) {
      titleHi = 'सिद्ध 5-मुखी रुद्राक्ष माला (108+1 मनके)';
      subHi = 'प्रामाणिक नेपाली रुद्राक्ष, हरिद्वार सिद्ध';
      descHi = 'हरिद्वार गंगा तट पर वैदिक आचार्यों द्वारा प्राण प्रतिष्ठित 5 मुखी रुद्राक्ष माला। जाप एवं धारण हेतु अत्यंत शुभ।';
    } else if (lower.contains('gangajal') || lower.contains('kalash')) {
      titleHi = 'पावन काशी गंगाजल कलश (ताम्र पात्र)';
      subHi = 'मणिकर्णिका व दशाश्वमेध घाट का पावन जल';
      descHi = 'मणिकर्णिका व दशाश्वमेध घाट से शुद्ध संकलित पवित्र गंगाजल, तांबे के सीलबंद कलश में।';
    } else if (lower.contains('yantra') || lower.contains('navgrah')) {
      titleHi = 'सिद्ध नवग्रह यंत्र (शुद्ध ताम्र पट्टिका)';
      subHi = 'समस्त नवग्रह शांति व समृद्धि हेतु अभिमंत्रित';
      descHi = 'नवग्रहों के शुभ प्रभाव को जागृत करने वाला, तांबे की पट्टिका पर सूक्ष्म रूप से उत्कीर्ण वैदिक यंत्र।';
    } else if (lower.contains('dhoop') || lower.contains('agarbatti') || lower.contains('incense')) {
      titleHi = 'वैदिक प्रीमियम धूप व अगरबत्ती';
      subHi = 'प्राकृतिक जड़ी-बूटियों एवं शुद्ध गूगल-लोबान';
      descHi = 'कपूरकाचरी, नागरमोथा, जटामांसी, गूगल, लोबान व देसी घी युक्त पूर्णतः शुद्ध हवन व धूप सामग्री।';
    } else {
      titleHi = raw['title_hi']?.toString() ?? rawTitle;
      subHi = raw['subtitle_hi']?.toString() ?? rawSub;
      descHi = raw['description_hi']?.toString() ?? rawDesc;
    }

    return {
      ...raw,
      'title': titleHi,
      'title_hi': titleHi,
      'subtitle': subHi,
      'subtitle_hi': subHi,
      'description': descHi,
      'description_hi': descHi,
      'badge': raw['is_featured'] == true || raw['badge'] != null ? 'सर्वाधिक लोकप्रिय' : null,
      'badge_hi': raw['is_featured'] == true || raw['badge'] != null ? 'सर्वाधिक लोकप्रिय' : null,
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CATEGORIES MAPPER
  // ─────────────────────────────────────────────────────────────────────────
  static const Map<String, String> categoryMapHi = {
    'All': 'सभी',
    'All Mandirs': 'सभी मंदिर',
    'All Pujas': 'सभी पूजाएँ',
    'All Astrologers': 'सभी ज्योतिषी',
    'All Chadava': 'सभी चढ़ावा',
    'Lord Shiva': 'भगवान शिव',
    'Vishnu / Krishna': 'विष्णु / कृष्ण',
    'Maa Durga / Devi': 'माँ दुर्गा / शक्तिपीठ',
    'Maa Durga / Shakti': 'माँ दुर्गा / शक्तिपीठ',
    'Hanuman Ji': 'हनुमान जी',
    'Lord Hanuman': 'संकटमोचन हनुमान जी',
    'Lord Ganesha': 'भगवान गणेश',
    'Top Rated': 'शीर्ष ज्योतिषी',
    'Experience: High to Low': 'अनुभव: अधिक से कम',
    'Rating: High to Low': 'रेटिंग: अधिक से कम',
    'Price: Low to High': 'शुल्क: कम से अधिक',
    'Price: High to Low': 'शुल्क: अधिक से कम',
    'Love & Relationships': 'प्रेम व संबंध',
    'Career & Jobs': 'करियर व नौकरी',
    'Wealth & Prosperity': 'धन व समृद्धि',
    'Health': 'स्वास्थ्य व आरोग्य',
    'Home & Vastu': 'घर व वास्तु दोष',
    'Kundli Matching': 'कुंडली मिलान',
    'Kundli Analysis': 'कुंडली विश्लेषण',
    'Tarot Reading': 'टैरो रीडिंग',
    'Vastu Shastra': 'वास्तु शास्त्र',
    'Prashna Kundli': 'प्रश्न कुंडली',
    'Numerology': 'अंक ज्योतिष',
  };

  static String localizeCategory(String cat, bool isHi) {
    if (!isHi) return cat;
    return categoryMapHi[cat] ?? cat;
  }
}
