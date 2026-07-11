package com.redbank.emergency.controller;

import com.redbank.auth.entity.User;
import com.redbank.core.dto.ApiResponse;
import com.redbank.emergency.dto.*;
import com.redbank.emergency.facade.EmergencyFacade;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/emergencies")
@RequiredArgsConstructor
@Tag(name = "Emergency Request", description = "Endpoints for managing emergency blood requests")
public class EmergencyController {

    private final EmergencyFacade emergencyFacade;

    @PostMapping
    @Operation(summary = "Create a new emergency request")
    public ResponseEntity<ApiResponse<EmergencyRequestResponseDTO>> createRequest(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody EmergencyRequestCreateDTO dto) {
        EmergencyRequestResponseDTO response = emergencyFacade.createRequest(user.getId(), dto);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(response, "Emergency request created successfully"));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get emergency request by ID")
    public ResponseEntity<ApiResponse<EmergencyRequestResponseDTO>> getRequest(@PathVariable UUID id) {
        EmergencyRequestResponseDTO response = emergencyFacade.getRequest(id);
        return ResponseEntity.ok(ApiResponse.success(response, "Request retrieved successfully"));
    }

    @GetMapping("/my-requests")
    @Operation(summary = "Get requests created by the current user")
    public ResponseEntity<ApiResponse<Page<EmergencyRequestSummaryDTO>>> getMyRequests(
            @AuthenticationPrincipal User user,
            Pageable pageable) {
        Page<EmergencyRequestSummaryDTO> response = emergencyFacade.getMyRequests(user.getId(), pageable);
        return ResponseEntity.ok(ApiResponse.success(response, "Requests retrieved successfully"));
    }

    @PostMapping("/{id}/cancel")
    @Operation(summary = "Cancel an active emergency request")
    public ResponseEntity<ApiResponse<Void>> cancelRequest(
            @PathVariable UUID id,
            @AuthenticationPrincipal User user,
            @Valid @RequestBody CancelRequestDTO dto) {
        emergencyFacade.cancelRequest(id, user.getId(), dto.getReason());
        return ResponseEntity.ok(ApiResponse.success(null, "Request cancelled successfully"));
    }

    @PostMapping("/{id}/accept")
    @Operation(summary = "Accept an emergency request as a donor")
    public ResponseEntity<ApiResponse<Void>> acceptRequest(
            @PathVariable UUID id,
            @AuthenticationPrincipal User user) {
        emergencyFacade.acceptRequest(id, user.getId());
        return ResponseEntity.ok(ApiResponse.success(null, "Request accepted successfully"));
    }

    @PostMapping("/{id}/decline")
    @Operation(summary = "Decline an emergency request as a donor")
    public ResponseEntity<ApiResponse<Void>> declineRequest(
            @PathVariable UUID id,
            @AuthenticationPrincipal User user) {
        emergencyFacade.declineRequest(id, user.getId());
        return ResponseEntity.ok(ApiResponse.success(null, "Request declined successfully"));
    }

    @GetMapping("/active")
    @Operation(summary = "Get active requests assigned or notified to the current donor")
    public ResponseEntity<ApiResponse<Page<EmergencyRequestSummaryDTO>>> getActiveRequests(
            @AuthenticationPrincipal User user,
            Pageable pageable) {
        Page<EmergencyRequestSummaryDTO> response = emergencyFacade.getActiveRequestsForDonor(user.getId(), pageable);
        return ResponseEntity.ok(ApiResponse.success(response, "Active requests retrieved successfully"));
    }

    @GetMapping("/{id}/history")
    @Operation(summary = "Get the state transition history for a request")
    public ResponseEntity<ApiResponse<List<EmergencyRequestHistoryDTO>>> getRequestHistory(@PathVariable UUID id) {
        List<EmergencyRequestHistoryDTO> response = emergencyFacade.getRequestHistory(id);
        return ResponseEntity.ok(ApiResponse.success(response, "Request history retrieved successfully"));
    }
}
