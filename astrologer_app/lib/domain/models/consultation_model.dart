class DevoteeConsultationRequest {
  final String id;
  final String devoteeName;
  final String devoteePhoto;
  final String devoteeGotra;
  final String devoteeRashi;
  final String birthDob;
  final String birthTime;
  final String birthPlace;
  final String problemTopic;
  final String type; // voice, video, chat
  final double perMinuteRate;
  final String callRoomId;
  final String callToken;
  final DateTime requestedAt;

  DevoteeConsultationRequest({
    required this.id,
    required this.devoteeName,
    required this.devoteePhoto,
    required this.devoteeGotra,
    required this.devoteeRashi,
    required this.birthDob,
    required this.birthTime,
    required this.birthPlace,
    required this.problemTopic,
    required this.type,
    required this.perMinuteRate,
    required this.callRoomId,
    required this.callToken,
    required this.requestedAt,
  });

  static List<DevoteeConsultationRequest> get mockQueue => [
    DevoteeConsultationRequest(
      id: "req_001",
      devoteeName: "Rajeshwar Sharma",
      devoteePhoto: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80",
      devoteeGotra: "Kashyap",
      devoteeRashi: "Mesh (Aries)",
      birthDob: "14 Oct 1992",
      birthTime: "06:45 AM",
      birthPlace: "Varanasi, UP",
      problemTopic: "Government Job & Career Prospects",
      type: "video",
      perMinuteRate: 35.0,
      callRoomId: "room_kashi_882",
      callToken: "rtc_sample_token_882",
      requestedAt: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    DevoteeConsultationRequest(
      id: "req_002",
      devoteeName: "Priyanka Mishra",
      devoteePhoto: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80",
      devoteeGotra: "Bharadwaja",
      devoteeRashi: "Kanya (Virgo)",
      birthDob: "22 Aug 1996",
      birthTime: "11:15 PM",
      birthPlace: "Jaipur, Rajasthan",
      problemTopic: "Kundli Matching & Marriage Muhurat",
      type: "voice",
      perMinuteRate: 30.0,
      callRoomId: "room_jaipur_419",
      callToken: "rtc_sample_token_419",
      requestedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    DevoteeConsultationRequest(
      id: "req_003",
      devoteeName: "Amitabh Verma",
      devoteePhoto: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80",
      devoteeGotra: "Vashishta",
      devoteeRashi: "Dhanu (Sagittarius)",
      birthDob: "03 Dec 1988",
      birthTime: "02:30 PM",
      birthPlace: "Patna, Bihar",
      problemTopic: "Business Expansion & Saturn Sade Sati",
      type: "chat",
      perMinuteRate: 25.0,
      callRoomId: "room_patna_102",
      callToken: "rtc_sample_token_102",
      requestedAt: DateTime.now().subtract(const Duration(minutes: 9)),
    ),
  ];
}

class EarningsSummary {
  final double todayEarnings;
  final int todayMinutes;
  final int todayConsultations;
  final double walletBalance;
  final double rating;

  EarningsSummary({
    required this.todayEarnings,
    required this.todayMinutes,
    required this.todayConsultations,
    required this.walletBalance,
    required this.rating,
  });

  static EarningsSummary get mockData => EarningsSummary(
    todayEarnings: 2450.0,
    todayMinutes: 82,
    todayConsultations: 6,
    walletBalance: 18750.0,
    rating: 4.92,
  );
}

class PastConsultation {
  final String id;
  final String devoteeName;
  final String type;
  final int durationMinutes;
  final double amount;
  final String timeAgo;
  final double rating;
  final String feedback;

  PastConsultation({
    required this.id,
    required this.devoteeName,
    required this.type,
    required this.durationMinutes,
    required this.amount,
    required this.timeAgo,
    required this.rating,
    required this.feedback,
  });

  static List<PastConsultation> get mockHistory => [
    PastConsultation(
      id: "hist_1",
      devoteeName: "Ananya Iyer",
      type: "video",
      durationMinutes: 18,
      amount: 630.0,
      timeAgo: "45 mins ago",
      rating: 5.0,
      feedback: "Guruji gave immense clarity on my career path. Very accurate remedies!",
    ),
    PastConsultation(
      id: "hist_2",
      devoteeName: "Kunal Deshmukh",
      type: "voice",
      durationMinutes: 12,
      amount: 360.0,
      timeAgo: "2 hours ago",
      rating: 4.8,
      feedback: "Answered all my questions patiently with precise Vedic timing.",
    ),
    PastConsultation(
      id: "hist_3",
      devoteeName: "Sunita Agarwal",
      type: "chat",
      durationMinutes: 24,
      amount: 600.0,
      timeAgo: "Yesterday",
      rating: 5.0,
      feedback: "Detailed Kundli chart analysis for my son's wedding.",
    ),
  ];
}
