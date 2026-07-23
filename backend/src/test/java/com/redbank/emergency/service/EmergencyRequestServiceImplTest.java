package com.redbank.emergency.service;

import com.redbank.auth.entity.User;
import com.redbank.auth.repository.UserRepository;
import com.redbank.emergency.dto.EmergencyRequestCreateDTO;
import com.redbank.emergency.dto.EmergencyRequestResponseDTO;
import com.redbank.emergency.entity.EmergencyRequest;
import com.redbank.emergency.enums.EmergencyStatus;
import com.redbank.emergency.mapper.EmergencyRequestMapper;
import com.redbank.emergency.repository.EmergencyRequestRepository;
import com.redbank.emergency.service.impl.EmergencyRequestServiceImpl;
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

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@SuppressWarnings("unchecked")
class EmergencyRequestServiceImplTest {

    @Mock
    private EmergencyRequestRepository requestRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private EmergencyRequestMapper mapper;

    @Mock
    private StateMachineFactory<EmergencyStatus, EmergencyEvent> stateMachineFactory;

    @Mock
    private StateMachine<EmergencyStatus, EmergencyEvent> stateMachine;

    @InjectMocks
    private EmergencyRequestServiceImpl emergencyRequestService;

    private User testRequester;
    private EmergencyRequest testRequest;
    private EmergencyRequestCreateDTO createDTO;

    @BeforeEach
    void setUp() {
        testRequester = new User();
        testRequester.setId(UUID.randomUUID());

        testRequest = new EmergencyRequest();
        testRequest.setId(UUID.randomUUID());
        testRequest.setRequester(testRequester);
        testRequest.setStatus(EmergencyStatus.DRAFT);

        createDTO = new EmergencyRequestCreateDTO();
    }

    @Test
    void createRequest_Success() {
        UUID requesterId = testRequester.getId();
        when(userRepository.findById(requesterId)).thenReturn(Optional.of(testRequester));
        when(mapper.toEntity(createDTO)).thenReturn(testRequest);
        when(requestRepository.save(testRequest)).thenReturn(testRequest);
        
        EmergencyRequestResponseDTO mockResponse = new EmergencyRequestResponseDTO();
        mockResponse.setId(testRequest.getId());
        when(mapper.toResponseDTO(testRequest)).thenReturn(mockResponse);

        when(stateMachineFactory.getStateMachine(anyString())).thenReturn(stateMachine);
        when(stateMachine.startReactively()).thenReturn(Mono.empty());
        when(stateMachine.sendEvent(any(Mono.class))).thenReturn(Flux.empty());

        EmergencyRequestResponseDTO result = emergencyRequestService.createRequest(requesterId, createDTO);

        assertNotNull(result);
        assertEquals(testRequest.getId(), result.getId());

        verify(requestRepository).save(testRequest);
        verify(stateMachineFactory).getStateMachine(testRequest.getId().toString());
        verify(stateMachine).startReactively();
        verify(stateMachine).sendEvent(any(Mono.class));
    }

    @Test
    void createRequest_UserNotFound_ThrowsException() {
        UUID requesterId = UUID.randomUUID();
        when(userRepository.findById(requesterId)).thenReturn(Optional.empty());

        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, 
                () -> emergencyRequestService.createRequest(requesterId, createDTO));

        assertEquals("Requester not found", exception.getMessage());
        verify(requestRepository, never()).save(any());
        verify(stateMachineFactory, never()).getStateMachine(anyString());
    }

    @Test
    void cancelRequest_Success() {
        UUID requestId = testRequest.getId();
        UUID actorId = testRequester.getId();
        String actorType = "REQUESTER";
        String reason = "No longer needed";

        when(requestRepository.findById(requestId)).thenReturn(Optional.of(testRequest));
        when(stateMachineFactory.getStateMachine(requestId.toString())).thenReturn(stateMachine);
        when(stateMachine.startReactively()).thenReturn(Mono.empty());
        when(stateMachine.sendEvent(any(Mono.class))).thenReturn(Flux.empty());

        assertDoesNotThrow(() -> emergencyRequestService.cancelRequest(requestId, actorId, actorType, reason));

        verify(requestRepository).findById(requestId);
        verify(stateMachineFactory).getStateMachine(requestId.toString());
        verify(stateMachine).startReactively();
        verify(stateMachine).sendEvent(any(Mono.class));
    }

    @Test
    void cancelRequest_Unauthorized_ThrowsException() {
        UUID requestId = testRequest.getId();
        UUID maliciousActorId = UUID.randomUUID();
        String actorType = "REQUESTER";
        String reason = "Malicious intent";

        when(requestRepository.findById(requestId)).thenReturn(Optional.of(testRequest));

        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class,
                () -> emergencyRequestService.cancelRequest(requestId, maliciousActorId, actorType, reason));

        assertEquals("Unauthorized: Only the requester can cancel this emergency request", exception.getMessage());
        
        verify(requestRepository).findById(requestId);
        verify(stateMachineFactory, never()).getStateMachine(anyString());
    }

    @Test
    void getRequest_Success() {
        UUID requestId = testRequest.getId();
        when(requestRepository.findById(requestId)).thenReturn(Optional.of(testRequest));
        
        EmergencyRequestResponseDTO mockResponse = new EmergencyRequestResponseDTO();
        mockResponse.setId(requestId);
        when(mapper.toResponseDTO(testRequest)).thenReturn(mockResponse);

        EmergencyRequestResponseDTO result = emergencyRequestService.getRequest(requestId);

        assertNotNull(result);
        assertEquals(requestId, result.getId());
    }

    @Test
    void getRequest_NotFound_ThrowsException() {
        UUID requestId = UUID.randomUUID();
        when(requestRepository.findById(requestId)).thenReturn(Optional.empty());

        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, 
                () -> emergencyRequestService.getRequest(requestId));

        assertEquals("Request not found", exception.getMessage());
    }
}
