package com.redbank.emergency.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.OffsetDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EmergencyRequestTimelineDTO {
    private OffsetDateTime acceptedAt;
    private OffsetDateTime travellingAt;
    private OffsetDateTime arrivedAt;
    private OffsetDateTime completedAt;
    private OffsetDateTime resolvedAt;
}
