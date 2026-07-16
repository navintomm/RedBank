package com.redbank.emergency.service;

import com.redbank.emergency.entity.EmergencyRequest;
import com.redbank.emergency.enums.EmergencyStatus;
import com.redbank.emergency.repository.EmergencyRequestRepository;
import com.redbank.emergency.service.impl.MatchingServiceImpl;
import com.redbank.emergency.statemachine.EmergencyEvent;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.statemachine.StateMachine;
import org.springframework.statemachine.config.StateMachineFactory;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class MatchingServiceImplTest {

    @Mock
    private EmergencyRequestRepository requestRepository;

    @Mock
    private NotificationService notificationService;

    @Mock
    private StateMachineFactory<EmergencyStatus, EmergencyEvent> stateMachineFactory;

    @Mock
    private StateMachine<EmergencyStatus, EmergencyEvent> stateMachine;

    @InjectMocks
    private MatchingServiceImpl matchingService;

    private UUID requestId;
    private EmergencyRequest testRequest;

    @BeforeEach
    void setUp() {
        requestId = UUID.randomUUID();
        testRequest = new EmergencyRequest();
        testRequest.setId(requestId);
        testRequest.setCurrentSearchTier(1);
    }

    @Test
    void startMatching_Success() {
        when(requestRepository.findById(requestId)).thenReturn(Optional.of(testRequest));
        when(stateMachineFactory.getStateMachine(requestId.toString())).thenReturn(stateMachine);
        when(stateMachine.startReactively()).thenReturn(Mono.empty());
        when(stateMachine.sendEvent(any(Mono.class))).thenReturn(Flux.empty());

        assertDoesNotThrow(() -> matchingService.startMatching(requestId));

        verify(notificationService).queueNotifications(eq(requestId), anyList(), eq(1));
        verify(stateMachineFactory, times(2)).getStateMachine(requestId.toString());
        verify(stateMachine, times(2)).sendEvent(any(Mono.class));
    }

    @Test
    void startMatching_RequestNotFound_ThrowsException() {
        when(requestRepository.findById(requestId)).thenReturn(Optional.empty());

        assertThrows(IllegalArgumentException.class, () -> matchingService.startMatching(requestId));
    }
}
