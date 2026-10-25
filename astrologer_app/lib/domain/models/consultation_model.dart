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
          "",
      devoteeGotra: json['user_gotra']?.toString() ?? json['devotee_gotra']?.toString() ?? 'Not specified',
      devoteeRashi: json['user_rashi']?.toString() ?? json['devotee_rashi']?.toString() ?? 'Not specified',
      birthDob: json['birth_dob']?.toString() ?? 'Not specified',
      birthTime: json['birth_time']?.toString() ?? 'Not specified',
      birthPlace: json['birth_place']?.toString() ?? 'Not specified',
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
  };
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
          0.0,
      todayMinutes: (json['today_minutes'] as num?)?.toInt() ?? 0,
      todayConsultations: (json['completed_consultations'] as num?)?.toInt() ??
          (json['today_consultations'] as num?)?.toInt() ??
          0,
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
    );
  }

  static EarningsSummary get initial => EarningsSummary(
    todayEarnings: 0.0,
    todayMinutes: 0,
    todayConsultations: 0,
    walletBalance: 0.0,
    rating: 5.0,
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
    this.devoteePhoto = "",
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
          "",
      type: json['type']?.toString() ?? 'voice',
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
      amount: (json['total_amount'] as num?)?.toDouble() ??
          (json['amount'] as num?)?.toDouble() ??
          0.0,
      timeAgo: timeAgo,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      feedback: json['notes']?.toString() ??
          json['feedback']?.toString() ??
          '',
    );
  }
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
          '',
      time: json['booking_time']?.toString() ?? json['scheduled_at']?.toString() ?? '',
      serviceType: json['service_name']?.toString() ??
          json['service_type']?.toString() ??
          json['type']?.toString() ??
          'Astrology Consultation',
      rate: json['rate_label']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? (json['total_amount'] as num?)?.toDouble() ?? 0.0,
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
}
