import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:redbank_app/features/donor/data/donor_repository.dart';
import 'package:redbank_app/features/donor/domain/donor_models.dart';
import 'package:redbank_app/features/donor/providers/donor_provider.dart';

class MockDonorRepository extends Mock implements DonorRepository {}

// A Listener class to observe state changes in the provider
class Listener<T> extends Mock {
  void call(T? previous, T next);
}

void main() {
  late MockDonorRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockDonorRepository();
    container = ProviderContainer(
      overrides: [
        donorRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('DonorProfileNotifier Tests', () {
    const mockProfile = DonorProfileDto(
      id: '1',
      userId: 'user1',
      bloodGroup: 'O_POSITIVE',
      availabilityStatus: 'AVAILABLE',
      verificationLevel: 'UNVERIFIED',
    );

    test('Initial fetch loads profile successfully', () async {
      when(() => mockRepository.getProfile()).thenAnswer((_) async => mockProfile);

      final listener = Listener<AsyncValue<DonorProfileDto?>>();
      container.listen(
        donorProfileProvider,
        listener.call,
        fireImmediately: true,
      );

      // Verify initial loading state
      verify(() => listener(null, const AsyncLoading<DonorProfileDto?>())).called(1);

      // Wait for provider to resolve
      await container.read(donorProfileProvider.future);

      // Verify state changed to data
      verify(() => listener(
            const AsyncLoading<DonorProfileDto?>(),
            const AsyncData<DonorProfileDto?>(mockProfile),
          )).called(1);
    });

    test('Initial fetch handles new user (404/NotFound)', () async {
      when(() => mockRepository.getProfile())
          .thenThrow(DonorNotFoundException('Not found'));

      final profile = await container.read(donorProfileProvider.future);

      // Should gracefully return null for a new user
      expect(profile, isNull);
    });

    test('updateAvailability switches state to loading then updates data', () async {
      when(() => mockRepository.getProfile()).thenAnswer((_) async => mockProfile);
      
      final updatedProfile = mockProfile.copyWith(availabilityStatus: 'UNAVAILABLE');
      
      // Need to register fallback value for custom DTO if passing object directly
      registerFallbackValue(const UpdateAvailabilityRequest(status: 'UNAVAILABLE'));
      
      when(() => mockRepository.updateAvailability(any()))
          .thenAnswer((_) async => updatedProfile);

      // Ensure initial load completes
      await container.read(donorProfileProvider.future);

      final notifier = container.read(donorProfileProvider.notifier);
      await notifier.updateAvailability('UNAVAILABLE');

      final finalState = container.read(donorProfileProvider);
      expect(finalState.value?.availabilityStatus, equals('UNAVAILABLE'));
    });
  });
}
