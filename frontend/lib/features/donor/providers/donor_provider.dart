import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/donor_models.dart';
import '../data/donor_repository.dart';

final donorProfileProvider = AsyncNotifierProvider<DonorProfileNotifier, DonorProfileDto?>(() {
  return DonorProfileNotifier();
});

class DonorProfileNotifier extends AsyncNotifier<DonorProfileDto?> {
  
  @override
  Future<DonorProfileDto?> build() async {
    return _fetchProfile();
  }

  Future<DonorProfileDto?> _fetchProfile() async {
    final repository = ref.read(donorRepositoryProvider);
    try {
      return await repository.getProfile();
    } on DonorNotFoundException {
      return null; // Normal state for new users before creating a profile
    }
  }

  Future<void> createOrUpdateProfile(UpdateDonorProfileRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(donorRepositoryProvider);
      return await repository.createOrUpdateProfile(request);
    });
  }

  Future<void> updateAvailability(String status) async {
    // Optimistic update could be implemented here, but we will rely on backend validation
    final currentData = state.value;
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final repository = ref.read(donorRepositoryProvider);
      final request = UpdateAvailabilityRequest(status: status);
      return await repository.updateAvailability(request);
    });

    // If it fails, state will be AsyncError and UI can handle it.
  }

  Future<void> deleteProfile() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(donorRepositoryProvider);
      await repository.deleteProfile();
      return null;
    });
  }
}
