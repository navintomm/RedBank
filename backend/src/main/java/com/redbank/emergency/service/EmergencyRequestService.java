package com.redbank.emergency.service;

import com.redbank.emergency.dto.EmergencyRequestCreateDTO;
import com.redbank.emergency.dto.EmergencyRequestResponseDTO;
import java.util.UUID;

public interface EmergencyRequestService {
    EmergencyRequestResponseDTO createRequest(UUID requesterId, EmergencyRequestCreateDTO dto);
    void cancelRequest(UUID requestId, UUID actorId, String actorType, String reason);
    EmergencyRequestResponseDTO getRequest(UUID requestId);
}
