package com.redbank.auth.dto;

import jakarta.validation.constraints.NotBlank;

public record UpdateFcmTokenRequest(
        @NotBlank(message = "FCM Token is required")
        String fcmToken
) {}
