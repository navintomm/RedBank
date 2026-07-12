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
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
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
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "blood_group", nullable = false, columnDefinition = "blood_group_enum")
    private BloodGroup bloodGroup;

    @Builder.Default
    @NotNull
    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "emergency_type", nullable = false, columnDefinition = "emergency_type_enum")
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
    private BigDecimal latitude;

    @Column(name = "longitude", precision = 11, scale = 8)
    private BigDecimal longitude;

    @Column(name = "hospital_location", columnDefinition = "geometry(Point,4326)")
    private Point hospitalLocation;

    @Builder.Default
    @NotNull
    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "status", nullable = false, columnDefinition = "emergency_status_enum")
    private EmergencyStatus status = EmergencyStatus.DRAFT;

    @Builder.Default
    @NotNull
    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "priority", nullable = false, columnDefinition = "emergency_priority_enum")
    private EmergencyPriority priority = EmergencyPriority.EMERGENCY;

    @Builder.Default
    @NotNull
    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "source", nullable = false, columnDefinition = "request_source_enum")
    private RequestSource source = RequestSource.INDIVIDUAL;

    @Enumerated(EnumType.STRING)
    @Column(name = "failure_reason", length = 512)
    private FailureReason failureReason;

    @Enumerated(EnumType.STRING)
    @Column(name = "cancel_reason", length = 512)
    private CancelReason cancelReason;

    @Builder.Default
    @Column(name = "current_search_tier")
    private Integer currentSearchTier = 1;

    @Builder.Default
    @Version
    @Column(name = "version", nullable = false)
    private Integer version = 0;

    @Builder.Default
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
