package com.redbank.emergency.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.OffsetDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EmergencyRequestAssignmentDTO {
    private UUID id;
    private UUID requestId;
    private UUID donorId;
    private Integer estimatedTravelTimeMins;
    private OffsetDateTime estimatedArrival;
    private OffsetDateTime actualArrival;
    private Boolean isActive;
    private OffsetDateTime createdAt;
    private OffsetDateTime completedAt;
}
