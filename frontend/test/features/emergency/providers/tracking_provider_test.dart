import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:redbank_app/features/emergency/data/tracking_repository.dart';
import 'package:redbank_app/features/emergency/providers/tracking_provider.dart';

class MockTrackingRepository extends Mock implements TrackingRepository {}

void main() {
  late MockTrackingRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockTrackingRepository();
    container = ProviderContainer(
      overrides: [
        trackingRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('TrackingNotifier Tests', () {
    const String emergencyId = 'test_emergency_123';
    
    final mockLocation = TrackingLocation(
      latitude: 40.7128,
      longitude: -74.0060,
      timestamp: DateTime.now(),
    );

    test('build initializes state from repository', () async {
      when(() => mockRepository.getTrackingStatus(emergencyId)).thenAnswer(
        (_) async => TrackingStatus(
          isTrackingActive: true,
          currentStatus: 'DONOR_TRAVELLING',
          latestLocation: mockLocation,
        ),
      );

      final state = await container.read(trackingProvider(emergencyId).future);

      expect(state.isTrackingActive, true);
      expect(state.status, 'DONOR_TRAVELLING');
      expect(state.currentDonorLocation?.latitude, 40.7128);
      
      verify(() => mockRepository.getTrackingStatus(emergencyId)).called(1);
    });

    test('stopTracking updates repository and state', () async {
      when(() => mockRepository.getTrackingStatus(emergencyId)).thenAnswer(
        (_) async => TrackingStatus(
          isTrackingActive: true,
          currentStatus: 'DONOR_TRAVELLING',
        ),
      );
      when(() => mockRepository.stopTracking(emergencyId)).thenAnswer((_) async {});

      // Wait for build
      await container.read(trackingProvider(emergencyId).future);
      
      // Stop tracking
      await container.read(trackingProvider(emergencyId).notifier).stopTracking();

      final state = container.read(trackingProvider(emergencyId)).value;
      
      expect(state?.isTrackingActive, false);
      verify(() => mockRepository.stopTracking(emergencyId)).called(1);
    });

    test('updateLocalEtaAndDistance updates local state only', () async {
      when(() => mockRepository.getTrackingStatus(emergencyId)).thenAnswer(
        (_) async => TrackingStatus(
          isTrackingActive: true,
          currentStatus: 'DONOR_TRAVELLING',
        ),
      );

      // Wait for build
      await container.read(trackingProvider(emergencyId).future);
      
      container.read(trackingProvider(emergencyId).notifier)
          .updateLocalEtaAndDistance('10 mins', 1500.0);

      final state = container.read(trackingProvider(emergencyId)).value;
      
      expect(state?.eta, '10 mins');
      expect(state?.distanceRemaining, 1500.0);
    });
  });
}
