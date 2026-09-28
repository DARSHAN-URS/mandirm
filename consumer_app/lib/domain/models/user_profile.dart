class UserProfile {
  final String id;
  final String? phoneNumber;
  final String? email;
  final String? fullName;
  final String? avatarUrl;
  final String? gotra;
  final String? rashi;
  final String? nakshatra;
  final DateTime? birthDate;
  final String? birthPlace;
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    this.phoneNumber,
    this.email,
    this.fullName,
    this.avatarUrl,
    this.gotra,
    this.rashi,
    this.nakshatra,
    this.birthDate,
    this.birthPlace,
    this.createdAt,
  });

  bool get isProfileComplete => fullName != null && fullName!.trim().isNotEmpty;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      phoneNumber: json['phone_number'] as String?,
      email: json['email'] as String?,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      gotra: json['gotra'] as String?,
      rashi: json['rashi'] as String?,
      nakshatra: json['nakshatra'] as String?,
      birthDate: json['birth_date'] != null
          ? DateTime.tryParse(json['birth_date'] as String)
          : null,
      birthPlace: json['birth_place'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (email != null) 'email': email,
      if (fullName != null) 'full_name': fullName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (gotra != null) 'gotra': gotra,
      if (rashi != null) 'rashi': rashi,
      if (nakshatra != null) 'nakshatra': nakshatra,
      if (birthDate != null) 'birth_date': birthDate!.toIso8601String(),
      if (birthPlace != null) 'birth_place': birthPlace,
    };
  }

  UserProfile copyWith({
    String? id,
    String? phoneNumber,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? gotra,
    String? rashi,
    String? nakshatra,
    DateTime? birthDate,
    String? birthPlace,
  }) {
    return UserProfile(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gotra: gotra ?? this.gotra,
      rashi: rashi ?? this.rashi,
      nakshatra: nakshatra ?? this.nakshatra,
      birthDate: birthDate ?? this.birthDate,
      birthPlace: birthPlace ?? this.birthPlace,
      createdAt: createdAt,
    );
  }
}
