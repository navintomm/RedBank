package com.redbank.emergency.statemachine.interceptor;

import com.redbank.emergency.entity.EmergencyRequest;
import com.redbank.emergency.entity.EmergencyRequestHistory;
import com.redbank.emergency.enums.EmergencyStatus;
import com.redbank.emergency.repository.EmergencyRequestHistoryRepository;
import com.redbank.emergency.repository.EmergencyRequestRepository;
import com.redbank.emergency.statemachine.EmergencyEvent;
import com.redbank.emergency.statemachine.EmergencyStateMachineConstants;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.Message;
import org.springframework.statemachine.StateMachine;
import org.springframework.statemachine.state.State;
import org.springframework.statemachine.support.StateMachineInterceptorAdapter;
import org.springframework.statemachine.transition.Transition;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;
import java.util.UUID;

@Slf4j
@Component
@RequiredArgsConstructor
public class EmergencyStateMachineInterceptor extends StateMachineInterceptorAdapter<EmergencyStatus, EmergencyEvent> {

    private final EmergencyRequestRepository requestRepository;
    private final EmergencyRequestHistoryRepository historyRepository;

    @Override
    @Transactional
    public void preStateChange(State<EmergencyStatus, EmergencyEvent> state, 
                               Message<EmergencyEvent> message, 
                               Transition<EmergencyStatus, EmergencyEvent> transition, 
                               StateMachine<EmergencyStatus, EmergencyEvent> stateMachine, 
                               StateMachine<EmergencyStatus, EmergencyEvent> rootStateMachine) {
                               
        if (message != null && message.getHeaders().containsKey(EmergencyStateMachineConstants.REQUEST_ID_HEADER)) {
            UUID requestId = message.getHeaders().get(EmergencyStateMachineConstants.REQUEST_ID_HEADER, UUID.class);
            
            Optional<EmergencyRequest> requestOpt = requestRepository.findById(requestId);
            if (requestOpt.isPresent()) {
                EmergencyRequest request = requestOpt.get();
                EmergencyStatus previousStatus = request.getStatus();
                EmergencyStatus newStatus = state.getId();
                
                log.info("Intercepted state change for request {}: {} -> {}", requestId, previousStatus, newStatus);
                
                // Save state transactionally
                request.setStatus(newStatus);
                requestRepository.save(request);
                
                // Extract metadata for the enhanced history record
                String actorType = message.getHeaders().get(EmergencyStateMachineConstants.ACTOR_TYPE_HEADER, String.class);
                UUID actorId = message.getHeaders().get(EmergencyStateMachineConstants.ACTOR_ID_HEADER, UUID.class);
                EmergencyEvent event = message.getPayload();
                
                // Create Enhanced History Record
                EmergencyRequestHistory history = EmergencyRequestHistory.builder()
                        .request(request)
                        .previousStatus(previousStatus)
                        .newStatus(newStatus)
                        .event(event)
                        .actorType(actorType != null ? actorType : "SYSTEM")
                        .actorId(actorId)
                        .transitionReason("Transition triggered by " + event.name())
                        .build();
                        
                historyRepository.save(history);
            }
        }
    }
}
