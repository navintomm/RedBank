import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../domain/donor_models.dart';
import '../providers/donor_provider.dart';

class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  ConsumerState<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String _currentAddress = "Tap on the map or use your GPS location";
  bool _isLoading = false;
  bool _isSaving = false;
  
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(0, 0),
    zoom: 2.0,
  );

  @override
  void initState() {
    super.initState();
    _loadInitialLocation();
  }

  Future<void> _loadInitialLocation() async {
    // If donor already has a location, show it
    final profile = ref.read(donorProfileProvider).valueOrNull;
    if (profile != null && profile.latitude != null && profile.longitude != null) {
      final loc = LatLng(profile.latitude!, profile.longitude!);
      setState(() {
        _selectedLocation = loc;
      });
      _updateAddress(loc);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(loc, 15));
    } else {
      // Otherwise try to get current GPS location
      _handleGetCurrentLocation();
    }
  }

  Future<void> _handleGetCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final locationService = ref.read(locationServiceProvider);
      final position = await locationService.getCurrentLocation();
      final loc = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _selectedLocation = loc;
      });
      
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(loc, 15));
      await _updateAddress(loc);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateAddress(LatLng location) async {
    setState(() {
      _isLoading = true;
      _currentAddress = "Loading address...";
    });
    
    final locationService = ref.read(locationServiceProvider);
    final address = await locationService.getAddressFromLatLng(location);
    
    if (mounted) {
      setState(() {
        _currentAddress = address;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleMapTap(LatLng location) async {
    setState(() {
      _selectedLocation = location;
    });
    await _updateAddress(location);
  }

  Future<void> _handleSaveLocation() async {
    if (_selectedLocation == null) return;

    final profile = ref.read(donorProfileProvider).valueOrNull;
    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You must create a profile first.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Re-build request with existing data + new location
      final request = UpdateDonorProfileRequest(
        bloodGroup: profile.bloodGroup,
        dateOfBirth: profile.dateOfBirth,
        gender: profile.gender,
        weight: profile.weight,
        district: profile.district,
        city: profile.city,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        lastDonationDate: profile.lastDonationDate,
        medicalNotes: profile.medicalNotes,
      );

      final notifier = ref.read(donorProfileProvider.notifier);
      await notifier.createOrUpdateProfile(request);

      final state = ref.read(donorProfileProvider);
      if (state.hasError) {
        throw state.error!;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Management'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              // If dark mode, could set dark map style here
              if (_selectedLocation != null) {
                _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_selectedLocation!, 15));
              }
            },
            onTap: _handleMapTap,
            markers: _selectedLocation == null
                ? {}
                : {
                    Marker(
                      markerId: const MarkerId('selected_location'),
                      position: _selectedLocation!,
                    ),
                  },
          ),
          
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomPanel(),
          ),
          
          Positioned(
            top: AppSpacing.md,
            right: AppSpacing.md,
            child: FloatingActionButton(
              heroTag: 'my_location_fab',
              tooltip: 'My Location',
              onPressed: _isLoading ? null : _handleGetCurrentLocation,
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.my_location, semanticLabel: 'Find My Location'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Location',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _currentAddress,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              text: 'Save Location',
              isLoading: _isSaving,
              onPressed: _selectedLocation == null ? null : _handleSaveLocation,
            ),
          ],
        ),
      ),
    );
  }
}
