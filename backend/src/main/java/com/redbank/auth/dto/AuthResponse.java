package com.redbank.auth.dto;

public record AuthResponse(
        String accessToken,
        String refreshToken,
        UserDto user,
        boolean isNewUser
) {}
