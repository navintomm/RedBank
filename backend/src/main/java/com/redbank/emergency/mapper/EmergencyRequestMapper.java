package com.redbank.emergency.mapper;

import com.redbank.emergency.dto.*;
import com.redbank.emergency.entity.*;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface EmergencyRequestMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "requester", ignore = true) // Handled in service
    @Mapping(target = "hospitalLocation", ignore = true) // Trigger populates this
    @Mapping(target = "status", ignore = true) // Default
    @Mapping(target = "source", ignore = true) // Default
    @Mapping(target = "failureReason", ignore = true)
    @Mapping(target = "cancelReason", ignore = true)
    @Mapping(target = "currentSearchTier", ignore = true)
    @Mapping(target = "version", ignore = true)
    @Mapping(target = "isDeleted", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "acceptedAt", ignore = true)
    @Mapping(target = "travellingAt", ignore = true)
    @Mapping(target = "arrivedAt", ignore = true)
    @Mapping(target = "completedAt", ignore = true)
    @Mapping(target = "resolvedAt", ignore = true)
    EmergencyRequest toEntity(EmergencyRequestCreateDTO dto);

    @Mapping(source = "requester.id", target = "requesterId")
    @Mapping(target = "timeline", expression = "java(toTimeline(entity))")
    EmergencyRequestResponseDTO toResponseDTO(EmergencyRequest entity);
    
    EmergencyRequestSummaryDTO toSummaryDTO(EmergencyRequest entity);

    default EmergencyRequestTimelineDTO toTimeline(EmergencyRequest entity) {
        if (entity == null) return null;
        return EmergencyRequestTimelineDTO.builder()
                .acceptedAt(entity.getAcceptedAt())
                .travellingAt(entity.getTravellingAt())
                .arrivedAt(entity.getArrivedAt())
                .completedAt(entity.getCompletedAt())
                .resolvedAt(entity.getResolvedAt())
                .build();
    }

    @Mapping(source = "request.id", target = "requestId")
    EmergencyRequestHistoryDTO toHistoryDTO(EmergencyRequestHistory entity);

    @Mapping(source = "request.id", target = "requestId")
    @Mapping(source = "donor.id", target = "donorId")
    @Mapping(source = "request", target = "requestSummary")
    EmergencyRequestNotificationDTO toNotificationDTO(EmergencyRequestNotification entity);

    @Mapping(source = "request.id", target = "requestId")
    @Mapping(source = "donor.id", target = "donorId")
    EmergencyRequestAssignmentDTO toAssignmentDTO(EmergencyRequestAssignment entity);
}
