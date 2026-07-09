package com.redbank.auth.controller;

import com.redbank.auth.dto.AuthResponse;
import com.redbank.auth.dto.RefreshRequest;
import com.redbank.auth.dto.UserDto;
import com.redbank.auth.dto.VerifyRequest;
import com.redbank.auth.service.AuthService;
import com.redbank.core.dto.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@Tag(name = "Authentication", description = "Endpoints for user authentication and token management")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/verify")
    @Operation(summary = "Verify Firebase Token", description = "Validates Firebase token, registers user if new, and returns app JWT")
    public ResponseEntity<ApiResponse<AuthResponse>> verify(@Valid @RequestBody VerifyRequest request) {
        AuthResponse response = authService.verifyAndLogin(request);
        return ResponseEntity.ok(ApiResponse.success(response, "Authentication successful"));
    }

    @PostMapping("/refresh")
    @Operation(summary = "Refresh JWT", description = "Exchanges a valid refresh token for a new JWT")
    public ResponseEntity<ApiResponse<AuthResponse>> refreshToken(@Valid @RequestBody RefreshRequest request) {
        AuthResponse response = authService.refreshToken(request);
        return ResponseEntity.ok(ApiResponse.success(response, "Token refreshed successfully"));
    }

    @PostMapping("/logout")
    @Operation(summary = "Logout", description = "Invalidates the refresh token", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<ApiResponse<Void>> logout(@AuthenticationPrincipal UserDetails userDetails) {
        authService.logout(userDetails.getUsername());
        return ResponseEntity.ok(ApiResponse.success(null, "Logged out successfully"));
    }

    @GetMapping("/me")
    @Operation(summary = "Get Current User", description = "Returns the profile of the currently authenticated user", security = @SecurityRequirement(name = "bearerAuth"))
    public ResponseEntity<ApiResponse<UserDto>> getCurrentUser(@AuthenticationPrincipal UserDetails userDetails) {
        UserDto userDto = authService.getCurrentUser(userDetails.getUsername());
        return ResponseEntity.ok(ApiResponse.success(userDto, "User retrieved successfully"));
    }
}
