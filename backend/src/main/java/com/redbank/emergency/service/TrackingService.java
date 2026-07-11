package com.redbank.emergency.service;

import com.redbank.emergency.dto.TrackingLocationRequestDTO;
import com.redbank.emergency.dto.TrackingLocationResponseDTO;
import com.redbank.emergency.dto.TrackingStatusResponseDTO;

import java.util.List;
import java.util.UUID;

public interface TrackingService {
    void startTracking(UUID requestId, UUID donorId);
    void stopTracking(UUID requestId, UUID donorId);
    void updateLocation(UUID requestId, UUID donorId, TrackingLocationRequestDTO dto);
    TrackingStatusResponseDTO getTrackingStatus(UUID requestId, UUID userId);
    List<TrackingLocationResponseDTO> getTrackingHistory(UUID requestId, UUID userId);
}
