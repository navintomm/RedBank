package com.redbank.emergency.dto;

import com.redbank.donor.entity.BloodGroup;
import com.redbank.emergency.enums.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EmergencyRequestResponseDTO {
    private UUID id;
    private UUID requesterId;
    private UUID hospitalId;
    
    private String patientName;
    private BloodGroup bloodGroup;
    private EmergencyType emergencyType;
    private Integer unitsRequired;
    
    private String hospitalName;
    private String hospitalAddress;
    private String city;
    private String pincode;
    private BigDecimal latitude;
    private BigDecimal longitude;
    
    private EmergencyStatus status;
    private EmergencyPriority priority;
    private RequestSource source;
    
    private FailureReason failureReason;
    private CancelReason cancelReason;
    
    private Integer currentSearchTier;
    private Integer version;
    
    private OffsetDateTime createdAt;
    private OffsetDateTime updatedAt;
    
    private EmergencyRequestTimelineDTO timeline;
}
