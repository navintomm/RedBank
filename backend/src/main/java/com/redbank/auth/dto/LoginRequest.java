package com.redbank.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record LoginRequest(
        @NotBlank(message = "Phone number is required")
        @Pattern(regexp = "^\\+[1-9]\\d{1,14}$", message = "Phone number must be in E.164 format")
        String phoneNumber
) {}
