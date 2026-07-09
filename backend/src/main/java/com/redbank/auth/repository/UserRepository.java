package com.redbank.auth.repository;

import com.redbank.auth.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByFirebaseUidAndIsDeletedFalse(String firebaseUid);
    Optional<User> findByPhoneNumberAndIsDeletedFalse(String phoneNumber);
    boolean existsByPhoneNumberAndIsDeletedFalse(String phoneNumber);
}
