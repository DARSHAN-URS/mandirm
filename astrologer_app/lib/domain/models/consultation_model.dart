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

  factory DevoteeConsultationRequest.fromJson(Map<String, dynamic> json) {
    DateTime reqAt = DateTime.now();
    if (json['created_at'] != null) {
      try {
        reqAt = DateTime.parse(json['created_at'].toString());
      } catch (_) {}
    }
    return DevoteeConsultationRequest(
      id: json['id']?.toString() ?? '',
      devoteeName: json['user_name']?.toString() ?? json['devotee_name']?.toString() ?? 'Devotee',
      devoteePhoto: json['user_photo']?.toString() ??
          json['devotee_photo']?.toString() ??
          "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80",
      devoteeGotra: json['user_gotra']?.toString() ?? json['devotee_gotra']?.toString() ?? 'Kashyap',
      devoteeRashi: json['user_rashi']?.toString() ?? json['devotee_rashi']?.toString() ?? 'Mesh (Aries)',
      birthDob: json['birth_dob']?.toString() ?? '14 Oct 1992',
      birthTime: json['birth_time']?.toString() ?? '06:45 AM',
      birthPlace: json['birth_place']?.toString() ?? 'Varanasi, UP',
      problemTopic: json['problem_topic']?.toString() ?? json['notes']?.toString() ?? 'Vedic Guidance',
      type: json['type']?.toString() ?? 'voice',
      perMinuteRate: (json['per_minute_rate'] as num?)?.toDouble() ?? 30.0,
      callRoomId: json['call_room_id']?.toString() ?? 'mandirm_room_${json['id']}',
      callToken: json['call_token']?.toString() ?? 'rtc_token_${json['id']}',
      requestedAt: reqAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'devotee_name': devoteeName,
    'devotee_photo': devoteePhoto,
    'devotee_gotra': devoteeGotra,
    'devotee_rashi': devoteeRashi,
    'birth_dob': birthDob,
    'birth_time': birthTime,
    'birth_place': birthPlace,
    'problem_topic': problemTopic,
    'type': type,
    'per_minute_rate': perMinuteRate,
    'call_room_id': callRoomId,
    'call_token': callToken,
    'created_at': requestedAt.toIso8601String(),
  };

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

  factory EarningsSummary.fromJson(Map<String, dynamic> json) {
    return EarningsSummary(
      todayEarnings: (json['total_earned'] as num?)?.toDouble() ??
          (json['today_earnings'] as num?)?.toDouble() ??
          2450.0,
      todayMinutes: (json['today_minutes'] as num?)?.toInt() ?? 82,
      todayConsultations: (json['completed_consultations'] as num?)?.toInt() ??
          (json['today_consultations'] as num?)?.toInt() ??
          6,
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 18750.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.92,
    );
  }

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
  final String devoteePhoto;
  final String type;
  final int durationMinutes;
  final double amount;
  final String timeAgo;
  final double rating;
  final String feedback;

  PastConsultation({
    required this.id,
    required this.devoteeName,
    this.devoteePhoto = "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80",
    required this.type,
    required this.durationMinutes,
    required this.amount,
    required this.timeAgo,
    required this.rating,
    required this.feedback,
  });

  factory PastConsultation.fromJson(Map<String, dynamic> json) {
    String timeAgo = 'Recently';
    if (json['created_at'] != null) {
      try {
        final dt = DateTime.parse(json['created_at'].toString());
        final diff = DateTime.now().difference(dt);
        if (diff.inMinutes < 2) {
          timeAgo = 'Just now';
        } else if (diff.inMinutes < 60) {
          timeAgo = '${diff.inMinutes} mins ago';
        } else if (diff.inHours < 24) {
          timeAgo = '${diff.inHours} hours ago';
        } else if (diff.inDays == 1) {
          timeAgo = 'Yesterday';
        } else {
          timeAgo = '${diff.inDays} days ago';
        }
      } catch (_) {}
    } else if (json['time_ago'] != null) {
      timeAgo = json['time_ago'].toString();
    }

    return PastConsultation(
      id: json['id']?.toString() ?? '',
      devoteeName: json['user_name']?.toString() ?? json['devotee_name']?.toString() ?? 'Devotee',
      devoteePhoto: json['user_photo']?.toString() ??
          json['devotee_photo']?.toString() ??
          "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80",
      type: json['type']?.toString() ?? 'voice',
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 15,
      amount: (json['total_amount'] as num?)?.toDouble() ??
          (json['amount'] as num?)?.toDouble() ??
          375.0,
      timeAgo: timeAgo,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      feedback: json['notes']?.toString() ??
          json['feedback']?.toString() ??
          'Devotee consultation fulfilled with Vedic remedies.',
    );
  }

  static List<PastConsultation> get mockHistory => [
    PastConsultation(
      id: "hist_1",
      devoteeName: "Ananya Iyer",
      devoteePhoto: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80",
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
      devoteePhoto: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=200&q=80",
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
      devoteePhoto: "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=200&q=80",
      type: "chat",
      durationMinutes: 24,
      amount: 600.0,
      timeAgo: "Yesterday",
      rating: 5.0,
      feedback: "Detailed Kundli chart analysis for my son's wedding.",
    ),
  ];
}

class AstrologerServiceBooking {
  final String id;
  final String devoteeName;
  final String devoteePhoto;
  final String time;
  final String serviceType;
  final String rate;
  final double amount;
  final String status; // pending, in_progress, completed, cancelled
  final String? notes;

  AstrologerServiceBooking({
    required this.id,
    required this.devoteeName,
    required this.devoteePhoto,
    required this.time,
    required this.serviceType,
    required this.rate,
    required this.amount,
    this.status = 'pending',
    this.notes,
  });

  factory AstrologerServiceBooking.fromJson(Map<String, dynamic> json) {
    return AstrologerServiceBooking(
      id: json['id']?.toString() ?? '',
      devoteeName: json['user_name']?.toString() ??
          json['devotee_name']?.toString() ??
          json['customer_name']?.toString() ??
          'Devotee',
      devoteePhoto: json['user_photo']?.toString() ??
          json['devotee_photo']?.toString() ??
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
      time: json['booking_time']?.toString() ?? json['scheduled_at']?.toString() ?? 'Today, 04:30 PM',
      serviceType: json['service_name']?.toString() ??
          json['service_type']?.toString() ??
          json['type']?.toString() ??
          'Kundli Matching',
      rate: json['rate_label']?.toString() ?? '₹500 / 20 mins',
      amount: (json['amount'] as num?)?.toDouble() ?? (json['total_amount'] as num?)?.toDouble() ?? 500.0,
      status: json['status']?.toString() ?? 'pending',
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'devotee_name': devoteeName,
    'devotee_photo': devoteePhoto,
    'time': time,
    'service_type': serviceType,
    'rate': rate,
    'amount': amount,
    'status': status,
    'notes': notes,
  };

  AstrologerServiceBooking copyWith({
    String? status,
    String? notes,
  }) {
    return AstrologerServiceBooking(
      id: id,
      devoteeName: devoteeName,
      devoteePhoto: devoteePhoto,
      time: time,
      serviceType: serviceType,
      rate: rate,
      amount: amount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  static List<AstrologerServiceBooking> get mockBookings => [
    AstrologerServiceBooking(
      id: 'book_001',
      devoteeName: 'Pooja Sharma',
      devoteePhoto: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
      time: 'Today, 04:30 PM',
      serviceType: 'Kundli Matching & Guna Milan',
      rate: '₹500 / 20 mins',
      amount: 500.0,
      status: 'pending',
      notes: 'Horoscope compatibility for prospective marriage.',
    ),
    AstrologerServiceBooking(
      id: 'book_002',
      devoteeName: 'Vikram Mehra',
      devoteePhoto: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      time: 'Today, 06:00 PM',
      serviceType: 'Career & Shani Dasha Analysis',
      rate: '₹300 / 15 mins',
      amount: 300.0,
      status: 'pending',
      notes: 'Guidance on job transition and Sade Sati remedies.',
    ),
    AstrologerServiceBooking(
      id: 'book_003',
      devoteeName: 'Ananya Roy',
      devoteePhoto: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      time: 'Tomorrow, 11:00 AM',
      serviceType: 'Marriage & Griha Pravesh Muhurat',
      rate: '₹400 / 15 mins',
      amount: 400.0,
      status: 'pending',
      notes: 'Auspicious lagna and tithi calculation for wedding.',
    ),
  ];
}
