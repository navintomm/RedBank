import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';

// --- State Model ---

class MapState {
  final bool isLoading;
  final bool hasPermission;
  final bool isGpsEnabled;
  final LatLng? currentLocation;
  final LatLng? selectedLocation;
  final String? selectedAddress;
  final String? errorMessage;

  const MapState({
    this.isLoading = true,
    this.hasPermission = false,
    this.isGpsEnabled = false,
    this.currentLocation,
    this.selectedLocation,
    this.selectedAddress,
    this.errorMessage,
  });

  MapState copyWith({
    bool? isLoading,
    bool? hasPermission,
    bool? isGpsEnabled,
    LatLng? currentLocation,
    LatLng? selectedLocation,
    String? selectedAddress,
    String? errorMessage,
  }) {
    return MapState(
      isLoading: isLoading ?? this.isLoading,
      hasPermission: hasPermission ?? this.hasPermission,
      isGpsEnabled: isGpsEnabled ?? this.isGpsEnabled,
      currentLocation: currentLocation ?? this.currentLocation,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// --- Provider ---

final mapProvider = StateNotifierProvider.autoDispose<MapNotifier, MapState>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  return MapNotifier(locationService);
});

class MapNotifier extends StateNotifier<MapState> {
  final LocationService _locationService;

  MapNotifier(this._locationService) : super(const MapState()) {
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final position = await _locationService.getCurrentLocation();
      
      final latLng = LatLng(position.latitude, position.longitude);
      
      state = state.copyWith(
        isLoading: false,
        hasPermission: true,
        isGpsEnabled: true,
        currentLocation: latLng,
        // Start with current location as selected if null
        selectedLocation: state.selectedLocation ?? latLng,
      );
      
      // Attempt to get address for initial location
      if (state.selectedLocation != null) {
        _updateAddress(state.selectedLocation!);
      }
    } catch (e) {
      final msg = e.toString().toLowerCase();
      state = state.copyWith(
        isLoading: false,
        hasPermission: !msg.contains('permission'),
        isGpsEnabled: !msg.contains('disabled'),
        errorMessage: e.toString(),
      );
    }
  }

  void updateSelectedLocation(LatLng position) {
    state = state.copyWith(selectedLocation: position);
    _updateAddress(position);
  }

  Future<void> _updateAddress(LatLng position) async {
    try {
      final address = await _locationService.getAddressFromLatLng(position);
      state = state.copyWith(selectedAddress: address);
    } catch (_) {
      // Keep existing address or null if geocoding fails
    }
  }

  Future<void> retryInitialization() async {
    await _initializeLocation();
  }
}
