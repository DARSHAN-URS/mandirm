import 'dart:convert';

class AstrologerProfile {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String role;
  final String? avatarUrl;
  final String? title;
  final String? bio;
  final int experienceYears;
  final double perMinuteChatRate;
  final double perMinuteCallRate;
  final double perMinuteVideoRate;
  final String? specialities;
  final String? languages;
  final double rating;
  final int consultationsCount;
  final bool isOnline;
  final bool isChatActive;
  final bool isCallActive;
  final double walletBalance;
  final String? workingHours;
  final DateTime? createdAt;

  const AstrologerProfile({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.role = 'astrologer',
    this.avatarUrl,
    this.title,
    this.bio,
    this.experienceYears = 10,
    this.perMinuteChatRate = 25.0,
    this.perMinuteCallRate = 35.0,
    this.perMinuteVideoRate = 45.0,
    this.specialities,
    this.languages,
    this.rating = 4.9,
    this.consultationsCount = 0,
    this.isOnline = true,
    this.isChatActive = true,
    this.isCallActive = true,
    this.walletBalance = 0.0,
    this.workingHours,
    this.createdAt,
  });

  factory AstrologerProfile.fromJson(Map<String, dynamic> rawJson) {
    final json = Map<String, dynamic>.from(rawJson);
    String? rawBio = json['bio']?.toString() ?? json['description']?.toString();
    if (rawBio != null && rawBio.contains('---METADATA---')) {
      final parts = rawBio.split('---METADATA---');
      rawBio = parts[0].trim();
      try {
        final metaStr = parts[1].trim();
        final metaJson = jsonDecode(metaStr);
        if (metaJson is Map) {
          json.addAll(Map<String, dynamic>.from(metaJson));
        }
      } catch (_) {}
    }

    // Parse specialities if List or String
    String specialitiesStr = 'Vedic Astrology';
    if (json['specialities'] != null) {
      if (json['specialities'] is List) {
        specialitiesStr = (json['specialities'] as List).join(', ');
      } else {
        specialitiesStr = json['specialities'].toString();
      }
    } else if (json['specialties'] != null) {
      if (json['specialties'] is List) {
        specialitiesStr = (json['specialties'] as List).join(', ');
      } else {
        specialitiesStr = json['specialties'].toString();
      }
    }

    // Parse languages if List or String
    String languagesStr = 'Hindi, English';
    if (json['languages'] != null) {
      if (json['languages'] is List) {
        languagesStr = (json['languages'] as List).join(', ');
      } else {
        languagesStr = json['languages'].toString();
      }
    }

    return AstrologerProfile(
      id: (json['id'] ?? json['sub'] ?? '').toString(),
      name: (json['name'] ?? json['full_name'] ?? 'Acharya').toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      role: (json['role'] ?? 'astrologer').toString(),
      avatarUrl: json['avatar_url']?.toString() ?? json['image_url']?.toString(),
      title: json['title']?.toString() ?? 'Vedic Astrologer',
      bio: rawBio,
      experienceYears: json['experience_years'] is num
          ? (json['experience_years'] as num).toInt()
          : int.tryParse(json['experience_years']?.toString() ?? '5') ?? 5,
      perMinuteChatRate: (json['per_minute_chat_rate'] is num)
          ? (json['per_minute_chat_rate'] as num).toDouble()
          : (json['chat_price'] is num
              ? (json['chat_price'] as num).toDouble()
              : double.tryParse(json['chat_price']?.toString() ?? '25.0') ?? 25.0),
      perMinuteCallRate: (json['per_minute_call_rate'] is num)
          ? (json['per_minute_call_rate'] as num).toDouble()
          : (json['call_price'] is num
              ? (json['call_price'] as num).toDouble()
              : double.tryParse(json['call_price']?.toString() ?? '35.0') ?? 35.0),
      perMinuteVideoRate: (json['per_minute_video_rate'] is num)
          ? (json['per_minute_video_rate'] as num).toDouble()
          : (json['video_price'] is num
              ? (json['video_price'] as num).toDouble()
              : double.tryParse(json['video_price']?.toString() ?? '45.0') ?? 45.0),
      specialities: specialitiesStr,
      languages: languagesStr,
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : 5.0,
      consultationsCount: json['consultations_count'] is num
          ? (json['consultations_count'] as num).toInt()
          : int.tryParse(json['consultations_count']?.toString() ?? '0') ?? 0,
      isOnline: json['is_online'] == true || json['is_online'] == 1,
      isChatActive: json['is_chat_active'] == true || json['is_chat_active'] == 1,
      isCallActive: json['is_call_active'] == true || json['is_call_active'] == 1,
      walletBalance: (json['wallet_balance'] is num)
          ? (json['wallet_balance'] as num).toDouble()
          : double.tryParse(json['wallet_balance']?.toString() ?? '0.0') ?? 0.0,
      workingHours: json['working_hours']?.toString() ?? '09:00 AM - 09:00 PM',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      'role': role,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (title != null) 'title': title,
      if (bio != null) 'bio': bio,
      'experience_years': experienceYears,
      'per_minute_chat_rate': perMinuteChatRate,
      'per_minute_call_rate': perMinuteCallRate,
      'per_minute_video_rate': perMinuteVideoRate,
      if (specialities != null) 'specialities': specialities,
      if (languages != null) 'languages': languages,
      'rating': rating,
      'consultations_count': consultationsCount,
      'is_online': isOnline,
      'is_chat_active': isChatActive,
      'is_call_active': isCallActive,
      'wallet_balance': walletBalance,
      if (workingHours != null) 'working_hours': workingHours,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  AstrologerProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? avatarUrl,
    String? title,
    String? bio,
    int? experienceYears,
    double? perMinuteChatRate,
    double? perMinuteCallRate,
    double? perMinuteVideoRate,
    String? specialities,
    String? languages,
    double? rating,
    int? consultationsCount,
    bool? isOnline,
    bool? isChatActive,
    bool? isCallActive,
    double? walletBalance,
    String? workingHours,
    DateTime? createdAt,
  }) {
    return AstrologerProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      title: title ?? this.title,
      bio: bio ?? this.bio,
      experienceYears: experienceYears ?? this.experienceYears,
      perMinuteChatRate: perMinuteChatRate ?? this.perMinuteChatRate,
      perMinuteCallRate: perMinuteCallRate ?? this.perMinuteCallRate,
      perMinuteVideoRate: perMinuteVideoRate ?? this.perMinuteVideoRate,
      specialities: specialities ?? this.specialities,
      languages: languages ?? this.languages,
      rating: rating ?? this.rating,
      consultationsCount: consultationsCount ?? this.consultationsCount,
      isOnline: isOnline ?? this.isOnline,
      isChatActive: isChatActive ?? this.isChatActive,
      isCallActive: isCallActive ?? this.isCallActive,
      walletBalance: walletBalance ?? this.walletBalance,
      workingHours: workingHours ?? this.workingHours,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
