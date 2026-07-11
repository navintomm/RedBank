package com.redbank.emergency.controller;

import com.redbank.auth.entity.User;
import com.redbank.core.dto.ApiResponse;
import com.redbank.emergency.dto.TrackingLocationRequestDTO;
import com.redbank.emergency.dto.TrackingLocationResponseDTO;
import com.redbank.emergency.dto.TrackingStatusResponseDTO;
import com.redbank.emergency.service.TrackingService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/emergencies/{id}/tracking")
@RequiredArgsConstructor
@Tag(name = "Live Tracking", description = "Endpoints for real-time donor tracking")
public class TrackingController {

    private final TrackingService trackingService;

    @PostMapping("/start")
    @Operation(summary = "Start live tracking (Donor only)")
    public ResponseEntity<ApiResponse<Void>> startTracking(
            @PathVariable UUID id,
            @AuthenticationPrincipal User user) {
        trackingService.startTracking(id, user.getId());
        return ResponseEntity.ok(ApiResponse.success(null, "Tracking started successfully"));
    }

    @PostMapping("/stop")
    @Operation(summary = "Stop live tracking (Donor only)")
    public ResponseEntity<ApiResponse<Void>> stopTracking(
            @PathVariable UUID id,
            @AuthenticationPrincipal User user) {
        trackingService.stopTracking(id, user.getId());
        return ResponseEntity.ok(ApiResponse.success(null, "Tracking stopped successfully"));
    }

    @PostMapping("/location")
    @Operation(summary = "Publish current location (Donor only)")
    public ResponseEntity<ApiResponse<Void>> updateLocation(
            @PathVariable UUID id,
            @AuthenticationPrincipal User user,
            @Valid @RequestBody TrackingLocationRequestDTO dto) {
        trackingService.updateLocation(id, user.getId(), dto);
        return ResponseEntity.ok(ApiResponse.success(null, "Location updated successfully"));
    }

    @GetMapping
    @Operation(summary = "Get current tracking status and latest location (Requester and Donor)")
    public ResponseEntity<ApiResponse<TrackingStatusResponseDTO>> getTrackingStatus(
            @PathVariable UUID id,
            @AuthenticationPrincipal User user) {
        TrackingStatusResponseDTO response = trackingService.getTrackingStatus(id, user.getId());
        return ResponseEntity.ok(ApiResponse.success(response, "Tracking status retrieved successfully"));
    }

    @GetMapping("/history")
    @Operation(summary = "Get full location history for the request (Requester and Donor)")
    public ResponseEntity<ApiResponse<List<TrackingLocationResponseDTO>>> getTrackingHistory(
            @PathVariable UUID id,
            @AuthenticationPrincipal User user) {
        List<TrackingLocationResponseDTO> response = trackingService.getTrackingHistory(id, user.getId());
        return ResponseEntity.ok(ApiResponse.success(response, "Tracking history retrieved successfully"));
    }
}
