package com.redbank.emergency.service.impl;

import com.redbank.auth.entity.User;
import com.redbank.auth.repository.UserRepository;
import org.springframework.security.access.AccessDeniedException;
import com.redbank.emergency.dto.TrackingLocationRequestDTO;
import com.redbank.emergency.dto.TrackingLocationResponseDTO;
import com.redbank.emergency.dto.TrackingStatusResponseDTO;
import com.redbank.emergency.entity.EmergencyRequest;
import com.redbank.emergency.entity.EmergencyRequestAssignment;
import com.redbank.emergency.entity.TrackingLocation;
import com.redbank.emergency.enums.EmergencyStatus;
import com.redbank.emergency.repository.EmergencyRequestAssignmentRepository;
import com.redbank.emergency.repository.EmergencyRequestRepository;
import com.redbank.emergency.repository.TrackingLocationRepository;
import com.redbank.emergency.service.TrackingService;
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

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class TrackingServiceImpl implements TrackingService {

    private final TrackingLocationRepository trackingLocationRepository;
    private final EmergencyRequestRepository requestRepository;
    private final EmergencyRequestAssignmentRepository assignmentRepository;
    private final UserRepository userRepository;
    private final StateMachineFactory<EmergencyStatus, EmergencyEvent> stateMachineFactory;

    private static final double ARRIVAL_THRESHOLD_METERS = 50.0;
    private static final double MIN_MOVEMENT_THRESHOLD_METERS = 5.0;

    @Override
    @Transactional
    public void startTracking(UUID requestId, UUID donorId) {
        validateDonorAssignment(requestId, donorId);
        // Tracking starts implicitly when locations are pushed, but we can log or init state if needed
        log.info("Tracking started for request {} by donor {}", requestId, donorId);
        sendEvent(requestId, donorId, EmergencyEvent.START_TRAVEL);
    }

    @Override
    @Transactional
    public void stopTracking(UUID requestId, UUID donorId) {
        validateDonorAssignment(requestId, donorId);
        log.info("Tracking stopped for request {} by donor {}", requestId, donorId);
    }

    @Override
    @Transactional
    public void updateLocation(UUID requestId, UUID donorId, TrackingLocationRequestDTO dto) {
        EmergencyRequestAssignment assignment = validateDonorAssignment(requestId, donorId);
        EmergencyRequest request = assignment.getRequest();

        Optional<TrackingLocation> lastLocOpt = trackingLocationRepository.findFirstByEmergencyRequestIdOrderByTimestampDesc(requestId);
        
        if (lastLocOpt.isPresent()) {
            TrackingLocation lastLoc = lastLocOpt.get();
            // Ignore duplicate/older timestamps
            if (!dto.getTimestamp().isAfter(lastLoc.getTimestamp())) {
                return;
            }
            
            // Ignore insignificant movement
            double distanceMoved = calculateDistance(
                lastLoc.getLatitude(), lastLoc.getLongitude(),
                dto.getLatitude(), dto.getLongitude()
            );
            if (distanceMoved < MIN_MOVEMENT_THRESHOLD_METERS) {
                return;
            }
        }

        User donor = userRepository.findById(donorId)
                .orElseThrow(() -> new IllegalArgumentException("Donor not found"));

        TrackingLocation location = TrackingLocation.builder()
                .emergencyRequest(request)
                .donor(donor)
                .latitude(dto.getLatitude())
                .longitude(dto.getLongitude())
                .accuracy(dto.getAccuracy())
                .speed(dto.getSpeed())
                .heading(dto.getHeading())
                .timestamp(dto.getTimestamp())
                .build();

        trackingLocationRepository.save(location);

        // Check if arrived
        if (request.getHospitalLocation() != null || (request.getLatitude() != null && request.getLongitude() != null)) {
            double destLat = request.getLatitude() != null ? request.getLatitude().doubleValue() : request.getHospitalLocation().getY();
            double destLng = request.getLongitude() != null ? request.getLongitude().doubleValue() : request.getHospitalLocation().getX();
            
            double distanceToHospital = calculateDistance(dto.getLatitude(), dto.getLongitude(), destLat, destLng);
            if (distanceToHospital <= ARRIVAL_THRESHOLD_METERS && request.getStatus() == EmergencyStatus.DONOR_TRAVELLING) {
                log.info("Donor {} arrived at hospital for request {}. Distance: {}m", donorId, requestId, distanceToHospital);
                sendEvent(requestId, donorId, EmergencyEvent.ARRIVED_AT_LOCATION);
            }
        }
    }

    @Override
    @Transactional(readOnly = true)
    public TrackingStatusResponseDTO getTrackingStatus(UUID requestId, UUID userId) {
        EmergencyRequest request = requestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Emergency Request not found"));

        validateReadAccess(request, userId);

        boolean isTrackingActive = request.getStatus() == EmergencyStatus.DONOR_TRAVELLING;
        TrackingLocationResponseDTO latestLocationDto = null;
        Integer estimatedTravelTimeMins = null;
        java.time.OffsetDateTime estimatedArrival = null;
        UUID assignedDonorId = null;
        String assignedDonorName = null;

        if (isTrackingActive || request.getStatus() == EmergencyStatus.ACCEPTED) {
            Optional<EmergencyRequestAssignment> assignmentOpt = assignmentRepository.findByRequestIdAndIsActiveTrue(requestId);
            if (assignmentOpt.isPresent()) {
                EmergencyRequestAssignment assignment = assignmentOpt.get();
                estimatedTravelTimeMins = assignment.getEstimatedTravelTimeMins();
                estimatedArrival = assignment.getEstimatedArrival();
                assignedDonorId = assignment.getDonor().getId();
                assignedDonorName = assignment.getDonor().getFirstName() + " " + assignment.getDonor().getLastName();
            }
        }

        if (isTrackingActive || request.getStatus() == EmergencyStatus.ARRIVED) {
            Optional<TrackingLocation> latestLoc = trackingLocationRepository.findFirstByEmergencyRequestIdOrderByTimestampDesc(requestId);
            if (latestLoc.isPresent()) {
                latestLocationDto = mapToDTO(latestLoc.get());
            }
        }

        return TrackingStatusResponseDTO.builder()
                .isTrackingActive(isTrackingActive)
                .currentStatus(request.getStatus())
                .latestLocation(latestLocationDto)
                .estimatedTravelTimeMins(estimatedTravelTimeMins)
                .estimatedArrival(estimatedArrival)
                .assignedDonorId(assignedDonorId)
                .assignedDonorName(assignedDonorName)
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public List<TrackingLocationResponseDTO> getTrackingHistory(UUID requestId, UUID userId) {
        EmergencyRequest request = requestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Emergency Request not found"));

        validateReadAccess(request, userId);

        return trackingLocationRepository.findAllByEmergencyRequestIdOrderByTimestampAsc(requestId).stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    private EmergencyRequestAssignment validateDonorAssignment(UUID requestId, UUID donorId) {
        return assignmentRepository.findByRequestIdAndDonorIdAndIsActiveTrue(requestId, donorId)
                .orElseThrow(() -> new AccessDeniedException("Only the active assigned donor can publish locations."));
    }

    private void validateReadAccess(EmergencyRequest request, UUID userId) {
        boolean isRequester = request.getRequester().getId().equals(userId);
        boolean isAssignedDonor = assignmentRepository.findByRequestIdAndIsActiveTrue(request.getId())
                .map(a -> a.getDonor().getId().equals(userId))
                .orElse(false);

        if (!isRequester && !isAssignedDonor) {
            throw new AccessDeniedException("Only the requester and the assigned donor can view tracking data.");
        }
    }

    private TrackingLocationResponseDTO mapToDTO(TrackingLocation loc) {
        return TrackingLocationResponseDTO.builder()
                .latitude(loc.getLatitude())
                .longitude(loc.getLongitude())
                .accuracy(loc.getAccuracy())
                .speed(loc.getSpeed())
                .heading(loc.getHeading())
                .timestamp(loc.getTimestamp())
                .build();
    }

    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        int r = 6371; // Radius of the earth in km
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                        Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        double d = r * c; // Distance in km
        return d * 1000; // Distance in meters
    }
    
    private void sendEvent(UUID requestId, UUID donorId, EmergencyEvent event) {
        StateMachine<EmergencyStatus, EmergencyEvent> sm = stateMachineFactory.getStateMachine(requestId.toString());
        sm.startReactively().subscribe();
        Message<EmergencyEvent> message = MessageBuilder.withPayload(event)
                .setHeader(EmergencyStateMachineConstants.REQUEST_ID_HEADER, requestId)
                .setHeader(EmergencyStateMachineConstants.DONOR_ID_HEADER, donorId)
                .setHeader(EmergencyStateMachineConstants.ACTOR_ID_HEADER, donorId)
                .setHeader(EmergencyStateMachineConstants.ACTOR_TYPE_HEADER, "DONOR")
                .build();
        sm.sendEvent(reactor.core.publisher.Mono.just(message)).subscribe();
    }
}
