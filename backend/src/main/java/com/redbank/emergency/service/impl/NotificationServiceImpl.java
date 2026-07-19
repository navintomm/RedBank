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

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationServiceImpl implements NotificationService {

    private final EmergencyRequestNotificationRepository notificationRepository;
    private final EmergencyRequestRepository requestRepository;
    private final UserRepository userRepository;
    private final java.util.Optional<FirebaseMessaging> firebaseMessaging;

    @Async
    @Override
    @Transactional
    public void queueNotifications(UUID requestId, List<UUID> donorIds, int searchTier) {
        log.info("ASYNC QUEUEING: Persisting notifications for {} donors", donorIds.size());
        
        var request = requestRepository.findById(requestId).orElseThrow();
        
        for (UUID donorId : donorIds) {
            var donorOpt = userRepository.findById(donorId);
            if(donorOpt.isPresent()) {
                var donor = donorOpt.get();
                EmergencyRequestNotification notification = EmergencyRequestNotification.builder()
                        .request(request)
                        .donor(donor)
                        .searchTier(searchTier)
                        .build();
                        
                notificationRepository.save(notification);
                log.info("FCM Notification saved for donor {}", donorId);
                
                sendFcmNotification(donor.getFcmToken(), "EMERGENCY_REQUEST", requestId.toString(), null, "Emergency Blood Request", "A patient nearby needs your blood type immediately.");
            }
        }
    }

    @Async
    @Override
    public void notifyRequesterDonorAccepted(UUID requestId, UUID assignmentId, UUID donorId) {
        var request = requestRepository.findById(requestId).orElseThrow();
        var donor = userRepository.findById(donorId).orElseThrow();
        
        sendFcmNotification(
                request.getRequester().getFcmToken(), 
                "EMERGENCY_ACCEPTED", 
                requestId.toString(), 
                assignmentId.toString(),
                "Donor Accepted!", 
                donor.getFirstName() + " has accepted your request and will be on their way."
        );
    }

    @Async
    @Override
    public void notifyRequesterDonorArrived(UUID requestId, UUID assignmentId, UUID donorId) {
        var request = requestRepository.findById(requestId).orElseThrow();
        var donor = userRepository.findById(donorId).orElseThrow();
        
        sendFcmNotification(
                request.getRequester().getFcmToken(), 
                "DONOR_ARRIVED", 
                requestId.toString(), 
                assignmentId.toString(),
                "Donor Arrived!", 
                donor.getFirstName() + " has arrived at the hospital."
        );
    }
    
    private void sendFcmNotification(String token, String type, String emergencyId, String assignmentId, String title, String body) {
        if (token == null || token.isBlank()) {
            log.warn("Cannot send FCM notification, token is missing for user.");
            return;
        }

        try {
            var messageBuilder = Message.builder()
                    .setToken(token)
                    .setNotification(Notification.builder()
                            .setTitle(title)
                            .setBody(body)
                            .build())
                    .putData("type", type)
                    .putData("emergencyId", emergencyId);
                    
            if (assignmentId != null) {
                messageBuilder.putData("assignmentId", assignmentId);
            }
            
            if (firebaseMessaging.isPresent()) {
                firebaseMessaging.get().sendAsync(messageBuilder.build());
                log.info("Dispatched FCM notification to token {} (type: {})", token, type);
            } else {
                log.warn("Simulated FCM notification to token {} (type: {}) - Firebase not configured", token, type);
            }
        } catch (Exception e) {
            log.error("Failed to send FCM notification", e);
        }
    }
}
