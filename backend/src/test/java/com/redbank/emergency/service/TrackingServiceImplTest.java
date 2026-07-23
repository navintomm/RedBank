package com.redbank.emergency.service;

import com.redbank.auth.entity.User;
import com.redbank.auth.repository.UserRepository;
import com.redbank.emergency.dto.TrackingLocationRequestDTO;
import com.redbank.emergency.dto.TrackingStatusResponseDTO;
import com.redbank.emergency.entity.EmergencyRequest;
import com.redbank.emergency.entity.EmergencyRequestAssignment;
import com.redbank.emergency.entity.TrackingLocation;
import com.redbank.emergency.enums.EmergencyStatus;
import com.redbank.emergency.repository.EmergencyRequestAssignmentRepository;
import com.redbank.emergency.repository.EmergencyRequestRepository;
import com.redbank.emergency.repository.TrackingLocationRepository;
import com.redbank.emergency.service.impl.TrackingServiceImpl;
import com.redbank.emergency.statemachine.EmergencyEvent;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.statemachine.StateMachine;
import org.springframework.statemachine.config.StateMachineFactory;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;
import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@SuppressWarnings("unchecked")
class TrackingServiceImplTest {

    @Mock
    private TrackingLocationRepository trackingLocationRepository;

    @Mock
    private EmergencyRequestRepository requestRepository;

    @Mock
    private EmergencyRequestAssignmentRepository assignmentRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private StateMachineFactory<EmergencyStatus, EmergencyEvent> stateMachineFactory;

    @Mock
    private StateMachine<EmergencyStatus, EmergencyEvent> stateMachine;

    @InjectMocks
    private TrackingServiceImpl trackingService;

    private UUID requestId;
    private UUID donorId;
    private User testDonor;
    private EmergencyRequest testRequest;
    private EmergencyRequestAssignment testAssignment;
    private TrackingLocationRequestDTO locationRequestDTO;

    @BeforeEach
    void setUp() {
        requestId = UUID.randomUUID();
        donorId = UUID.randomUUID();

        testDonor = new User();
        testDonor.setId(donorId);

        testRequest = new EmergencyRequest();
        testRequest.setId(requestId);
        
        User testRequester = new User();
        testRequester.setId(UUID.randomUUID());
        testRequest.setRequester(testRequester);
        
        testRequest.setLatitude(BigDecimal.valueOf(40.7128));
        testRequest.setLongitude(BigDecimal.valueOf(-74.0060));
        testRequest.setStatus(EmergencyStatus.DONOR_TRAVELLING);

        testAssignment = new EmergencyRequestAssignment();
        testAssignment.setRequest(testRequest);
        testAssignment.setDonor(testDonor);
        testAssignment.setIsActive(true);

        locationRequestDTO = new TrackingLocationRequestDTO();
        locationRequestDTO.setLatitude(41.7127);
        locationRequestDTO.setLongitude(-75.0059);
        locationRequestDTO.setAccuracy(5.0);
        locationRequestDTO.setSpeed(10.0);
        locationRequestDTO.setHeading(90.0);
        locationRequestDTO.setTimestamp(LocalDateTime.now());
    }

    @Test
    void startTracking_Success() {
        when(assignmentRepository.findByRequestIdAndDonorIdAndIsActiveTrue(requestId, donorId))
                .thenReturn(Optional.of(testAssignment));
        when(stateMachineFactory.getStateMachine(requestId.toString())).thenReturn(stateMachine);
        when(stateMachine.startReactively()).thenReturn(Mono.empty());
        when(stateMachine.sendEvent(any(Mono.class))).thenReturn(Flux.empty());

        assertDoesNotThrow(() -> trackingService.startTracking(requestId, donorId));

        verify(stateMachineFactory).getStateMachine(requestId.toString());
        verify(stateMachine).sendEvent(any(Mono.class));
    }

    @Test
    void startTracking_InvalidAssignment_ThrowsException() {
        when(assignmentRepository.findByRequestIdAndDonorIdAndIsActiveTrue(requestId, donorId))
                .thenReturn(Optional.empty());

        assertThrows(AccessDeniedException.class, 
                () -> trackingService.startTracking(requestId, donorId));
    }

    @Test
    void updateLocation_Success() {
        when(assignmentRepository.findByRequestIdAndDonorIdAndIsActiveTrue(requestId, donorId))
                .thenReturn(Optional.of(testAssignment));
        when(trackingLocationRepository.findFirstByEmergencyRequestIdOrderByTimestampDesc(requestId))
                .thenReturn(Optional.empty());
        when(userRepository.findById(donorId)).thenReturn(Optional.of(testDonor));

        assertDoesNotThrow(() -> trackingService.updateLocation(requestId, donorId, locationRequestDTO));

        verify(trackingLocationRepository).save(any(TrackingLocation.class));
        verify(stateMachineFactory, never()).getStateMachine(anyString()); // Since it hasn't arrived
    }

    @Test
    void updateLocation_ArrivalTriggered() {
        // Set coordinates exactly equal to hospital to trigger arrival
        locationRequestDTO.setLatitude(40.7128);
        locationRequestDTO.setLongitude(-74.0060);

        when(assignmentRepository.findByRequestIdAndDonorIdAndIsActiveTrue(requestId, donorId))
                .thenReturn(Optional.of(testAssignment));
        when(trackingLocationRepository.findFirstByEmergencyRequestIdOrderByTimestampDesc(requestId))
                .thenReturn(Optional.empty());
        when(userRepository.findById(donorId)).thenReturn(Optional.of(testDonor));
        
        when(stateMachineFactory.getStateMachine(requestId.toString())).thenReturn(stateMachine);
        when(stateMachine.startReactively()).thenReturn(Mono.empty());
        when(stateMachine.sendEvent(any(Mono.class))).thenReturn(Flux.empty());

        assertDoesNotThrow(() -> trackingService.updateLocation(requestId, donorId, locationRequestDTO));

        verify(trackingLocationRepository).save(any(TrackingLocation.class));
        verify(stateMachineFactory).getStateMachine(requestId.toString());
        verify(stateMachine).sendEvent(any(Mono.class));
    }

    @Test
    void getTrackingStatus_Success() {
        when(assignmentRepository.findByRequestIdAndIsActiveTrue(requestId))
                .thenReturn(Optional.of(testAssignment));
        when(requestRepository.findById(requestId)).thenReturn(Optional.of(testRequest));

        TrackingStatusResponseDTO result = trackingService.getTrackingStatus(requestId, donorId);

        assertNotNull(result);
        assertTrue(result.isTrackingActive());
        assertEquals(EmergencyStatus.DONOR_TRAVELLING, result.getCurrentStatus());
    }


}
