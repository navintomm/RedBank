class DonorProfileDto {
  final String id;
  final String userId;
  final String bloodGroup;
  final DateTime? dateOfBirth;
  final String? gender;
  final double? weight;
  final String? district;
  final String? city;
  final double? latitude;
  final double? longitude;
  final DateTime? lastDonationDate;
  final String availabilityStatus;
  final String verificationLevel;
  final String? medicalNotes;
  final String? profileImageUrl;

  const DonorProfileDto({
    required this.id,
    required this.userId,
    required this.bloodGroup,
    this.dateOfBirth,
    this.gender,
    this.weight,
    this.district,
    this.city,
    this.latitude,
    this.longitude,
    this.lastDonationDate,
    required this.availabilityStatus,
    required this.verificationLevel,
    this.medicalNotes,
    this.profileImageUrl,
  });

  factory DonorProfileDto.fromJson(Map<String, dynamic> json) {
    return DonorProfileDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      bloodGroup: json['bloodGroup'] as String,
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth'] as String) : null,
      gender: json['gender'] as String?,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      district: json['district'] as String?,
      city: json['city'] as String?,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      lastDonationDate: json['lastDonationDate'] != null ? DateTime.parse(json['lastDonationDate'] as String) : null,
      availabilityStatus: json['availabilityStatus'] as String,
      verificationLevel: json['verificationLevel'] as String,
      medicalNotes: json['medicalNotes'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }

  DonorProfileDto copyWith({
    String? id,
    String? userId,
    String? bloodGroup,
    DateTime? dateOfBirth,
    String? gender,
    double? weight,
    String? district,
    String? city,
    double? latitude,
    double? longitude,
    DateTime? lastDonationDate,
    String? availabilityStatus,
    String? verificationLevel,
    String? medicalNotes,
    String? profileImageUrl,
  }) {
    return DonorProfileDto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      district: district ?? this.district,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastDonationDate: lastDonationDate ?? this.lastDonationDate,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      verificationLevel: verificationLevel ?? this.verificationLevel,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}

class UpdateDonorProfileRequest {
  final String bloodGroup;
  final DateTime? dateOfBirth;
  final String? gender;
  final double? weight;
  final String? district;
  final String? city;
  final double? latitude;
  final double? longitude;
  final DateTime? lastDonationDate;
  final String? medicalNotes;
  final String? profileImageUrl;

  const UpdateDonorProfileRequest({
    required this.bloodGroup,
    this.dateOfBirth,
    this.gender,
    this.weight,
    this.district,
    this.city,
    this.latitude,
    this.longitude,
    this.lastDonationDate,
    this.medicalNotes,
    this.profileImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'bloodGroup': bloodGroup,
      if (dateOfBirth != null) 'dateOfBirth': "${dateOfBirth!.year}-${dateOfBirth!.month.toString().padLeft(2, '0')}-${dateOfBirth!.day.toString().padLeft(2, '0')}",
      if (gender != null) 'gender': gender,
      if (weight != null) 'weight': weight,
      if (district != null) 'district': district,
      if (city != null) 'city': city,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (lastDonationDate != null) 'lastDonationDate': "${lastDonationDate!.year}-${lastDonationDate!.month.toString().padLeft(2, '0')}-${lastDonationDate!.day.toString().padLeft(2, '0')}",
      if (medicalNotes != null) 'medicalNotes': medicalNotes,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
    };
  }
}

class UpdateAvailabilityRequest {
  final String status;

  const UpdateAvailabilityRequest({required this.status});

  Map<String, dynamic> toJson() {
    return {
      'status': status,
    };
  }
}
