package com.redbank.emergency.entity;

import com.redbank.emergency.enums.EmergencyStatus;
import com.redbank.emergency.statemachine.EmergencyEvent;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.OffsetDateTime;
import java.util.UUID;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

@Entity
@Table(name = "emergency_request_history")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EmergencyRequestHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "request_id", nullable = false)
    private EmergencyRequest request;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "previous_status", columnDefinition = "emergency_status_enum")
    private EmergencyStatus previousStatus;

    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.NAMED_ENUM)
    @Column(name = "new_status", nullable = false, columnDefinition = "emergency_status_enum")
    private EmergencyStatus newStatus;

    @Enumerated(EnumType.STRING)
    @Column(name = "event")
    private EmergencyEvent event;

    @Column(name = "actor_type", length = 50)
    private String actorType;

    @Column(name = "actor_id")
    private UUID actorId;

    @Column(name = "transition_reason", length = 256)
    private String transitionReason;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private OffsetDateTime createdAt;
}
