package com.redbank.emergency.repository;

import com.redbank.emergency.entity.EmergencyRequestHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface EmergencyRequestHistoryRepository extends JpaRepository<EmergencyRequestHistory, UUID> {
    List<EmergencyRequestHistory> findByRequestIdOrderByCreatedAtAsc(UUID requestId);
}
