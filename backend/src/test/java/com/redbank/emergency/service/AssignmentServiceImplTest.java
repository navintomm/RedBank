package com.redbank.emergency.service;

import com.redbank.auth.entity.User;
import com.redbank.auth.repository.UserRepository;
import com.redbank.donor.entity.DonorProfile;
import com.redbank.donor.repository.DonorRepository;
import com.redbank.emergency.entity.EmergencyRequest;
import com.redbank.emergency.entity.EmergencyRequestAssignment;
import com.redbank.emergency.repository.EmergencyRequestAssignmentRepository;
import com.redbank.emergency.repository.EmergencyRequestRepository;
import com.redbank.emergency.service.impl.AssignmentServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.locationtech.jts.geom.Point;

import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AssignmentServiceImplTest {

    @Mock
    private EmergencyRequestAssignmentRepository assignmentRepository;

    @Mock
    private EmergencyRequestRepository requestRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private DonorRepository donorRepository;

    @Mock
    private RoutingService routingService;

    @InjectMocks
    private AssignmentServiceImpl assignmentService;

    private UUID requestId;
    private UUID donorId;

    @BeforeEach
    void setUp() {
        requestId = UUID.randomUUID();
        donorId = UUID.randomUUID();
    }

    @Test
    void processAcceptance_ShouldThrowException_WhenActiveAssignmentAlreadyExists() {
        when(assignmentRepository.existsByRequestIdAndIsActiveTrue(requestId)).thenReturn(true);

        IllegalStateException exception = assertThrows(IllegalStateException.class, 
                () -> assignmentService.processAcceptance(requestId, donorId));

        assertEquals("Active assignment already exists for this request", exception.getMessage());
        
        verify(requestRepository, never()).findById(any());
        verify(assignmentRepository, never()).save(any());
    }

    @Test
    void processAcceptance_ShouldThrowException_WhenDonorAlreadyAssigned() {
        when(assignmentRepository.existsByRequestIdAndIsActiveTrue(requestId)).thenReturn(false);
        when(assignmentRepository.existsByRequestIdAndDonorId(requestId, donorId)).thenReturn(true);

        IllegalStateException exception = assertThrows(IllegalStateException.class, 
                () -> assignmentService.processAcceptance(requestId, donorId));

        assertEquals("Donor is already assigned to this request", exception.getMessage());
        
        verify(requestRepository, never()).findById(any());
        verify(assignmentRepository, never()).save(any());
    }
}
