import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:redbank_app/core/widgets/empty_state_widget.dart';
import 'package:redbank_app/core/widgets/error_state_widget.dart';
import 'package:redbank_app/features/donor/domain/donor_models.dart';
import 'package:redbank_app/features/donor/presentation/donor_profile_screen.dart';
import 'package:redbank_app/features/donor/providers/donor_provider.dart';

class MockNotifierData extends AsyncNotifier<DonorProfileDto?> implements DonorProfileNotifier {
  final DonorProfileDto? initialData;
  MockNotifierData(this.initialData);

  @override
  Future<DonorProfileDto?> build() async => initialData;
  @override
  Future<void> createOrUpdateProfile(UpdateDonorProfileRequest request) async {}
  @override
  Future<void> updateAvailability(String status) async {}
  @override
  Future<void> deleteProfile() async {}
}

class MockNotifierError extends AsyncNotifier<DonorProfileDto?> implements DonorProfileNotifier {
  @override
  Future<DonorProfileDto?> build() async {
    throw Exception('Simulated network error');
  }
  @override
  Future<void> createOrUpdateProfile(UpdateDonorProfileRequest request) async {}
  @override
  Future<void> updateAvailability(String status) async {}
  @override
  Future<void> deleteProfile() async {}
}

void main() {
  testWidgets('DonorProfileScreen renders EmptyStateWidget when profile is null', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          donorProfileProvider.overrideWith(() => MockNotifierData(null)),
        ],
        child: const MaterialApp(
          home: DonorProfileScreen(),
        ),
      ),
    );

    // Fast forward past the loading state
    await tester.pumpAndSettle();

    expect(find.byType(EmptyStateWidget), findsOneWidget);
    expect(find.textContaining('not set up a donor profile'), findsOneWidget);
  });

  testWidgets('DonorProfileScreen renders Data when profile exists', (WidgetTester tester) async {
    const mockProfile = DonorProfileDto(
      id: '1',
      userId: 'user1',
      bloodGroup: 'AB_POSITIVE',
      availabilityStatus: 'AVAILABLE',
      verificationLevel: 'VERIFIED',
      city: 'Gotham',
    );

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            donorProfileProvider.overrideWith(() => MockNotifierData(mockProfile)),
          ],
          child: const MaterialApp(
            home: DonorProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('AB+'), findsOneWidget); // Formatted blood group badge
      expect(find.text('Gotham'), findsOneWidget);
      expect(find.byType(EmptyStateWidget), findsNothing);
    });
  });

  testWidgets('DonorProfileScreen renders ErrorStateWidget on Exception', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          donorProfileProvider.overrideWith(() => MockNotifierError()),
        ],
        child: const MaterialApp(
          home: DonorProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(ErrorStateWidget), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
