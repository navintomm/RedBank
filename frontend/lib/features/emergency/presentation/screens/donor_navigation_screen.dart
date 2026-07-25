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
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/maps/map_loading_widget.dart';
import '../../../../core/widgets/redbank_scaffold.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/icon_button.dart';
import '../../../../core/widgets/primary_button.dart';

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
  bool _isFirstLoad = true;

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
    ref.read(liveTrackingServiceProvider).stopTracking();
    super.dispose();
  }

  void _updateMapElements() {
    final trackingStateAsync = ref.watch(trackingProvider(widget.emergency.id));
    if (!trackingStateAsync.hasValue) return;
    
    final trackingState = trackingStateAsync.value!;
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
          rotation: trackingState.currentDonorLocation!.heading ?? 0.0,
        ),
      };

      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: [donorPos, hospitalPos],
          color: AppColors.primary,
          width: 6,
        ),
      };
    });

    if (_isFirstLoad) {
      _isFirstLoad = false;
      _animateCameraToRoute(donorPos, hospitalPos);
    } else {
      _animateCameraToDonor(donorPos, trackingState.currentDonorLocation!.heading ?? 0.0);
    }
    
    // Auto-arrive fallback
    if (distanceMeters <= 50.0 && trackingState.isTrackingActive && !_isArriving) {
      _handleManualArrive();
    }
  }

  Future<void> _animateCameraToRoute(LatLng p1, LatLng p2) async {
    final controller = await _controller.future;
    
    double minLat = p1.latitude < p2.latitude ? p1.latitude : p2.latitude;
    double maxLat = p1.latitude > p2.latitude ? p1.latitude : p2.latitude;
    double minLng = p1.longitude < p2.longitude ? p1.longitude : p2.longitude;
    double maxLng = p1.longitude > p2.longitude ? p1.longitude : p2.longitude;
    
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 120));
  }

  Future<void> _animateCameraToDonor(LatLng donorPos, double heading) async {
    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: donorPos, zoom: 17, tilt: 45, bearing: heading),
    ));
  }

  Future<void> _handleManualArrive() async {
    if (_isArriving) return;
    setState(() => _isArriving = true);
    
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Arrival confirmed. Thank you for your service.'),
          backgroundColor: AppColors.success,
        ),
      );
      
      await ref.read(liveTrackingServiceProvider).stopTracking();
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error confirming arrival: $e'), backgroundColor: AppColors.error),
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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RedBankScaffold(
      body: trackingStateAsync.when(
        data: (trackingState) {
          final initialPos = trackingState.currentDonorLocation != null 
              ? LatLng(trackingState.currentDonorLocation!.latitude, trackingState.currentDonorLocation!.longitude)
              : LatLng(widget.emergency.latitude, widget.emergency.longitude);

          return Stack(
            children: [
              // 1. Full-screen map
              Positioned.fill(
                child: GoogleMap(
                  style: MapService.getMapStyle(context),
                  initialCameraPosition: CameraPosition(
                    target: initialPos,
                    zoom: 15,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    if (!_controller.isCompleted) {
                      _controller.complete(controller);
                    }
                  },
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: false,
                ),
              ),

              // 2. Top App Bar / Summary Overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    child: _buildTopOverlay(trackingState, isDark),
                  ),
                ),
              ),

              // 3. Floating Quick Actions (Re-center)
              Positioned(
                bottom: 220, // Avoid overlapping the bottom panel
                right: AppSpacing.md,
                child: MedicalIconButton(
                  icon: Icons.my_location,
                  isGlass: false,
                  hasBackground: true,
                  onPressed: () {
                    if (trackingState.currentDonorLocation != null) {
                      final donorPos = LatLng(
                        trackingState.currentDonorLocation!.latitude,
                        trackingState.currentDonorLocation!.longitude,
                      );
                      _animateCameraToDonor(donorPos, trackingState.currentDonorLocation!.heading ?? 0.0);
                    }
                  },
                ),
              ),

              // 4. Bottom Navigation Panel
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildNavigationPanel(trackingState, isDark),
              ),
            ],
          );
        },
        loading: () => const MapLoadingWidget(),
        error: (error, _) => ErrorStateWidget(
          message: 'Failed to start navigation.',
          onRetry: () => ref.invalidate(trackingProvider(widget.emergency.id)),
        ),
      ),
    );
  }

  Widget _buildTopOverlay(TrackingState state, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      child: Row(
        children: [
          MedicalIconButton(
            icon: Icons.arrow_back,
            isGlass: false,
            hasBackground: false,
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Navigation',
                  style: AppTypography.getTextTheme(isDark: isDark).titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'To ${widget.emergency.hospitalName}',
                  style: AppTypography.getTextTheme(isDark: isDark).bodySmall?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationPanel(TrackingState state, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Grabber handle for aesthetics
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Distance',
                        style: AppTypography.getTextTheme(isDark: isDark).labelMedium?.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _distanceRemaining > 1000 
                            ? '${(_distanceRemaining / 1000).toStringAsFixed(1)} km'
                            : '${_distanceRemaining.toStringAsFixed(0)} m',
                        style: AppTypography.getTextTheme(isDark: isDark).headlineMedium?.copyWith(
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
                        style: AppTypography.getTextTheme(isDark: isDark).labelMedium?.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _eta,
                        style: AppTypography.getTextTheme(isDark: isDark).headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              
              PrimaryButton(
                text: 'I HAVE ARRIVED',
                icon: Icons.local_hospital_outlined,
                onPressed: _isArriving ? null : _handleManualArrive,
                isLoading: _isArriving,
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              OutlinedButton.icon(
                icon: const Icon(Icons.phone_outlined),
                label: const Text('Call Hospital'),
                onPressed: () {
                  // In a real app, this would use url_launcher
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  side: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                  foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
