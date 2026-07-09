package com.redbank.auth.dto;

import jakarta.validation.constraints.NotBlank;

public record VerifyRequest(
        @NotBlank(message = "Firebase ID Token is required")
        String idToken,
        
        String role // Optional: Role to assign if user is new
) {}
