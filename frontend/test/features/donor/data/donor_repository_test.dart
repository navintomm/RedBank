import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:redbank_app/features/donor/data/donor_api_service.dart';
import 'package:redbank_app/features/donor/data/donor_repository.dart';
import 'package:redbank_app/features/donor/domain/donor_models.dart';

class MockDonorApiService extends Mock implements DonorApiService {}

void main() {
  late DonorRepository repository;
  late MockDonorApiService mockApiService;

  setUp(() {
    mockApiService = MockDonorApiService();
    repository = DonorRepository(mockApiService);
  });

  group('DonorRepository Tests', () {
    const mockProfile = DonorProfileDto(
      id: '123',
      userId: 'user123',
      bloodGroup: 'O_POSITIVE',
      availabilityStatus: 'AVAILABLE',
      verificationLevel: 'VERIFIED',
    );

    test('getProfile returns DonorProfileDto on success', () async {
      when(() => mockApiService.getProfile()).thenAnswer((_) async => mockProfile);

      final result = await repository.getProfile();

      expect(result, equals(mockProfile));
      verify(() => mockApiService.getProfile()).called(1);
    });

    test('getProfile throws DonorNotFoundException on 404', () async {
      final dioException = DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 404,
          data: {'message': 'Not found'},
        ),
      );
      
      when(() => mockApiService.getProfile()).thenThrow(dioException);

      expect(() => repository.getProfile(), throwsA(isA<DonorNotFoundException>()));
    });

    test('getProfile throws DonorServerException on 500', () async {
      final dioException = DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 500,
          data: {'message': 'Server error'},
        ),
      );
      
      when(() => mockApiService.getProfile()).thenThrow(dioException);

      expect(() => repository.getProfile(), throwsA(isA<DonorServerException>()));
    });
  });
}
