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
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMapElements();
    });
  }

  void _updateMapElements() {
    final trackingStateAsync = ref.read(trackingProvider(widget.emergency.id));
    if (!trackingStateAsync.hasValue) return;
    
    final trackingState = trackingStateAsync.value!;
    final hospitalPos = LatLng(widget.emergency.latitude, widget.emergency.longitude);

    LatLng? donorPos;
    if (trackingState.currentDonorLocation != null) {
      donorPos = LatLng(
        trackingState.currentDonorLocation!.latitude,
        trackingState.currentDonorLocation!.longitude,
      );
    }

    double distanceMeters = 0.0;
    if (donorPos != null) {
      distanceMeters = Geolocator.distanceBetween(
        donorPos.latitude, donorPos.longitude,
        hospitalPos.latitude, hospitalPos.longitude,
      );
    }

    String etaStr = 'Calculating...';
    if (trackingState.estimatedTravelTimeMins != null) {
      etaStr = '${trackingState.estimatedTravelTimeMins} min';
    } else if (trackingState.status == 'DONOR_TRAVELLING') {
      etaStr = 'Calculating...';
    } else if (trackingState.status == 'ARRIVED' || trackingState.status == 'COMPLETED') {
      etaStr = 'Arrived';
      distanceMeters = 0.0;
    } else {
      etaStr = 'Waiting...';
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
      };

      if (donorPos != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('donor'),
            position: donorPos,
            infoWindow: const InfoWindow(title: 'Donor'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          )
        );
        
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: [donorPos, hospitalPos],
            color: AppColors.primary,
            width: 4,
            patterns: [PatternItem.dash(20), PatternItem.gap(10)],
          ),
        };
      } else {
        _polylines = {};
      }
    });

    // Only auto-animate camera on first load or if explicitly recentering (prevent aggressive zooming on every poll)
    if (_isFirstLoad && donorPos != null) {
      _isFirstLoad = false;
      _animateCamera(donorPos, hospitalPos);
    }
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
                    if (!_controller.isCompleted) {
                      _controller.complete(controller);
                    }
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
    String statusMessage = 'Waiting for donor';
    Color statusColor = Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;

    bool isStale = false;
    if (state.currentDonorLocation != null) {
      final secondsSinceUpdate = DateTime.now().difference(state.currentDonorLocation!.timestamp.toLocal()).inSeconds;
      if (secondsSinceUpdate > 120) {
        isStale = true;
      }
    }

    if (state.status == 'COMPLETED') {
      statusMessage = 'Donation Completed';
      statusColor = AppColors.success;
    } else if (state.status == 'ARRIVED') {
      statusMessage = 'Donor Arrived';
      statusColor = AppColors.success;
    } else if (state.status == 'DONOR_TRAVELLING') {
      if (state.currentDonorLocation == null) {
        statusMessage = 'Waiting for first location...';
        statusColor = AppColors.warning;
      } else if (isStale) {
        statusMessage = 'Location stale (poor signal)';
        statusColor = AppColors.warning;
      } else {
        statusMessage = '${state.assignedDonorName ?? 'Donor'} is travelling';
        statusColor = AppColors.primary;
      }
    } else if (state.status == 'ACCEPTED') {
      statusMessage = 'Donor accepted, waiting to start travel';
      statusColor = AppColors.warning;
    } else if (state.status == 'FAILED' || state.status == 'CANCELLED') {
      statusMessage = 'Request ${state.status.toLowerCase()}';
      statusColor = AppColors.error;
    }

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
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  statusMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                if (state.currentDonorLocation != null && state.status == 'DONOR_TRAVELLING')
                  Text(
                    'Updated ${DateTime.now().difference(state.currentDonorLocation!.timestamp.toLocal()).inSeconds}s ago',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isStale ? AppColors.warning : Theme.of(context).textTheme.bodySmall?.color,
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
