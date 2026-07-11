package com.redbank.emergency.service.impl;

import com.redbank.auth.repository.UserRepository;
import com.redbank.emergency.entity.EmergencyRequestNotification;
import com.redbank.emergency.repository.EmergencyRequestNotificationRepository;
import com.redbank.emergency.repository.EmergencyRequestRepository;
import com.redbank.emergency.service.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationServiceImpl implements NotificationService {

    private final EmergencyRequestNotificationRepository notificationRepository;
    private final EmergencyRequestRepository requestRepository;
    private final UserRepository userRepository;

    @Async
    @Override
    @Transactional
    public void queueNotifications(UUID requestId, List<UUID> donorIds, int searchTier) {
        log.info("ASYNC QUEUEING: Persisting notifications for {} donors", donorIds.size());
        
        var request = requestRepository.findById(requestId).orElseThrow();
        
        for (UUID donorId : donorIds) {
            var donorOpt = userRepository.findById(donorId);
            if(donorOpt.isPresent()) {
                EmergencyRequestNotification notification = EmergencyRequestNotification.builder()
                        .request(request)
                        .donor(donorOpt.get())
                        .searchTier(searchTier)
                        .build();
                        
                notificationRepository.save(notification);
                log.info("FCM Notification Dispatched to donor {}", donorId);
            }
        }
    }
}
