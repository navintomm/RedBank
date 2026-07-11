package com.redbank.donor.repository;

import com.redbank.donor.entity.AvailabilityStatus;
import com.redbank.donor.entity.BloodGroup;
import com.redbank.donor.entity.DonorProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface DonorRepository extends JpaRepository<DonorProfile, UUID> {
    
    Optional<DonorProfile> findByUserIdAndIsDeletedFalse(UUID userId);
    
    boolean existsByUserIdAndIsDeletedFalse(UUID userId);
    
    // Example of a basic spatial query (will be expanded in Matching Engine)
    // using Hibernate Spatial ST_DWithin function
    @Query("SELECT d FROM DonorProfile d WHERE d.isDeleted = false " +
           "AND d.bloodGroup = :bloodGroup " +
           "AND d.availabilityStatus = :status " +
           "AND dwithin(d.location, :point, :distanceMeters) = true")
    List<DonorProfile> findAvailableDonorsNearby(
            @Param("bloodGroup") BloodGroup bloodGroup,
            @Param("status") AvailabilityStatus status,
            @Param("point") org.locationtech.jts.geom.Point point,
            @Param("distanceMeters") double distanceMeters);
}
