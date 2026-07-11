package com.redbank.emergency.service;

import java.util.List;
import java.util.UUID;

public interface NotificationService {
    void queueNotifications(UUID requestId, List<UUID> donorIds, int searchTier);
}
