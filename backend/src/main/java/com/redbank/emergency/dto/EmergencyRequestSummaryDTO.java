package com.redbank.emergency.dto;

import com.redbank.donor.entity.BloodGroup;
import com.redbank.emergency.enums.EmergencyStatus;
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
public class EmergencyRequestSummaryDTO {
    private UUID id;
    private String hospitalName;
    private String city;
    private BloodGroup bloodGroup;
    private EmergencyStatus status;
    private OffsetDateTime createdAt;
}
