package com.redbank.emergency.repository;

import com.redbank.emergency.entity.EmergencyRequest;
import com.redbank.emergency.enums.EmergencyStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface EmergencyRequestRepository extends JpaRepository<EmergencyRequest, UUID> {
    Page<EmergencyRequest> findByRequesterIdAndIsDeletedFalse(UUID requesterId, Pageable pageable);
    
    // Finds active requests for a requester
    List<EmergencyRequest> findByRequesterIdAndStatusNotInAndIsDeletedFalse(UUID requesterId, List<EmergencyStatus> terminalStatuses);
}
