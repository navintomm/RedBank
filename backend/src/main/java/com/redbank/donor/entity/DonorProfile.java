package com.redbank.donor.entity;

import com.redbank.auth.entity.User;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.type.SqlTypes;
import org.locationtech.jts.geom.Point;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.ZonedDateTime;
import java.util.UUID;

@Entity
@Table(name = "donor_profile")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DonorProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "blood_group", nullable = false, columnDefinition = "blood_group_enum")
    private BloodGroup bloodGroup;

    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(columnDefinition = "gender_enum")
    private Gender gender;

    @Column(precision = 5, scale = 2)
    private BigDecimal weight;

    @Column(length = 100)
    private String district;

    @Column(length = 100)
    private String city;

    @Column(precision = 10, scale = 8)
    private BigDecimal latitude;

    @Column(precision = 11, scale = 8)
    private BigDecimal longitude;

    // PostGIS Geometry column
    @Column(columnDefinition = "geometry(Point, 4326)")
    private Point location;

    @Column(name = "last_donation_date")
    private LocalDate lastDonationDate;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "availability_status", nullable = false, columnDefinition = "availability_status_enum")
    @Builder.Default
    private AvailabilityStatus availabilityStatus = AvailabilityStatus.UNAVAILABLE;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "verification_level", nullable = false, columnDefinition = "verification_level_enum")
    @Builder.Default
    private VerificationLevel verificationLevel = VerificationLevel.PHONE_VERIFIED;

    @Column(name = "medical_notes", columnDefinition = "TEXT")
    private String medicalNotes;

    @Column(name = "profile_image_url", length = 512)
    private String profileImageUrl;

    @Builder.Default
    @Column(name = "is_deleted")
    private boolean isDeleted = false;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private ZonedDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private ZonedDateTime updatedAt;

    @Column(name = "created_by", length = 128)
    private String createdBy;
}
