package com.redbank.emergency.repository;

import com.redbank.emergency.entity.EmergencyRequestAssignment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface EmergencyRequestAssignmentRepository extends JpaRepository<EmergencyRequestAssignment, UUID> {
    Optional<EmergencyRequestAssignment> findByRequestIdAndIsActiveTrue(UUID requestId);
    
    Optional<EmergencyRequestAssignment> findByRequestIdAndDonorIdAndIsActiveTrue(UUID requestId, UUID donorId);
}
