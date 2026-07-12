package com.redbank.emergency.entity;

import com.redbank.auth.entity.User;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "emergency_request_assignments")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EmergencyRequestAssignment {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "request_id", nullable = false)
    private EmergencyRequest request;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "donor_id", nullable = false)
    private User donor;

    @Column(name = "estimated_travel_time_mins")
    private Integer estimatedTravelTimeMins;

    @Column(name = "estimated_arrival")
    private OffsetDateTime estimatedArrival;

    @Column(name = "actual_arrival")
    private OffsetDateTime actualArrival;

    @Builder.Default
    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private OffsetDateTime createdAt;

    @Column(name = "completed_at")
    private OffsetDateTime completedAt;
}
