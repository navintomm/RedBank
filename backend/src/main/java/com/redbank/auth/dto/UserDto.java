package com.redbank.auth.dto;

import java.util.Set;
import java.util.UUID;

public record UserDto(
        UUID id,
        String phoneNumber,
        String firstName,
        String lastName,
        Set<String> roles
) {}
