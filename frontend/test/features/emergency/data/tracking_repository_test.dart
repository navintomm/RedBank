import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:redbank_app/features/emergency/data/tracking_repository.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late TrackingRepository repository;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    repository = TrackingRepository(mockDio);
  });

  group('TrackingRepository Tests', () {
    const String emergencyId = '123e4567-e89b-12d3-a456-426614174000';
    final location = TrackingLocation(
      latitude: 40.7128,
      longitude: -74.0060,
      timestamp: DateTime.now(),
    );

    test('startTracking calls correct endpoint', () async {
      when(() => mockDio.post(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {'success': true},
        ),
      );

      await repository.startTracking(emergencyId);

      verify(() => mockDio.post('/emergencies/$emergencyId/tracking/start')).called(1);
    });

    test('stopTracking calls correct endpoint', () async {
      when(() => mockDio.post(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {'success': true},
        ),
      );

      await repository.stopTracking(emergencyId);

      verify(() => mockDio.post('/emergencies/$emergencyId/tracking/stop')).called(1);
    });

    test('updateLocation sends correctly formatted data', () async {
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {'success': true},
        ),
      );

      await repository.updateLocation(emergencyId, location);

      verify(
        () => mockDio.post(
          '/emergencies/$emergencyId/tracking/location',
          data: location.toJson(),
        ),
      ).called(1);
    });

    test('getTrackingStatus returns TrackingStatus on success', () async {
      final mockData = {
        'data': {
          'isTrackingActive': true,
          'currentStatus': 'DONOR_TRAVELLING',
          'latestLocation': location.toJson(),
        }
      };

      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: mockData,
        ),
      );

      final result = await repository.getTrackingStatus(emergencyId);

      expect(result.isTrackingActive, true);
      expect(result.currentStatus, 'DONOR_TRAVELLING');
      expect(result.latestLocation?.latitude, location.latitude);
      
      verify(() => mockDio.get('/emergencies/$emergencyId/tracking')).called(1);
    });
    
    test('getTrackingHistory returns List of TrackingLocation', () async {
      final mockData = {
        'data': [
          location.toJson()
        ]
      };

      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: mockData,
        ),
      );

      final result = await repository.getTrackingHistory(emergencyId);

      expect(result.length, 1);
      expect(result.first.latitude, location.latitude);
      
      verify(() => mockDio.get('/emergencies/$emergencyId/tracking/history')).called(1);
    });
  });
}
