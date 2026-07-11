import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/dio_client.dart';
import '../data/emergency_api_service.dart';
import '../data/emergency_repository.dart';
import '../domain/emergency_models.dart';
import 'emergency_state.dart';

final emergencyApiServiceProvider = Provider.autoDispose<EmergencyApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return EmergencyApiService(dio);
});

final emergencyRepositoryProvider = Provider.autoDispose<EmergencyRepository>((ref) {
  final apiService = ref.watch(emergencyApiServiceProvider);
  return EmergencyRepository(apiService);
});

final emergencyNotifierProvider = AsyncNotifierProvider.autoDispose<EmergencyNotifier, EmergencyState>(() {
  return EmergencyNotifier();
});

class EmergencyNotifier extends AutoDisposeAsyncNotifier<EmergencyState> {
  late EmergencyRepository _repository;

  @override
  Future<EmergencyState> build() async {
    _repository = ref.watch(emergencyRepositoryProvider);
    // Initial state
    return const EmergencyState();
  }

  Future<void> loadMyRequests() async {
    state = const AsyncValue.loading();
    try {
      final requests = await _repository.getMyRequests();
      state = AsyncValue.data(EmergencyState(myRequests: requests));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadActiveEmergencies() async {
    state = const AsyncValue.loading();
    try {
      final emergencies = await _repository.getActiveEmergencies();
      state = AsyncValue.data(EmergencyState(activeEmergencies: emergencies));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<EmergencyRequestModel?> createRequest(CreateEmergencyRequestDto dto) async {
    final previousState = state.valueOrNull ?? const EmergencyState();
    state = const AsyncValue.loading();
    try {
      final request = await _repository.createEmergencyRequest(dto);
      state = AsyncValue.data(previousState.copyWith(
        myRequests: [...previousState.myRequests, request],
        currentRequest: request,
      ));
      return request;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> getRequestDetails(String id) async {
    final previousState = state.valueOrNull ?? const EmergencyState();
    state = const AsyncValue.loading();
    try {
      final request = await _repository.getEmergencyRequest(id);
      state = AsyncValue.data(previousState.copyWith(currentRequest: request));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> acceptRequest(String id) async {
    final previousState = state.valueOrNull ?? const EmergencyState();
    state = const AsyncValue.loading();
    try {
      await _repository.acceptRequest(id);
      final request = await _repository.getEmergencyRequest(id);
      state = AsyncValue.data(previousState.copyWith(currentRequest: request));
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> declineRequest(String id) async {
    final previousState = state.valueOrNull ?? const EmergencyState();
    state = const AsyncValue.loading();
    try {
      await _repository.declineRequest(id);
      state = AsyncValue.data(previousState);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> cancelRequest(String id, String reason) async {
    final previousState = state.valueOrNull ?? const EmergencyState();
    state = const AsyncValue.loading();
    try {
      await _repository.cancelRequest(id, reason);
      final request = await _repository.getEmergencyRequest(id);
      state = AsyncValue.data(previousState.copyWith(currentRequest: request));
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
