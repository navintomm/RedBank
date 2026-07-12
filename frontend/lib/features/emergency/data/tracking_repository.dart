import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/dio_client.dart';

final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return TrackingRepository(dio);
});

class TrackingLocation {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? speed;
  final double? heading;
  final DateTime timestamp;

  TrackingLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.speed,
    this.heading,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'speed': speed,
        'heading': heading,
        'timestamp': timestamp.toIso8601String(),
      };

  factory TrackingLocation.fromJson(Map<String, dynamic> json) {
    return TrackingLocation(
      latitude: json['latitude'],
      longitude: json['longitude'],
      accuracy: json['accuracy'],
      speed: json['speed'],
      heading: json['heading'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class TrackingStatus {
  final bool isTrackingActive;
  final String currentStatus;
  final TrackingLocation? latestLocation;

  TrackingStatus({
    required this.isTrackingActive,
    required this.currentStatus,
    this.latestLocation,
  });

  factory TrackingStatus.fromJson(Map<String, dynamic> json) {
    return TrackingStatus(
      isTrackingActive: json['isTrackingActive'] ?? false,
      currentStatus: json['currentStatus'] ?? 'UNKNOWN',
      latestLocation: json['latestLocation'] != null
          ? TrackingLocation.fromJson(json['latestLocation'])
          : null,
    );
  }
}

class TrackingRepository {
  final Dio _dio;

  TrackingRepository(this._dio);

  Future<void> startTracking(String emergencyId) async {
    await _dio.post('/emergencies/$emergencyId/tracking/start');
  }

  Future<void> stopTracking(String emergencyId) async {
    await _dio.post('/emergencies/$emergencyId/tracking/stop');
  }

  Future<void> updateLocation(String emergencyId, TrackingLocation location) async {
    await _dio.post('/emergencies/$emergencyId/tracking/location', data: location.toJson());
  }

  Future<TrackingStatus> getTrackingStatus(String emergencyId) async {
    final response = await _dio.get('/emergencies/$emergencyId/tracking');
    return TrackingStatus.fromJson(response.data['data']);
  }

  Future<List<TrackingLocation>> getTrackingHistory(String emergencyId) async {
    final response = await _dio.get('/emergencies/$emergencyId/tracking/history');
    final List<dynamic> data = response.data['data'];
    return data.map((json) => TrackingLocation.fromJson(json)).toList();
  }
}
