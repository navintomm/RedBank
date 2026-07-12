package com.redbank.emergency.service.impl;

import com.redbank.emergency.repository.EmergencyRequestRepository;
import com.redbank.emergency.service.RadiusExpansionService;
import com.redbank.emergency.statemachine.EmergencyEvent;
import com.redbank.emergency.statemachine.EmergencyStateMachineConstants;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.Message;
import org.springframework.messaging.support.MessageBuilder;
import org.springframework.statemachine.StateMachine;
import org.springframework.statemachine.config.StateMachineFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class RadiusExpansionServiceImpl implements RadiusExpansionService {

    private final EmergencyRequestRepository requestRepository;
    private final StateMachineFactory<com.redbank.emergency.enums.EmergencyStatus, EmergencyEvent> stateMachineFactory;
    
    private static final int MAX_TIERS = 5;

    @Override
    @Transactional
    public void evaluateExpansion(UUID requestId) {
        log.info("Evaluating radius expansion for request {}", requestId);
        
        var request = requestRepository.findById(requestId).orElseThrow();
        int currentTier = request.getCurrentSearchTier();
        
        if (currentTier >= MAX_TIERS) {
            log.warn("Max search tier reached. Emitting REQUEST_EXPIRED.");
            sendEvent(requestId, EmergencyEvent.REQUEST_EXPIRED);
        } else {
            // SINGLE RESPONSIBILITY: Increment tier count only. Let State Machine handle state changes.
            request.setCurrentSearchTier(currentTier + 1);
            requestRepository.save(request);
            sendEvent(requestId, EmergencyEvent.RESTART_SEARCH);
        }
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
