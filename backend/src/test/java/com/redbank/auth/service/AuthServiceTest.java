package com.redbank.auth.service;

import com.redbank.auth.dto.AuthResponse;
import com.redbank.auth.dto.RefreshRequest;
import com.redbank.auth.entity.RefreshToken;
import com.redbank.auth.entity.Role;
import com.redbank.auth.entity.User;
import com.redbank.auth.mapper.UserMapper;
import com.redbank.auth.repository.RefreshTokenRepository;
import com.redbank.auth.repository.RoleRepository;
import com.redbank.auth.repository.UserRepository;
import com.redbank.auth.security.JwtProvider;
import com.redbank.core.exception.TokenRefreshException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.time.ZonedDateTime;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class AuthServiceTest {

    @Mock
    private UserRepository userRepository;
    @Mock
    private RoleRepository roleRepository;
    @Mock
    private RefreshTokenRepository refreshTokenRepository;
    @Mock
    private JwtProvider jwtProvider;
    @Mock
    private UserMapper userMapper;

    @InjectMocks
    private AuthService authService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testRefreshToken_Success() {
        String tokenString = "valid-token";
        RefreshRequest request = new RefreshRequest(tokenString);
        
        User user = new User();
        user.setId(UUID.randomUUID());
        user.setRoles(Set.of(new Role(1, "ROLE_DONOR")));

        RefreshToken refreshToken = new RefreshToken();
        refreshToken.setToken(tokenString);
        refreshToken.setUser(user);
        refreshToken.setExpiryDate(ZonedDateTime.now().plusDays(1));

        when(refreshTokenRepository.findByToken(tokenString)).thenReturn(Optional.of(refreshToken));
        when(jwtProvider.generateJwtToken(any())).thenReturn("new-jwt-token");

        AuthResponse response = authService.refreshToken(request);

        assertNotNull(response);
        assertEquals("new-jwt-token", response.accessToken());
    }

    @Test
    void testRefreshToken_Expired() {
        String tokenString = "expired-token";
        RefreshRequest request = new RefreshRequest(tokenString);

        RefreshToken refreshToken = new RefreshToken();
        refreshToken.setToken(tokenString);
        refreshToken.setExpiryDate(ZonedDateTime.now().minusDays(1));

        when(refreshTokenRepository.findByToken(tokenString)).thenReturn(Optional.of(refreshToken));

        assertThrows(TokenRefreshException.class, () -> authService.refreshToken(request));
        verify(refreshTokenRepository, times(1)).delete(refreshToken);
    }
}
