package com.redbank.emergency.service.impl;

import com.redbank.auth.entity.User;
import com.redbank.auth.repository.UserRepository;
import com.redbank.emergency.dto.*;
import com.redbank.emergency.entity.EmergencyRequest;
import com.redbank.emergency.enums.EmergencyStatus;
import com.redbank.emergency.mapper.EmergencyRequestMapper;
import com.redbank.emergency.repository.EmergencyRequestRepository;
import com.redbank.emergency.service.EmergencyRequestService;
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
public class EmergencyRequestServiceImpl implements EmergencyRequestService {

    private final EmergencyRequestRepository requestRepository;
    private final UserRepository userRepository;
    private final EmergencyRequestMapper mapper;
    private final StateMachineFactory<EmergencyStatus, EmergencyEvent> stateMachineFactory;

    @Override
    @Transactional
    public EmergencyRequestResponseDTO createRequest(UUID requesterId, EmergencyRequestCreateDTO dto) {
        log.info("Creating emergency request for requester {}", requesterId);
        
        User requester = userRepository.findById(requesterId)
                .orElseThrow(() -> new IllegalArgumentException("Requester not found"));

        EmergencyRequest request = mapper.toEntity(dto);
        request.setRequester(requester);
        // Save initial DRAFT state manually before state machine takes over
        request = requestRepository.save(request);

        // Trigger State Machine to transition DRAFT -> CREATED
        sendEvent(request.getId(), EmergencyEvent.CREATE_REQUEST, requesterId, "REQUESTER");

        return mapper.toResponseDTO(request);
    }

    @Override
    @Transactional
    public void cancelRequest(UUID requestId, UUID actorId, String actorType, String reason) {
        log.info("Cancelling emergency request {}", requestId);
        sendEvent(requestId, EmergencyEvent.CANCEL_REQUEST, actorId, actorType);
    }
    
    @Override
    @Transactional(readOnly = true)
    public EmergencyRequestResponseDTO getRequest(UUID requestId) {
        return requestRepository.findById(requestId)
                .map(mapper::toResponseDTO)
                .orElseThrow(() -> new IllegalArgumentException("Request not found"));
    }

    private void sendEvent(UUID requestId, EmergencyEvent event, UUID actorId, String actorType) {
        StateMachine<EmergencyStatus, EmergencyEvent> sm = stateMachineFactory.getStateMachine(requestId.toString());
        sm.startReactively().subscribe();
        
        Message<EmergencyEvent> message = MessageBuilder.withPayload(event)
                .setHeader(EmergencyStateMachineConstants.REQUEST_ID_HEADER, requestId)
                .setHeader(EmergencyStateMachineConstants.ACTOR_ID_HEADER, actorId)
                .setHeader(EmergencyStateMachineConstants.ACTOR_TYPE_HEADER, actorType)
                .build();
                
        sm.sendEvent(reactor.core.publisher.Mono.just(message)).subscribe();
    }
}
