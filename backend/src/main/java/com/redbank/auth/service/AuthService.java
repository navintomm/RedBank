package com.redbank.auth.service;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import com.redbank.auth.dto.*;
import com.redbank.auth.entity.RefreshToken;
import com.redbank.auth.entity.Role;
import com.redbank.auth.entity.User;
import com.redbank.auth.mapper.UserMapper;
import com.redbank.auth.repository.RefreshTokenRepository;
import com.redbank.auth.repository.RoleRepository;
import com.redbank.auth.repository.UserRepository;
import com.redbank.auth.security.JwtProvider;
import com.redbank.core.constants.AppConstants;
import com.redbank.core.exception.AuthException;
import com.redbank.core.exception.TokenRefreshException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.ZonedDateTime;
import java.util.Optional;
import java.util.UUID;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final JwtProvider jwtProvider;
    private final UserMapper userMapper;

    @Value("${jwt.refreshExpiration.ms:86400000}") // 24 Hours Default
    private Long refreshTokenDurationMs;

    public AuthService(UserRepository userRepository, RoleRepository roleRepository,
                       RefreshTokenRepository refreshTokenRepository, JwtProvider jwtProvider,
                       UserMapper userMapper) {
        this.userRepository = userRepository;
        this.roleRepository = roleRepository;
        this.refreshTokenRepository = refreshTokenRepository;
        this.jwtProvider = jwtProvider;
        this.userMapper = userMapper;
    }

    @Transactional
    public AuthResponse verifyAndLogin(VerifyRequest request) {
        try {
            // Verify token with Firebase Admin
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(request.idToken());
            String firebaseUid = decodedToken.getUid();
            String phoneNumber = (String) decodedToken.getClaims().get("phone_number");

            if (phoneNumber == null) {
                throw new AuthException("Phone number not found in Firebase token.");
            }

            Optional<User> userOpt = userRepository.findByFirebaseUidAndIsDeletedFalse(firebaseUid);
            User user;
            boolean isNewUser = false;

            if (userOpt.isPresent()) {
                user = userOpt.get();
                // Ensure phone matches
                if (!user.getPhoneNumber().equals(phoneNumber)) {
                    user.setPhoneNumber(phoneNumber);
                    userRepository.save(user);
                }
            } else {
                // Register new user
                isNewUser = true;
                user = new User();
                user.setFirebaseUid(firebaseUid);
                user.setPhoneNumber(phoneNumber);
                
                String roleName = (request.role() != null) ? request.role() : AppConstants.ROLE_DONOR;
                Role role = roleRepository.findByName(roleName)
                        .orElseThrow(() -> new RuntimeException("Error: Role is not found."));
                
                user.getRoles().add(role);
                userRepository.save(user);
            }

            // Generate App JWTs
            UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(user, null, user.getRoles().stream()
                    .map(r -> new org.springframework.security.core.authority.SimpleGrantedAuthority(r.getName()))
                    .toList());

            String jwt = jwtProvider.generateJwtToken(authentication);
            RefreshToken refreshToken = createRefreshToken(user);

            return new AuthResponse(jwt, refreshToken.getToken(), userMapper.toDto(user), isNewUser);

        } catch (FirebaseAuthException e) {
            throw new AuthException("Invalid Firebase token");
        }
    }

    @Transactional
    public AuthResponse refreshToken(RefreshRequest request) {
        return refreshTokenRepository.findByToken(request.refreshToken())
                .map(this::verifyExpiration)
                .map(RefreshToken::getUser)
                .map(user -> {
                    UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(user, null, user.getRoles().stream()
                            .map(r -> new org.springframework.security.core.authority.SimpleGrantedAuthority(r.getName()))
                            .toList());
                    String token = jwtProvider.generateJwtToken(authentication);
                    return new AuthResponse(token, request.refreshToken(), userMapper.toDto(user), false);
                })
                .orElseThrow(() -> new TokenRefreshException("Refresh token is not in database!"));
    }

    @Transactional
    public void logout(String firebaseUid) {
        userRepository.findByFirebaseUidAndIsDeletedFalse(firebaseUid)
                .ifPresent(refreshTokenRepository::deleteByUser);
    }

    @Transactional(readOnly = true)
    public UserDto getCurrentUser(String firebaseUid) {
        User user = userRepository.findByFirebaseUidAndIsDeletedFalse(firebaseUid)
                .orElseThrow(() -> new AuthException("User not found"));
        return userMapper.toDto(user);
    }

    private RefreshToken createRefreshToken(User user) {
        // Delete existing refresh tokens for the user to ensure single device session (optional logic)
        refreshTokenRepository.deleteByUser(user);
        
        RefreshToken refreshToken = new RefreshToken();
        refreshToken.setUser(user);
        refreshToken.setExpiryDate(ZonedDateTime.now().plusSeconds(refreshTokenDurationMs / 1000));
        refreshToken.setToken(UUID.randomUUID().toString());

        return refreshTokenRepository.save(refreshToken);
    }

    private RefreshToken verifyExpiration(RefreshToken token) {
        if (token.getExpiryDate().isBefore(ZonedDateTime.now())) {
            refreshTokenRepository.delete(token);
            throw new TokenRefreshException("Refresh token was expired. Please make a new signin request");
        }
        return token;
    }
}
