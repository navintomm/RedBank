package com.redbank.donor.controller;

import com.redbank.auth.entity.User;
import com.redbank.core.dto.ApiResponse;
import com.redbank.donor.dto.DonorProfileDto;
import com.redbank.donor.dto.UpdateAvailabilityRequest;
import com.redbank.donor.dto.UpdateDonorProfileRequest;
import com.redbank.donor.service.DonorProfileService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/donors/profile")
@Tag(name = "Donor Profile", description = "Endpoints for managing donor profiles and eligibility")
@SecurityRequirement(name = "bearerAuth")
public class DonorController {

    private final DonorProfileService donorService;

    public DonorController(DonorProfileService donorService) {
        this.donorService = donorService;
    }

    @GetMapping
    @Operation(summary = "Get Profile", description = "Gets the current user's donor profile")
    public ResponseEntity<ApiResponse<DonorProfileDto>> getProfile(@AuthenticationPrincipal User user) {
        DonorProfileDto profile = donorService.getProfileByUserId(user.getId());
        return ResponseEntity.ok(ApiResponse.success(profile, "Profile retrieved successfully"));
    }

    @PostMapping
    @Operation(summary = "Create or Update Profile", description = "Creates or completely updates the donor profile. Computes initial eligibility.")
    public ResponseEntity<ApiResponse<DonorProfileDto>> createOrUpdateProfile(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody UpdateDonorProfileRequest request) {
        DonorProfileDto profile = donorService.createOrUpdateProfile(user.getId(), request);
        return ResponseEntity.ok(ApiResponse.success(profile, "Profile saved successfully"));
    }

    @PutMapping
    @Operation(summary = "Update Profile", description = "Alias for POST. Updates the donor profile.")
    public ResponseEntity<ApiResponse<DonorProfileDto>> updateProfile(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody UpdateDonorProfileRequest request) {
        return createOrUpdateProfile(user, request);
    }

    @PatchMapping("/availability")
    @Operation(summary = "Update Availability", description = "Quick toggle for updating donor availability status (checks cooldowns)")
    public ResponseEntity<ApiResponse<DonorProfileDto>> updateAvailability(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody UpdateAvailabilityRequest request) {
        DonorProfileDto profile = donorService.updateAvailability(user.getId(), request);
        return ResponseEntity.ok(ApiResponse.success(profile, "Availability updated successfully"));
    }

    @DeleteMapping
    @Operation(summary = "Delete Profile", description = "Soft deletes the donor profile")
    public ResponseEntity<ApiResponse<Void>> deleteProfile(@AuthenticationPrincipal User user) {
        donorService.deleteProfile(user.getId());
        return ResponseEntity.ok(ApiResponse.success(null, "Profile deleted successfully"));
    }
}
