import '../domain/emergency_models.dart';

class EmergencyState {
  final List<EmergencyRequestModel> myRequests;
  final List<EmergencyRequestModel> activeEmergencies;
  final EmergencyRequestModel? currentRequest;

  const EmergencyState({
    this.myRequests = const [],
    this.activeEmergencies = const [],
    this.currentRequest,
  });

  EmergencyState copyWith({
    List<EmergencyRequestModel>? myRequests,
    List<EmergencyRequestModel>? activeEmergencies,
    EmergencyRequestModel? currentRequest,
    bool clearCurrentRequest = false,
  }) {
    return EmergencyState(
      myRequests: myRequests ?? this.myRequests,
      activeEmergencies: activeEmergencies ?? this.activeEmergencies,
      currentRequest: clearCurrentRequest ? null : (currentRequest ?? this.currentRequest),
    );
  }
}
