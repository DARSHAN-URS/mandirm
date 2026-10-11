import 'locale_service.dart';

/// Central bilingual string table for the Mandirm Astrologer App.
/// Matches the exact pattern of the Consumer App:
/// Usage: `AstroStrings.t('key')` or `LocaleService().isHindi ? '...' : '...'`
class AstroStrings {
  AstroStrings._();

  static String t(String key) {
    final lang = LocaleService().locale.value;
    final map = lang == LocaleService.hi ? _hi : _en;
    return map[key] ?? _en[key] ?? key;
  }

  // ─── English ─────────────────────────────────────────────────────────────
  static const Map<String, String> _en = {
    // Portal & Shell
    'app_name': 'Mandirm Acharya',
    'portal_title': 'VEDIC ACHARYA PORTAL',
    'portal_tag': 'JYOTISH ACHARYA',
    'connecting_cosmos': 'Connecting to Mandirm Cosmos...',

    // Bottom Navigation Bar
    'nav_duty': 'Duty Status',
    'nav_requests': 'Requests',
    'nav_history': 'History',
    'nav_earnings': 'Earnings',
    'nav_profile': 'Profile',

    // Duty Status / Availability
    'online': 'Online',
    'offline': 'Offline',
    'busy': 'Busy',
    'duty_online_msg': 'You are online & receiving devotees',
    'duty_offline_msg': 'You are offline (Not receiving devotees)',
    'go_online': 'Go Online',
    'go_offline': 'Go Offline',
    'status_online_badge': 'ONLINE FOR CONSULTATIONS',
    'status_offline_badge': 'CURRENTLY OFFLINE',
    'status_busy_badge': 'ENGAGED IN CONSULTATION',

    // Dashboard Hub
    'today_dakshina': 'Today\'s Dakshina',
    'wallet_balance': 'Wallet Balance',
    'today_minutes': 'Minutes Consulted',
    'today_consultations': 'Consultations Done',
    'devotee_rating': 'Devotee Rating',
    'active_queue': 'Active Devotee Queue',
    'waiting_devotees': 'devotees waiting in sacred queue',
    'no_active_queue': 'No devotees waiting in queue right now.',
    'recent_consultations': 'Recent Consultations',
    'view_all': 'View All',
    'accept': 'Accept & Connect',
    'pass': 'Pass Request',

    // Consultations Screen
    'requests_console': 'Requests Console',
    'requests_subtitle': 'Live consultations (Voice, Video, Chat) & Special service requests',
    'tab_consultations': 'Consultations',
    'tab_services': 'Service Requests',
    'live_queue_empty': 'Queue is currently clear. When devotees book audio/video or chat, requests appear here in real time.',
    'service_requests_empty': 'No special service or anushthan requests pending at this time.',
    'service_customer': 'Devotee',
    'service_type': 'Service',
    'service_date': 'Target Date',
    'service_dakshina': 'Dakshina Amount',
    'start_consultation': 'Start Consultation',
    'accept_booking': 'Accept Booking',

    // History Screen
    'history_title': 'Devotee Records & Kundlis',
    'history_subtitle': 'Past consultations, prescribed remedies & devotee reviews',
    'filter_all': 'All Records',
    'filter_voice': 'Voice Calls',
    'filter_video': 'Video Calls',
    'no_history': 'No consultation records found.',
    'mins': 'mins',
    'remedies_prescribed': 'Remedies Prescribed',

    // Earnings Screen
    'earnings_title': 'Sacred Dakshina & Settlements',
    'earnings_subtitle': 'Real-time earnings, completed sessions & bank payouts',
    'sacred_dakshina_balance': 'Sacred Dakshina Balance',
    'instant_withdrawal': 'Withdraw Funds',
    'today_settlement': 'Today\'s Earnings',
    'completed_sessions': 'Completed Sessions',
    'bank_account': 'Bank Payout Account',
    'payout_history': 'Settlement History',
    'settled': 'Settled',
    'processing': 'Processing',
    'request_withdrawal_title': 'Withdraw Dakshina to Bank',
    'confirm_withdrawal': 'Confirm & Transfer',

    // Profile Screen
    'profile_title': 'Acharya Profile & Account',
    'kyc_verified': 'KYC VERIFIED',
    'edit_profile': 'Edit Profile',
    'specialities': 'Specialities & Expertise',
    'languages': 'Languages Spoken',
    'consultation_rates': 'Consultation Dakshina Rates',
    'voice_call_rate': 'Voice Call Rate',
    'video_call_rate': 'Video Call Rate',
    'chat_rate': 'Chat Rate',
    'per_min': '/min',
    'ashram_certs': 'Ashram & Vedic Certifications',
    'mandirm_partner': 'Mandirm Certified Vedic Astrologer',
    'partner_sub': 'Verified credentials, authenticated horoscope reading protocols & sacred ethics standard.',
    'sign_out': 'Sign Out from Portal',
    'sign_out_confirm': 'Are you sure you want to sign out from the Acharya Portal?',
    'cancel': 'Cancel',

    // Drawer Menu
    'drawer_acharya_hub': 'Acharya Console & Duty',
    'drawer_duty_title': 'Duty Status & Live Console',
    'drawer_duty_sub': 'Toggle online availability & quick queue',
    'drawer_requests_title': 'Incoming Devotee Requests',
    'drawer_requests_sub': 'Audio, Video & Chat booking requests',
    'drawer_history_title': 'Devotee Kundli History',
    'drawer_history_sub': 'Past sessions & prescribed remedies',
    'drawer_earnings_title': 'Sacred Dakshina & Wallet',
    'drawer_earnings_sub': 'View daily earnings & bank payouts',
    'drawer_profile_title': 'Acharya Profile Settings',
    'drawer_profile_sub': 'Manage rates, bio, languages & certificates',
    'drawer_notifications_title': 'Notifications & Alerts',
    'drawer_notifications_sub': 'Booking updates & devotee alerts',
    'drawer_support_title': 'Acharya Support Helpline',
    'drawer_support_sub': '24x7 Mandirm Astrologer Desk',
    'drawer_sign_out_title': 'Sign Out Console',
    'drawer_sign_out_sub': 'Securely exit your session',

    // Auth Screen
    'acharya_signin_title': 'Acharya Sign In',
    'acharya_signin_sub': 'Sign in to access your devotee requests, live consultations & dakshina ledger.',
    'email_label': 'Astrologer Email Address',
    'email_hint': 'acharya@mandirm.in',
    'send_code': 'Send Verification Code',
    'or_continue_with': 'OR CONTINUE WITH',
    'google_signin': 'Continue with Google',
  };

  // ─── Hindi ───────────────────────────────────────────────────────────────
  static const Map<String, String> _hi = {
    // Portal & Shell
    'app_name': 'मंदिरम् आचार्य',
    'portal_title': 'वैदिक आचार्य पोर्टल',
    'portal_tag': 'ज्योतिष आचार्य',
    'connecting_cosmos': 'मंदिरम् ब्रह्मांड से जुड़ रहे हैं...',

    // Bottom Navigation Bar
    'nav_duty': 'ड्यूटी स्थिति',
    'nav_requests': 'परामर्श कतार',
    'nav_history': 'इतिहास',
    'nav_earnings': 'दक्षिणा आय',
    'nav_profile': 'प्रोफ़ाइल',

    // Duty Status / Availability
    'online': 'ऑनलाइन',
    'offline': 'ऑफलाइन',
    'busy': 'व्यस्त',
    'duty_online_msg': 'आप ऑनलाइन हैं और भक्त आपसे जुड़ सकते हैं',
    'duty_offline_msg': 'आप ऑफलाइन हैं (भक्त कॉल नहीं कर सकते)',
    'go_online': 'ऑनलाइन हों',
    'go_offline': 'ऑफलाइन हों',
    'status_online_badge': 'परामर्श हेतु ऑनलाइन उपलब्ध',
    'status_offline_badge': 'वर्तमान में ऑफलाइन',
    'status_busy_badge': 'परामर्श में व्यस्त',

    // Dashboard Hub
    'today_dakshina': 'आज की दक्षिणा',
    'wallet_balance': 'वॉलेट शेष',
    'today_minutes': 'परामर्श समय',
    'today_consultations': 'संपन्न परामर्श',
    'devotee_rating': 'भक्त रेटिंग',
    'active_queue': 'प्रतीक्षारत भक्त कतार',
    'waiting_devotees': 'भक्त पवित्र कतार में प्रतीक्षारत हैं',
    'no_active_queue': 'वर्तमान में कतार में कोई भक्त प्रतीक्षारत नहीं है।',
    'recent_consultations': 'हाल के परामर्श',
    'view_all': 'सभी देखें',
    'accept': 'स्वीकार करें व जुड़ें',
    'pass': 'अनुरोध छोड़ें',

    // Consultations Screen
    'requests_console': 'परामर्श कतार कंसोल',
    'requests_subtitle': 'लाइव परामर्श (ऑडियो, वीडियो, चैट) व विशेष अनुष्ठान अनुरोध',
    'tab_consultations': 'लाइव परामर्श',
    'tab_services': 'सेवा अनुरोध',
    'live_queue_empty': 'कतार वर्तमान में रिक्त है। जब भक्त ऑडियो/वीडियो या चैट बुक करेंगे, अनुरोध यहाँ तुरंत दिखाई देंगे।',
    'service_requests_empty': 'इस समय कोई विशेष सेवा या अनुष्ठान अनुरोध लंबित नहीं है।',
    'service_customer': 'भक्त',
    'service_type': 'सेवा',
    'service_date': 'निर्धारित तिथि',
    'service_dakshina': 'दक्षिणा राशि',
    'start_consultation': 'परामर्श शुरू करें',
    'accept_booking': 'बुकिंग स्वीकार करें',

    // History Screen
    'history_title': 'भक्त विवरण व कुंडलियां',
    'history_subtitle': 'पूर्व परामर्श, सुझाए गए वैदिक उपाय व भक्त समीक्षाएं',
    'filter_all': 'सभी रिकॉर्ड',
    'filter_voice': 'वॉइस कॉल',
    'filter_video': 'वीडियो कॉल',
    'no_history': 'कोई परामर्श रिकॉर्ड उपलब्ध नहीं है।',
    'mins': 'मिनट',
    'remedies_prescribed': 'सुझाए गए वैदिक उपाय',

    // Earnings Screen
    'earnings_title': 'पवित्र दक्षिणा व बैंक भुगतान',
    'earnings_subtitle': 'दैनिक आय, संपन्न परामर्श सत्र व बैंक ट्रांसफर विवरण',
    'sacred_dakshina_balance': 'पवित्र दक्षिणा शेष',
    'instant_withdrawal': 'बैंक में ट्रांसफर करें',
    'today_settlement': 'आज की कुल दक्षिणा',
    'completed_sessions': 'संपन्न सत्र',
    'bank_account': 'पंजीकृत बैंक खाता',
    'payout_history': 'भुगतान इतिहास',
    'settled': 'सफल ट्रांसफर',
    'processing': 'प्रक्रियाधीन',
    'request_withdrawal_title': 'बैंक खाते में दक्षिणा निकासी',
    'confirm_withdrawal': 'पुष्टि करें और ट्रांसफर करें',

    // Profile Screen
    'profile_title': 'आचार्य प्रोफ़ाइल व खाता',
    'kyc_verified': 'KYC सत्यापित',
    'edit_profile': 'प्रोफ़ाइल बदलें',
    'specialities': 'विशेषज्ञता व ज्ञान',
    'languages': 'भाषा ज्ञान',
    'consultation_rates': 'परामर्श दक्षिणा दर',
    'voice_call_rate': 'वॉइस कॉल दर',
    'video_call_rate': 'वीडियो कॉल दर',
    'chat_rate': 'चैट दर',
    'per_min': '/मिनट',
    'ashram_certs': 'आश्रम व वैदिक प्रमाणपत्र',
    'mandirm_partner': 'मंदिरम् प्रमाणित वैदिक ज्योतिषी',
    'partner_sub': 'सत्यापित साख, शास्त्रोक्त कुंडली विश्लेषण और पवित्र वैदिक आचार संहिता।',
    'sign_out': 'पोर्टल से लॉग आउट करें',
    'sign_out_confirm': 'क्या आप निश्चित रूप से आचार्य पोर्टल से लॉग आउट करना चाहते हैं?',
    'cancel': 'रद्द करें',

    // Drawer Menu
    'drawer_acharya_hub': 'आचार्य कंसोल व ड्यूटी',
    'drawer_duty_title': 'ड्यूटी स्थिति व लाइव कंसोल',
    'drawer_duty_sub': 'ऑनलाइन उपलब्धता और त्वरित कतार टॉगल करें',
    'drawer_requests_title': 'आगामी भक्त परामर्श अनुरोध',
    'drawer_requests_sub': 'ऑडियो, वीडियो और चैट बुकिंग अनुरोध',
    'drawer_history_title': 'भक्त कुंडली इतिहास',
    'drawer_history_sub': 'विगत परामर्श सत्र व सुझाए गए उपाय',
    'drawer_earnings_title': 'पवित्र दक्षिणा व वॉलेट',
    'drawer_earnings_sub': 'दैनिक दक्षिणा आय व बैंक ट्रांसफर देखें',
    'drawer_profile_title': 'आचार्य प्रोफ़ाइल सेटिंग्स',
    'drawer_profile_sub': 'दक्षिणा दरें, परिचय, भाषाएं व प्रमाणपत्र प्रबंधित करें',
    'drawer_notifications_title': 'सूचनाएं व अलर्ट',
    'drawer_notifications_sub': 'बुकिंग अपडेट और भक्त संदेश',
    'drawer_support_title': 'आचार्य सहायता हेल्पलाइन',
    'drawer_support_sub': '24x7 मंदिरम् ज्योतिषी सहायता केंद्र',
    'drawer_sign_out_title': 'लॉग आउट कंसोल',
    'drawer_sign_out_sub': 'वर्तमान सत्र सुरक्षित समाप्त करें',

    // Auth Screen
    'acharya_signin_title': 'आचार्य प्रवेश (साइन इन)',
    'acharya_signin_sub': 'भक्त अनुरोध, लाइव परामर्श और दक्षिणा खाता देखने के लिए साइन इन करें।',
    'email_label': 'ज्योतिषी ईमेल आईडी',
    'email_hint': 'acharya@mandirm.in',
    'send_code': 'सत्यापन कोड भेजें',
    'or_continue_with': 'अथवा इसके साथ जारी रखें',
    'google_signin': 'Google से साइन इन करें',
  };
}
