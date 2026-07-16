package com.redbank.emergency.service.impl;

import com.redbank.auth.repository.UserRepository;
import com.redbank.emergency.entity.EmergencyRequestAssignment;
import com.redbank.emergency.repository.EmergencyRequestAssignmentRepository;
import com.redbank.emergency.repository.EmergencyRequestRepository;
import com.redbank.emergency.service.AssignmentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class AssignmentServiceImpl implements AssignmentService {

    private final EmergencyRequestAssignmentRepository assignmentRepository;
    private final EmergencyRequestRepository requestRepository;
    private final UserRepository userRepository;
    private final com.redbank.donor.repository.DonorRepository donorRepository;
    private final com.redbank.emergency.service.RoutingService routingService;

    @Override
    @Transactional(propagation = Propagation.MANDATORY) // BOUNDARY: Must execute within state machine transaction
    public void processAcceptance(UUID requestId, UUID donorId) {
        log.info("Processing acceptance assignment for request {} and donor {}", requestId, donorId);
        
        var request = requestRepository.findById(requestId).orElseThrow();
        var donor = userRepository.findById(donorId).orElseThrow();
        var donorProfile = donorRepository.findByUserIdAndIsDeletedFalse(donorId).orElseThrow();
        
        // Store acceptedAt
        request.setAcceptedAt(OffsetDateTime.now());
        requestRepository.save(request);

        int travelTimeMins = 30; // Fallback
        if (request.getHospitalLocation() != null && donorProfile.getLocation() != null) {
            travelTimeMins = routingService.calculateEstimatedTravelTimeMins(
                    donorProfile.getLocation().getY(), donorProfile.getLocation().getX(),
                    request.getHospitalLocation().getY(), request.getHospitalLocation().getX()
            );
        }
        
        EmergencyRequestAssignment assignment = EmergencyRequestAssignment.builder()
                .request(request)
                .donor(donor)
                .estimatedTravelTimeMins(travelTimeMins)
                .estimatedArrival(OffsetDateTime.now().plusMinutes(travelTimeMins))
                .isActive(true)
                .build();
                
        assignmentRepository.save(assignment);
        log.info("Assignment created. ETA: {} mins. Ready to notify requester via websockets/FCM (to be implemented).", travelTimeMins);
    }
}
