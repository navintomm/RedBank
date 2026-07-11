package com.redbank.emergency.facade;

import com.redbank.emergency.dto.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.UUID;

public interface EmergencyFacade {
    EmergencyRequestResponseDTO createRequest(UUID requesterId, EmergencyRequestCreateDTO dto);
    EmergencyRequestResponseDTO getRequest(UUID requestId);
    Page<EmergencyRequestSummaryDTO> getMyRequests(UUID requesterId, Pageable pageable);
    void cancelRequest(UUID requestId, UUID actorId, String reason);
    void acceptRequest(UUID requestId, UUID donorId);
    void declineRequest(UUID requestId, UUID donorId);
    Page<EmergencyRequestSummaryDTO> getActiveRequestsForDonor(UUID donorId, Pageable pageable);
    List<EmergencyRequestHistoryDTO> getRequestHistory(UUID requestId);
}
