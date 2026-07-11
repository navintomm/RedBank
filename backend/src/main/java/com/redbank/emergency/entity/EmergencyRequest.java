package com.redbank.emergency.entity;

import com.redbank.auth.entity.User;
import com.redbank.donor.entity.BloodGroup;
import com.redbank.emergency.enums.*;
import jakarta.persistence.*;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import org.locationtech.jts.geom.Point;

import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "emergency_request")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EmergencyRequest {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "requester_id", nullable = false)
    private User requester;

    @Column(name = "hospital_id")
    private UUID hospitalId;

    @NotBlank
    @Column(name = "patient_name", nullable = false, length = 128)
    private String patientName;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(name = "blood_group", nullable = false)
    private BloodGroup bloodGroup;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(name = "emergency_type", nullable = false)
    private EmergencyType emergencyType = EmergencyType.WHOLE_BLOOD;

    @Min(1)
    @Column(name = "units_required", nullable = false)
    private Integer unitsRequired;

    @NotBlank
    @Column(name = "hospital_name", nullable = false, length = 256)
    private String hospitalName;

    @Column(name = "hospital_address", columnDefinition = "TEXT")
    private String hospitalAddress;

    @NotBlank
    @Column(name = "city", nullable = false, length = 100)
    private String city;

    @Column(name = "pincode", length = 20)
    private String pincode;

    @Column(name = "latitude", precision = 10, scale = 8)
    private Double latitude;

    @Column(name = "longitude", precision = 11, scale = 8)
    private Double longitude;

    @Column(name = "hospital_location", columnDefinition = "geometry(Point,4326)")
    private Point hospitalLocation;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private EmergencyStatus status = EmergencyStatus.DRAFT;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(name = "priority", nullable = false)
    private EmergencyPriority priority = EmergencyPriority.EMERGENCY;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(name = "source", nullable = false)
    private RequestSource source = RequestSource.INDIVIDUAL;

    @Enumerated(EnumType.STRING)
    @Column(name = "failure_reason", length = 512)
    private FailureReason failureReason;

    @Enumerated(EnumType.STRING)
    @Column(name = "cancel_reason", length = 512)
    private CancelReason cancelReason;

    @Column(name = "current_search_tier")
    private Integer currentSearchTier = 1;

    @Version
    @Column(name = "version", nullable = false)
    private Integer version = 0;

    @Column(name = "is_deleted")
    private Boolean isDeleted = false;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private OffsetDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private OffsetDateTime updatedAt;

    @Column(name = "accepted_at")
    private OffsetDateTime acceptedAt;

    @Column(name = "travelling_at")
    private OffsetDateTime travellingAt;

    @Column(name = "arrived_at")
    private OffsetDateTime arrivedAt;

    @Column(name = "completed_at")
    private OffsetDateTime completedAt;

    @Column(name = "resolved_at")
    private OffsetDateTime resolvedAt;
}
