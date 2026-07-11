package com.redbank.emergency.repository;

import com.redbank.emergency.entity.EmergencyRequestNotification;
import com.redbank.emergency.enums.NotificationStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface EmergencyRequestNotificationRepository extends JpaRepository<EmergencyRequestNotification, UUID> {
    Page<EmergencyRequestNotification> findByDonorIdAndStatus(UUID donorId, NotificationStatus status, Pageable pageable);
    
    List<EmergencyRequestNotification> findByRequestId(UUID requestId);
    
    Optional<EmergencyRequestNotification> findByRequestIdAndDonorId(UUID requestId, UUID donorId);
}
