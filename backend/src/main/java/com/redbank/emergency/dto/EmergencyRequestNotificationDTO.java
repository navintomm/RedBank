package com.redbank.emergency.dto;

import com.redbank.emergency.enums.NotificationStatus;
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
public class EmergencyRequestNotificationDTO {
    private UUID id;
    private UUID requestId;
    private UUID donorId;
    private NotificationStatus status;
    private Integer searchTier;
    private OffsetDateTime createdAt;
    private OffsetDateTime respondedAt;
    
    // Optionally include basic request info so donor can see what they're notified for
    private EmergencyRequestSummaryDTO requestSummary;
}
