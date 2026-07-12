import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../features/emergency/data/tracking_repository.dart';

final liveTrackingServiceProvider = Provider<LiveTrackingService>((ref) {
  return LiveTrackingService(ref);
});

class LiveTrackingService {
  final Ref _ref;
  StreamSubscription<Position>? _positionStream;
  String? _activeEmergencyId;
  DateTime? _lastPublishTime;

  LiveTrackingService(this._ref);

  Future<void> startTracking(String emergencyId) async {
    if (_activeEmergencyId == emergencyId) return;
    
    _activeEmergencyId = emergencyId;
    
    // Notify backend
    await _ref.read(trackingRepositoryProvider).startTracking(emergencyId);

    // Require background execution on Android (requires foreground service config in AndroidManifest if app is killed, but this works for backgrounded app)
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 20, // Only emit if moved > 20 meters
    );

    _positionStream?.cancel();
    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      _publishLocation(position);
    });
    
    // Force immediate publish of current location
    try {
      final initialPosition = await Geolocator.getCurrentPosition();
      _publishLocation(initialPosition);
    } catch (e) {
      // Ignore if unavailable immediately
    }
  }

  Future<void> stopTracking() async {
    if (_activeEmergencyId != null) {
      try {
        await _ref.read(trackingRepositoryProvider).stopTracking(_activeEmergencyId!);
      } catch (e) {
        // Ignore failure on stop
      }
    }
    await _positionStream?.cancel();
    _positionStream = null;
    _activeEmergencyId = null;
  }

  void _publishLocation(Position position) {
    if (_activeEmergencyId == null) return;
    
    final now = DateTime.now();
    // Extra guard: even though distanceFilter is 20m, we ensure we don't spam if geolocator goes rogue. Max once per 15 seconds.
    if (_lastPublishTime != null && now.difference(_lastPublishTime!).inSeconds < 15) {
      return;
    }
    
    _lastPublishTime = now;

    final location = TrackingLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      speed: position.speed,
      heading: position.heading,
      timestamp: position.timestamp.toUtc(),
    );

    _ref.read(trackingRepositoryProvider).updateLocation(_activeEmergencyId!, location).catchError((e) {
      // Silently fail and retry on next tick
    });
  }
}
