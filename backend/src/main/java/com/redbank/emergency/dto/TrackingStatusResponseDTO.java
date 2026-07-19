package com.redbank.emergency.dto;

import com.redbank.emergency.enums.EmergencyStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TrackingStatusResponseDTO {
    private boolean isTrackingActive;
    private EmergencyStatus currentStatus;
    private TrackingLocationResponseDTO latestLocation;
    
    // Assignment details
    private UUID assignedDonorId;
    private String assignedDonorName;
    private Integer estimatedTravelTimeMins;
    private java.time.OffsetDateTime estimatedArrival;
}
