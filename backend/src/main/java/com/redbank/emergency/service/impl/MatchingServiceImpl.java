package com.redbank.emergency.service.impl;

import com.redbank.emergency.repository.EmergencyRequestRepository;
import com.redbank.donor.repository.DonorRepository;
import com.redbank.donor.entity.DonorProfile;
import com.redbank.donor.entity.AvailabilityStatus;
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
    private final DonorRepository donorRepository;
    private final NotificationService notificationService;
    private final StateMachineFactory<com.redbank.emergency.enums.EmergencyStatus, EmergencyEvent> stateMachineFactory;

    @Override
    public void startMatching(UUID requestId) {
        log.info("Starting geographic matching for request {}", requestId);
        
        // COHESION: Retrieves current state, isolates ST_DWithin query to MatchEngine context
        var request = requestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Request not found"));
                
        int tier = request.getCurrentSearchTier();
        
        // Define tier distances (e.g., Tier 1: 5km, Tier 2: 10km, Tier 3: 20km)
        double[] tierDistances = {0, 5000, 10000, 20000};
        double searchRadius = (tier > 0 && tier < tierDistances.length) ? tierDistances[tier] : 5000;
        
        // 1. Spatial Search
        List<DonorProfile> nearbyDonors = donorRepository.findAvailableDonorsNearby(
                request.getBloodGroup(), 
                AvailabilityStatus.AVAILABLE, 
                request.getHospitalLocation(), 
                searchRadius
        );
        
        // 2. Medical Eligibility Filtering (in-memory, business logic layer)
        java.time.LocalDate ninetyDaysAgo = java.time.LocalDate.now().minusDays(90);
        
        List<UUID> eligibleDonors = nearbyDonors.stream()
                .filter(d -> d.getDateOfBirth() != null && d.getDateOfBirth().isBefore(java.time.LocalDate.now().minusYears(18)))
                .filter(d -> d.getWeight() != null && d.getWeight().compareTo(java.math.BigDecimal.valueOf(50.0)) >= 0)
                .filter(d -> d.getLastDonationDate() == null || d.getLastDonationDate().isBefore(ninetyDaysAgo))
                .map(d -> d.getUser().getId())
                .toList();

        log.info("Found {} eligible donors for request {} at tier {} (radius: {}m)", eligibleDonors.size(), requestId, tier, searchRadius);
        
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
