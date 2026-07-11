package com.redbank.emergency.service;

import com.redbank.emergency.dto.EmergencyRequestHistoryDTO;
import java.util.List;
import java.util.UUID;

public interface HistoryService {
    List<EmergencyRequestHistoryDTO> getHistory(UUID requestId);
}
