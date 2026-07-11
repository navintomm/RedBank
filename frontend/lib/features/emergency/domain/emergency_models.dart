class EmergencyRequestModel {
  final String id;
  final String bloodGroup;
  final int unitsRequired;
  final String status;
  final double latitude;
  final double longitude;
  final String hospitalName;
  final String? hospitalAddress;
  final String? city;
  final String? patientName;
  final String priority;
  final String emergencyType;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? failureReason;
  final String? cancelReason;

  const EmergencyRequestModel({
    required this.id,
    required this.bloodGroup,
    required this.unitsRequired,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.hospitalName,
    this.hospitalAddress,
    this.city,
    this.patientName,
    required this.priority,
    required this.emergencyType,
    required this.createdAt,
    this.updatedAt,
    this.failureReason,
    this.cancelReason,
  });

  factory EmergencyRequestModel.fromJson(Map<String, dynamic> json) {
    return EmergencyRequestModel(
      id: json['id'] as String,
      bloodGroup: json['bloodGroup'] as String,
      unitsRequired: json['unitsRequired'] as int,
      status: json['status'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      hospitalName: json['hospitalName'] as String,
      hospitalAddress: json['hospitalAddress'] as String?,
      city: json['city'] as String?,
      patientName: json['patientName'] as String?,
      priority: json['priority'] as String,
      emergencyType: json['emergencyType'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      failureReason: json['failureReason'] as String?,
      cancelReason: json['cancelReason'] as String?,
    );
  }
}

class EmergencyNotificationModel {
  final String id;
  final String emergencyRequestId;
  final String donorId;
  final String status;
  final DateTime sentAt;

  const EmergencyNotificationModel({
    required this.id,
    required this.emergencyRequestId,
    required this.donorId,
    required this.status,
    required this.sentAt,
  });

  factory EmergencyNotificationModel.fromJson(Map<String, dynamic> json) {
    return EmergencyNotificationModel(
      id: json['id'] as String,
      emergencyRequestId: json['emergencyRequestId'] as String,
      donorId: json['donorId'] as String,
      status: json['status'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
    );
  }
}

class EmergencyAssignmentModel {
  final String id;
  final String emergencyRequestId;
  final String donorId;
  final DateTime? estimatedArrival;
  final DateTime? actualArrival;

  const EmergencyAssignmentModel({
    required this.id,
    required this.emergencyRequestId,
    required this.donorId,
    this.estimatedArrival,
    this.actualArrival,
  });

  factory EmergencyAssignmentModel.fromJson(Map<String, dynamic> json) {
    return EmergencyAssignmentModel(
      id: json['id'] as String,
      emergencyRequestId: json['emergencyRequestId'] as String,
      donorId: json['donorId'] as String,
      estimatedArrival: json['estimatedArrival'] != null ? DateTime.parse(json['estimatedArrival'] as String) : null,
      actualArrival: json['actualArrival'] != null ? DateTime.parse(json['actualArrival'] as String) : null,
    );
  }
}

class EmergencyHistoryModel {
  final String id;
  final String previousState;
  final String newState;
  final String event;
  final String actorType;
  final String actorId;
  final DateTime timestamp;
  final String? transitionReason;

  const EmergencyHistoryModel({
    required this.id,
    required this.previousState,
    required this.newState,
    required this.event,
    required this.actorType,
    required this.actorId,
    required this.timestamp,
    this.transitionReason,
  });

  factory EmergencyHistoryModel.fromJson(Map<String, dynamic> json) {
    return EmergencyHistoryModel(
      id: json['id'] as String,
      previousState: json['previousState'] as String,
      newState: json['newState'] as String,
      event: json['event'] as String,
      actorType: json['actorType'] as String,
      actorId: json['actorId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      transitionReason: json['transitionReason'] as String?,
    );
  }
}

class CreateEmergencyRequestDto {
  final String patientName;
  final int patientAge;
  final String gender;
  final String bloodGroup;
  final String emergencyType; // component
  final int unitsRequired;
  final String priority;
  final String hospitalName;
  final String hospitalAddress;
  final String district;
  final String city;
  final double latitude;
  final double longitude;
  final String medicalNotes;
  final String contactInstructions;

  const CreateEmergencyRequestDto({
    required this.patientName,
    required this.patientAge,
    required this.gender,
    required this.bloodGroup,
    required this.emergencyType,
    required this.unitsRequired,
    required this.priority,
    required this.hospitalName,
    required this.hospitalAddress,
    required this.district,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.medicalNotes,
    required this.contactInstructions,
  });

  Map<String, dynamic> toJson() {
    return {
      'patientName': patientName,
      'patientAge': patientAge,
      'gender': gender,
      'bloodGroup': bloodGroup,
      'emergencyType': emergencyType,
      'unitsRequired': unitsRequired,
      'priority': priority,
      'hospitalName': hospitalName,
      'hospitalAddress': hospitalAddress,
      'district': district,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'medicalNotes': medicalNotes,
      'contactInstructions': contactInstructions,
    };
  }
}
