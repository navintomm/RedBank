package com.redbank.auth.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.ZonedDateTime;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, unique = true, length = 20)
    private String phoneNumber;

    @Column(nullable = false, unique = true, length = 128)
    private String firebaseUid;

    @Column(length = 50)
    private String firstName;

    @Column(length = 50)
    private String lastName;

    @Builder.Default
    @Column(nullable = false)
    private boolean isDeleted = false;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
            name = "user_roles",
            joinColumns = @JoinColumn(name = "user_id"),
            inverseJoinColumns = @JoinColumn(name = "role_id")
    )
    @Builder.Default
    private Set<Role> roles = new HashSet<>();

    @CreationTimestamp
    @Column(updatable = false)
    private ZonedDateTime createdAt;

    @UpdateTimestamp
    private ZonedDateTime updatedAt;
    
    @Column(length = 128)
    private String createdBy;
}
