package com.redbank.emergency.service.impl;

import com.redbank.emergency.repository.EmergencyRequestRepository;
import com.redbank.emergency.service.MatchingService;
import com.redbank.emergency.service.NotificationService;
import com.redbank.emergency.statemachine.EmergencyEvent;
import com.redbank.emergency.statemachine.EmergencyStateMachineConstants;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.Message;
import org.springframework.messaging.support.MessageBuilder;
import org.springframework.statemachine.StateMachine;
import org.springframework.statemachine.config.StateMachineFactory;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class MatchingServiceImpl implements MatchingService {

    private final EmergencyRequestRepository requestRepository;
    private final NotificationService notificationService;
    private final StateMachineFactory<com.redbank.emergency.enums.EmergencyStatus, EmergencyEvent> stateMachineFactory;

    @Override
    public void startMatching(UUID requestId) {
        log.info("Starting geographic matching for request {}", requestId);
        
        // COHESION: Retrieves current state, isolates ST_DWithin query to MatchEngine context
        var request = requestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Request not found"));
                
        int tier = request.getCurrentSearchTier();
        
        // Mock ST_DWithin Geographic Search
        List<UUID> eligibleDonors = List.of(UUID.randomUUID(), UUID.randomUUID()); 
        
        log.info("Found {} eligible donors for request {} at tier {}", eligibleDonors.size(), requestId, tier);
        
        if (eligibleDonors.isEmpty()) {
            log.warn("No donors found at tier {}, letting timeout loop handle radius expansion.", tier);
            return;
        }

        // COUPLING AVOIDANCE: Service does NOT set request.setStatus()
        // It exclusively delegates flow transitions to the State Machine.
        sendEvent(requestId, EmergencyEvent.DONORS_FOUND);
        
        // Delegate side-effects
        notificationService.queueNotifications(requestId, eligibleDonors, tier);
        
        sendEvent(requestId, EmergencyEvent.SEND_NOTIFICATIONS);
    }
    
    private void sendEvent(UUID requestId, EmergencyEvent event) {
        StateMachine<com.redbank.emergency.enums.EmergencyStatus, EmergencyEvent> sm = stateMachineFactory.getStateMachine(requestId.toString());
        sm.startReactively().subscribe();
        Message<EmergencyEvent> message = MessageBuilder.withPayload(event)
                .setHeader(EmergencyStateMachineConstants.REQUEST_ID_HEADER, requestId)
                .setHeader(EmergencyStateMachineConstants.ACTOR_TYPE_HEADER, "SYSTEM")
                .build();
        sm.sendEvent(reactor.core.publisher.Mono.just(message)).subscribe();
    }
}
