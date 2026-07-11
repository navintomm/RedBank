package com.redbank.emergency.service;

import java.util.UUID;

public interface RadiusExpansionService {
    void evaluateExpansion(UUID requestId);
}
