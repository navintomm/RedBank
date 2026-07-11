package com.redbank.donor.dto;

import com.redbank.donor.entity.AvailabilityStatus;
import jakarta.validation.constraints.NotNull;

public record UpdateAvailabilityRequest(
        @NotNull(message = "Availability status is required")
        AvailabilityStatus status
) {}
