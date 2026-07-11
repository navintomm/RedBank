package com.redbank.emergency.service;

import java.util.UUID;

public interface ReliabilityService {
    void penalizeNoShow(UUID donorId, UUID requestId);
}
