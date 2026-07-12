import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/emergency_models.dart';
import '../../providers/tracking_provider.dart';
import '../../../../core/services/map_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/maps/map_loading_widget.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  final EmergencyRequestModel emergency;

  const TrackingScreen({super.key, required this.emergency});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  double _distanceRemaining = 0.0;
  String _eta = 'Calculating...';

  @override
  void initState() {
    super.initState();
    // Pre-calculate distance if we have initial positions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMapElements();
    });
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
        // Assume 30 km/h (8.33 m/s) average urban speed if speed is 0
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
            infoWindow: const InfoWindow(title: 'Hospital'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
          Marker(
            markerId: const MarkerId('donor'),
            position: donorPos,
            infoWindow: const InfoWindow(title: 'Donor'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        };

        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: [donorPos, hospitalPos],
            color: AppColors.primary,
            width: 4,
            patterns: [PatternItem.dash(20), PatternItem.gap(10)],
          ),
        };
      });

      _animateCamera(donorPos, hospitalPos);
    });
  }

  Future<void> _animateCamera(LatLng p1, LatLng p2) async {
    final controller = await _controller.future;
    
    double minLat = p1.latitude < p2.latitude ? p1.latitude : p2.latitude;
    double maxLat = p1.latitude > p2.latitude ? p1.latitude : p2.latitude;
    double minLng = p1.longitude < p2.longitude ? p1.longitude : p2.longitude;
    double maxLng = p1.longitude > p2.longitude ? p1.longitude : p2.longitude;
    
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
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
        title: const Text('Live Tracking'),
        centerTitle: true,
      ),
      body: trackingStateAsync.when(
        data: (trackingState) {
          final initialPos = trackingState.currentDonorLocation != null 
              ? LatLng(trackingState.currentDonorLocation!.latitude, trackingState.currentDonorLocation!.longitude)
              : LatLng(widget.emergency.latitude, widget.emergency.longitude);

          return Column(
            children: [
              Expanded(
                child: GoogleMap(
                  style: MapService.getMapStyle(context),
                  initialCameraPosition: CameraPosition(
                    target: initialPos,
                    zoom: 14,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
              ),
              _buildTrackingPanel(trackingState),
            ],
          );
        },
        loading: () => const MapLoadingWidget(),
        error: (error, _) => ErrorStateWidget(
          errorMessage: 'Failed to load live tracking: $error',
          onRetry: () => ref.invalidate(trackingProvider(widget.emergency.id)),
        ),
      ),
    );
  }

  Widget _buildTrackingPanel(TrackingState state) {
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
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: state.isTrackingActive ? AppColors.success : Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  state.isTrackingActive ? 'Donor is on the way' : 'Tracking inactive',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                if (state.currentDonorLocation != null)
                  Text(
                    'Updated ${DateTime.now().difference(state.currentDonorLocation!.timestamp.toLocal()).inSeconds}s ago',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
