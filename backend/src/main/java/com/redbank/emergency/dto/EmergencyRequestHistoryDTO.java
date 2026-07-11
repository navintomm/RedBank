package com.redbank.emergency.dto;

import com.redbank.emergency.enums.EmergencyStatus;
import com.redbank.emergency.statemachine.EmergencyEvent;
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
public class EmergencyRequestHistoryDTO {
    private UUID id;
    private UUID requestId;
    private EmergencyStatus previousStatus;
    private EmergencyStatus newStatus;
    private EmergencyEvent event;
    private String actorType;
    private UUID actorId;
    private String transitionReason;
    private OffsetDateTime createdAt;
}
