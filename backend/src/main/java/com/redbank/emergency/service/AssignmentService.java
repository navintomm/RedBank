package com.redbank.emergency.service;

import java.util.UUID;

public interface AssignmentService {
    void processAcceptance(UUID requestId, UUID donorId);
}
