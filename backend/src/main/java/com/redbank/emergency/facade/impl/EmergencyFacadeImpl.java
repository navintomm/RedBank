package com.redbank.emergency.facade.impl;

import com.redbank.emergency.dto.*;
import com.redbank.emergency.entity.EmergencyRequestNotification;
import com.redbank.emergency.enums.NotificationStatus;
import com.redbank.emergency.facade.EmergencyFacade;
import com.redbank.emergency.mapper.EmergencyRequestMapper;
import com.redbank.emergency.repository.EmergencyRequestNotificationRepository;
import com.redbank.emergency.repository.EmergencyRequestRepository;
import com.redbank.emergency.service.EmergencyRequestService;
import com.redbank.emergency.service.HistoryService;
import com.redbank.emergency.statemachine.EmergencyEvent;
import com.redbank.emergency.statemachine.EmergencyStateMachineConstants;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
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
public class EmergencyFacadeImpl implements EmergencyFacade {

    private final EmergencyRequestService requestService;
    private final HistoryService historyService;
    private final EmergencyRequestRepository requestRepository;
    private final EmergencyRequestNotificationRepository notificationRepository;
    private final EmergencyRequestMapper mapper;
    private final StateMachineFactory<com.redbank.emergency.enums.EmergencyStatus, EmergencyEvent> stateMachineFactory;

    @Override
    public EmergencyRequestResponseDTO createRequest(UUID requesterId, EmergencyRequestCreateDTO dto) {
        return requestService.createRequest(requesterId, dto);
    }

    @Override
    public EmergencyRequestResponseDTO getRequest(UUID requestId) {
        return requestService.getRequest(requestId);
    }

    @Override
    public Page<EmergencyRequestSummaryDTO> getMyRequests(UUID requesterId, Pageable pageable) {
        return requestRepository.findByRequesterIdAndIsDeletedFalse(requesterId, pageable)
                .map(mapper::toSummaryDTO);
    }

    @Override
    public void cancelRequest(UUID requestId, UUID actorId, String reason) {
        requestService.cancelRequest(requestId, actorId, "REQUESTER", reason);
    }

    @Override
    public void acceptRequest(UUID requestId, UUID donorId) {
        sendEvent(requestId, donorId, EmergencyEvent.DONOR_ACCEPTED);
    }

    @Override
    public void declineRequest(UUID requestId, UUID donorId) {
        sendEvent(requestId, donorId, EmergencyEvent.DONOR_DECLINED);
    }

    @Override
    public Page<EmergencyRequestSummaryDTO> getActiveRequestsForDonor(UUID donorId, Pageable pageable) {
        return notificationRepository.findByDonorIdAndStatus(donorId, NotificationStatus.SENT, pageable)
                .map(EmergencyRequestNotification::getRequest)
                .map(mapper::toSummaryDTO);
    }

    @Override
    public List<EmergencyRequestHistoryDTO> getRequestHistory(UUID requestId) {
        return historyService.getHistory(requestId);
    }
    
    private void sendEvent(UUID requestId, UUID actorId, EmergencyEvent event) {
        StateMachine<com.redbank.emergency.enums.EmergencyStatus, EmergencyEvent> sm = stateMachineFactory.getStateMachine(requestId.toString());
        sm.startReactively().subscribe();
        Message<EmergencyEvent> message = MessageBuilder.withPayload(event)
                .setHeader(EmergencyStateMachineConstants.REQUEST_ID_HEADER, requestId)
                .setHeader(EmergencyStateMachineConstants.DONOR_ID_HEADER, actorId)
                .setHeader(EmergencyStateMachineConstants.ACTOR_ID_HEADER, actorId)
                .setHeader(EmergencyStateMachineConstants.ACTOR_TYPE_HEADER, "DONOR")
                .build();
        sm.sendEvent(reactor.core.publisher.Mono.just(message)).subscribe();
    }
}
