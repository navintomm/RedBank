import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../domain/emergency_models.dart';
import '../../providers/tracking_provider.dart';
import '../../../../core/services/map_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/maps/map_loading_widget.dart';
import '../../../../core/widgets/redbank_scaffold.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/icon_button.dart';
import '../widgets/emergency_timeline.dart';

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
    
    // Add padding to ensure markers aren't hidden behind overlays
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 120));
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
                  mapToolbarEnabled: false,
                  compassEnabled: false, // We'll rely on the default UX for simplicity or add a custom one
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

              // 3. Bottom Tracking Panel
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildTrackingPanel(trackingState, isDark),
              ),
            ],
          );
        },
        loading: () => const MapLoadingWidget(),
        error: (error, _) => ErrorStateWidget(
          message: 'Failed to load live tracking.',
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
                  'Live Tracking',
                  style: AppTypography.getTextTheme(isDark: isDark).titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.emergency.hospitalName,
                  style: AppTypography.getTextTheme(isDark: isDark).bodySmall?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Refresh/re-center button
          MedicalIconButton(
            icon: Icons.my_location,
            isGlass: false,
            hasBackground: true,
            onPressed: () {
              if (state.currentDonorLocation != null) {
                final donorPos = LatLng(
                  state.currentDonorLocation!.latitude,
                  state.currentDonorLocation!.longitude,
                );
                final hospitalPos = LatLng(widget.emergency.latitude, widget.emergency.longitude);
                _animateCamera(donorPos, hospitalPos);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingPanel(TrackingState state, bool isDark) {
    String statusMessage = 'Waiting for donor';
    Color statusColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

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
        statusColor = isDark ? AppColors.primaryDark : AppColors.primaryLight;
      }
    } else if (state.status == 'ACCEPTED') {
      statusMessage = 'Donor accepted, waiting to start travel';
      statusColor = AppColors.warning;
    } else if (state.status == 'FAILED' || state.status == 'CANCELLED') {
      statusMessage = 'Request ${state.status.toLowerCase()}';
      statusColor = AppColors.error;
    }

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
              
              EmergencyTimeline(currentStatus: state.status),
              
              const SizedBox(height: AppSpacing.lg),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              
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
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      statusMessage,
                      style: AppTypography.getTextTheme(isDark: isDark).bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (state.currentDonorLocation != null && state.status == 'DONOR_TRAVELLING')
                    Text(
                      'Updated ${DateTime.now().difference(state.currentDonorLocation!.timestamp.toLocal()).inSeconds}s ago',
                      style: AppTypography.getTextTheme(isDark: isDark).bodySmall?.copyWith(
                        color: isStale ? AppColors.warning : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.phone_outlined),
                      label: const Text('Call Donor'),
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
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Share Tracking'),
                      onPressed: () {
                        // In a real app, this would use share_plus
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        side: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.dividerLight),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                        foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
