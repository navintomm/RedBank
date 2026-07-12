import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/tracking_repository.dart';

class TrackingState {
  final TrackingLocation? currentDonorLocation;
  final double? distanceRemaining; // In meters
  final String? eta;
  final String status;
  final bool isTrackingActive;

  TrackingState({
    this.currentDonorLocation,
    this.distanceRemaining,
    this.eta,
    required this.status,
    required this.isTrackingActive,
  });

  TrackingState copyWith({
    TrackingLocation? currentDonorLocation,
    double? distanceRemaining,
    String? eta,
    String? status,
    bool? isTrackingActive,
  }) {
    return TrackingState(
      currentDonorLocation: currentDonorLocation ?? this.currentDonorLocation,
      distanceRemaining: distanceRemaining ?? this.distanceRemaining,
      eta: eta ?? this.eta,
      status: status ?? this.status,
      isTrackingActive: isTrackingActive ?? this.isTrackingActive,
    );
  }
}

class TrackingNotifier extends AutoDisposeFamilyAsyncNotifier<TrackingState, String> {
  Timer? _pollingTimer;

  @override
  FutureOr<TrackingState> build(String arg) async {
    ref.onDispose(() {
      _pollingTimer?.cancel();
    });

    final status = await _fetchStatus();
    
    // Poll every 5 seconds for requester if tracking is active
    if (status.isTrackingActive) {
      _startPolling();
    }

    return status;
  }

  Future<TrackingState> _fetchStatus() async {
    final repo = ref.read(trackingRepositoryProvider);
    final response = await repo.getTrackingStatus(arg);
    return TrackingState(
      currentDonorLocation: response.latestLocation,
      status: response.currentStatus,
      isTrackingActive: response.isTrackingActive,
      // ETA and distance would typically be provided by the backend or calculated locally.
      // For now, we leave them null until calculated by the UI map.
    );
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final newStatus = await _fetchStatus();
        state = AsyncData(newStatus);
        
        if (!newStatus.isTrackingActive) {
          timer.cancel();
        }
      } catch (e) {
        // Ignore network errors on polling, keep old state
      }
    });
  }

  Future<void> stopTracking() async {
    try {
      await ref.read(trackingRepositoryProvider).stopTracking(arg);
      _pollingTimer?.cancel();
      state = AsyncData(state.value!.copyWith(isTrackingActive: false));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
  
  void updateLocalEtaAndDistance(String eta, double distance) {
    if (state.hasValue) {
      state = AsyncData(state.value!.copyWith(eta: eta, distanceRemaining: distance));
    }
  }
}

final trackingProvider = AutoDisposeAsyncNotifierProviderFamily<TrackingNotifier, TrackingState, String>(
  () => TrackingNotifier(),
);
