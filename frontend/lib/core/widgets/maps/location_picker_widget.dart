import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/map_provider.dart';
import '../../services/map_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import 'map_loading_widget.dart';
import 'permission_required_widget.dart';
import 'current_location_button.dart';

class LocationPickerWidget extends ConsumerStatefulWidget {
  final Function(LatLng, String?) onLocationSelected;
  final double height;

  const LocationPickerWidget({
    super.key,
    required this.onLocationSelected,
    this.height = 300,
  });

  @override
  ConsumerState<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends ConsumerState<LocationPickerWidget> {
  late final MapService _mapService;

  @override
  void initState() {
    super.initState();
    _mapService = MapService();
  }

  @override
  void dispose() {
    _mapService.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapService.onMapCreated(controller);
  }

  void _onCameraIdle() {
    // When the map stops moving, we could optionally reverse-geocode the center point
    // This is useful if the user drags the map instead of tapping
  }

  void _onMapTap(LatLng position) {
    ref.read(mapProvider.notifier).updateSelectedLocation(position);
    
    // Notify parent immediately
    final state = ref.read(mapProvider);
    widget.onLocationSelected(position, state.selectedAddress);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (state.isLoading) {
      return SizedBox(
        height: widget.height,
        child: const MapLoadingWidget(),
      );
    }

    if (!state.hasPermission || !state.isGpsEnabled) {
      return SizedBox(
        height: widget.height,
        child: PermissionRequiredWidget(
          errorMessage: state.errorMessage ?? 'We need location access to set the hospital coordinate.',
          isGpsDisabled: !state.isGpsEnabled,
          onRetry: () => ref.read(mapProvider.notifier).retryInitialization(),
        ),
      );
    }

    final initialTarget = state.selectedLocation ?? state.currentLocation ?? const LatLng(0, 0);

    // We only create the set of markers if a location is selected
    final markers = <Marker>{};
    if (state.selectedLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: state.selectedLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    // Also notify parent if address finishes resolving
    ref.listen<MapState>(mapProvider, (previous, next) {
      if (next.selectedLocation != null && next.selectedAddress != previous?.selectedAddress) {
        widget.onLocationSelected(next.selectedLocation!, next.selectedAddress);
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            ),
          ),
          child: ClipRRect(
            borderRadius: AppSpacing.borderRadiusMd,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: initialTarget,
                    zoom: 15.0,
                  ),
                  onMapCreated: _onMapCreated,
                  onCameraIdle: _onCameraIdle,
                  onTap: _onMapTap,
                  markers: markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: false,
                  style: MapService.getMapStyle(context),
                ),
                Positioned(
                  bottom: AppSpacing.md,
                  right: AppSpacing.md,
                  child: CurrentLocationButton(
                    isDark: isDark,
                    onPressed: () {
                      if (state.currentLocation != null) {
                        _mapService.moveToLocation(state.currentLocation!);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        if (state.selectedAddress != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary, size: 16),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  state.selectedAddress!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          )
        ],
      ],
    );
  }
}
