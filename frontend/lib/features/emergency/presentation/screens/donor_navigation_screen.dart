import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../domain/emergency_models.dart';
import '../../providers/tracking_provider.dart';
import '../../../../core/services/live_tracking_service.dart';
import '../../../../core/services/map_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/maps/map_loading_widget.dart';

class DonorNavigationScreen extends ConsumerStatefulWidget {
  final EmergencyRequestModel emergency;

  const DonorNavigationScreen({super.key, required this.emergency});

  @override
  ConsumerState<DonorNavigationScreen> createState() => _DonorNavigationScreenState();
}

class _DonorNavigationScreenState extends ConsumerState<DonorNavigationScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  double _distanceRemaining = 0.0;
  String _eta = 'Calculating...';
  bool _isArriving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTracking();
    });
  }

  void _startTracking() {
    ref.read(liveTrackingServiceProvider).startTracking(widget.emergency.id);
  }

  @override
  void dispose() {
    // Only stop tracking if we navigate away manually and it's not finished
    ref.read(liveTrackingServiceProvider).stopTracking();
    super.dispose();
  }

  void _updateMapElements() {
    final trackingStateAsync = ref.watch(trackingProvider(widget.emergency.id));
    trackingStateAsync.whenData((trackingState) {
      if (trackingState.currentDonorLocation == null) return;

      final hospitalPos = LatLng(widget.emergency.latitude, widget.emergency.longitude);
      final donorPos = LatLng(
        trackingState.currentDonorLocation!.latitude,
        trackingState.currentDonorLocation!.longitude,
      );

      final distanceMeters = Geolocator.distanceBetween(
        donorPos.latitude, donorPos.longitude,
        hospitalPos.latitude, hospitalPos.longitude,
      );

      final speed = trackingState.currentDonorLocation!.speed ?? 0.0;
      String etaStr = 'Calculating...';
      if (speed > 1.0) {
        final seconds = distanceMeters / speed;
        final minutes = (seconds / 60).ceil();
        etaStr = '$minutes min';
      } else {
        final minutes = (distanceMeters / 8.33 / 60).ceil();
        etaStr = '~$minutes min';
      }

      setState(() {
        _distanceRemaining = distanceMeters;
        _eta = etaStr;
        
        _markers = {
          Marker(
            markerId: const MarkerId('hospital'),
            position: hospitalPos,
            infoWindow: const InfoWindow(title: 'Hospital Destination'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
          Marker(
            markerId: const MarkerId('donor'),
            position: donorPos,
            infoWindow: const InfoWindow(title: 'You'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          ),
        };

        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: [donorPos, hospitalPos],
            color: AppColors.primary,
            width: 5,
          ),
        };
      });

      _animateCameraToDonor(donorPos);
      
      // Auto-arrive fallback if backend somehow missed it
      if (distanceMeters <= 50.0 && trackingState.isTrackingActive && !_isArriving) {
        _handleManualArrive();
      }
    });
  }

  Future<void> _animateCameraToDonor(LatLng donorPos) async {
    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: donorPos, zoom: 16, tilt: 45),
    ));
  }

  Future<void> _handleManualArrive() async {
    if (_isArriving) return;
    setState(() => _isArriving = true);
    
    try {
      // Since we don't have an explicit arrive API in flutter layer right now,
      // The backend detects ARRIVED automatically based on distance.
      // But if user clicks manual, we can force a very close location update or handle it.
      // We will assume the API provides a way or rely on automatic detection.
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arrival confirmed. Proceed to the blood bank.')),
      );
      
      // Stop local tracking
      await ref.read(liveTrackingServiceProvider).stopTracking();
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error confirming arrival: $e')),
        );
        setState(() => _isArriving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackingStateAsync = ref.watch(trackingProvider(widget.emergency.id));
    ref.listen(trackingProvider(widget.emergency.id), (prev, next) {
      if (next.hasValue) {
        _updateMapElements();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation'),
        centerTitle: true,
      ),
      body: trackingStateAsync.when(
        data: (trackingState) {
          final initialPos = trackingState.currentDonorLocation != null 
              ? LatLng(trackingState.currentDonorLocation!.latitude, trackingState.currentDonorLocation!.longitude)
              : const LatLng(0, 0);

          return Column(
            children: [
              Expanded(
                child: GoogleMap(
                  style: MapService.getMapStyle(context),
                  initialCameraPosition: CameraPosition(
                    target: initialPos,
                    zoom: 15,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  compassEnabled: true,
                ),
              ),
              _buildNavigationPanel(trackingState),
            ],
          );
        },
        loading: () => const MapLoadingWidget(),
        error: (error, _) => ErrorStateWidget(
          errorMessage: 'Failed to start navigation: $error',
          onRetry: () => ref.invalidate(trackingProvider(widget.emergency.id)),
        ),
      ),
    );
  }

  Widget _buildNavigationPanel(TrackingState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distance',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _distanceRemaining > 1000 
                          ? '${(_distanceRemaining / 1000).toStringAsFixed(1)} km'
                          : '${_distanceRemaining.toStringAsFixed(0)} m',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'ETA',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _eta,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isArriving ? null : _handleManualArrive,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isArriving 
                  ? const SizedBox(
                      height: 24, 
                      width: 24, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Text('I Have Arrived', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
