package com.redbank.emergency.repository;

import com.redbank.emergency.entity.TrackingLocation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface TrackingLocationRepository extends JpaRepository<TrackingLocation, UUID> {
    
    Optional<TrackingLocation> findFirstByEmergencyRequestIdOrderByTimestampDesc(UUID emergencyRequestId);
    
    List<TrackingLocation> findAllByEmergencyRequestIdOrderByTimestampAsc(UUID emergencyRequestId);
}
